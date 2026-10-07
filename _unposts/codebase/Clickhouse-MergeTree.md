
# 1 Executive summary

The essence of `MergeTree` is to use an **immutable, sorted, self-describing data part** as the common unit of storage, concurrency, recovery, maintenance, and replication.

- An insert does not update existing files. It partitions and sorts a batch, builds a complete columnar part with indexes and checksums, and publishes that part atomically.
- A read takes a stable snapshot of visible parts, progressively prunes partitions, parts, granules, and columns, and reads only the surviving mark ranges.
- Background compaction merges several sorted parts into a larger sorted part and atomically replaces the inputs. Updates, deletes, TTL, recompression, projections, and engine-specific semantics reuse this transformation model.
- The partition key, sorting key, primary key, and granule solve different problems: management boundaries, physical locality, sparse search, and I/O granularity. Treating them as one “key” leads to poor designs.
- Immutability makes readers and writers mostly independent: old parts remain readable while a new version is built, and physical deletion is delayed until no reader can still reference them.
- Compaction capacity is part of write capacity. The engine must reserve resources, schedule background work, observe part growth, and apply ingestion backpressure before small parts become unbounded.
- Replication and tiered storage operate on whole verified parts rather than coordinating arbitrary page mutations, keeping distributed protocols above the local storage format.

In reusable storage-engine terms, the design is:

```text
batch → partition → sort → build immutable part → atomic publish
                                      │
query → snapshot → prune → read marks │
                                      ▼
                     background transform and replace
```

The most important implementation question is therefore: **What is the immutable publication unit, how is it indexed and validated, and how can every maintenance operation replace it safely?** Once that boundary is sound, read optimization, compaction policy, updates, tiering, and replication can evolve around it.

> Source baseline: ClickHouse `master` at commit `4f8c9f219120fcb713fc907466c866b453a911d0`, dated 2026-09-28.
>
> This document is intentionally about architecture and design choices. It uses the current implementation as evidence, but it is not a class-by-class source walkthrough. The goal is to build a mental model that is useful both for understanding `MergeTree` and for designing another analytical storage engine.

# 2 The one-sentence mental model

`MergeTree` is a **collection of immutable, internally sorted, columnar data parts**. Inserts create new parts quickly; reads prune parts and small ranges inside parts; background compaction continuously replaces several small parts with fewer large parts.

That sentence contains most of the design:

- **Immutable parts** make concurrent reads, crash recovery, replication, backup, and cache management tractable.
- **Sorted rows inside each part** enable a small sparse primary index instead of a large row-level index.
- **Columnar streams** make analytical scans read only the required columns.
- **Background merging** converts cheap foreground writes into efficient long-term layout.
- **Replacement instead of in-place modification** provides a common mechanism for compaction, mutations, TTL, recompression, and materialized physical structures.

The table is therefore not one globally sorted file. It is a set of sorted runs whose count and size distribution are managed over time.

```text
INSERT batches
     │
     ▼
small immutable sorted parts ───────────────┐
     │                                      │
     │ background selection                │ SELECT snapshot
     ▼                                      ▼
fewer, larger sorted parts           prune parts and granules
     │                                      │
     └──────── atomic replacement ──────────┘
```

This resembles an LSM tree at a high level, but `MergeTree` is not simply a textbook leveled or size-tiered LSM:

- parts are directly queryable columnar objects, not just key-value runs;
- there is no requirement that the primary key be unique;
- partitions are explicit administrative and compaction boundaries;
- compaction selection is heuristic and resource-aware rather than a fixed level schedule;
- merge-time transforms may change row semantics, as in `ReplacingMergeTree`, `SummingMergeTree`, and `AggregatingMergeTree`.

# 3 What the engine is optimizing for

The architecture favors analytical workloads with batch-oriented ingestion:

1. **Keep foreground inserts bounded.** Sorting and writing one batch is acceptable; reorganizing the whole table is not.
2. **Make scans proportional to useful data.** Eliminate irrelevant partitions, parts, granules, and columns before decoding rows.
3. **Exploit locality.** Rows that are filtered or aggregated together should be close in the sorting order.
4. **Move expensive maintenance out of the write path.** Consolidation, cleanup, TTL application, recompression, and much schema materialization happen asynchronously.
5. **Treat storage objects as replaceable values.** A completed part can be published, copied, fetched, backed up, moved, or retired as one unit.

The price is equally important:

- newly inserted data initially increases the number of parts;
- reads may need to consult several parts;
- updates are not naturally in-place;
- compaction consumes disk bandwidth, CPU, and temporary space;
- some engine semantics become final only after merging unless a query requests `FINAL`.

An implementation inspired by `MergeTree` must therefore design foreground I/O and background maintenance together. Compaction is not an optional cleanup feature; it is part of the write algorithm.

# 4 The hierarchy of physical units

The cleanest way to understand the engine is as a hierarchy:

```text
Table
└── Partition: administrative and merge boundary
    └── Data part: immutable publication/replacement unit
        └── Granule: smallest normal index and read unit
            └── Column stream: compressed data addressed by marks
```

Each level solves a different problem.

| Unit | Main purpose | Typical operation |
| --- | --- | --- |
| Table | Schema, policies, active-part catalog | Take a read snapshot, schedule work |
| Partition | Bound maintenance and data management | Prune, drop, move, freeze, merge within it |
| Part | Atomic immutable version of a row range | Publish, replace, fetch, back up |
| Granule | Balance index size against read amplification | Skip or read a mark range |
| Column stream | Efficient analytical I/O | Seek, decompress, decode required columns |

The crucial design principle is that these units are deliberately different. A partition is too large to be the normal write unit, a part is too large to be the normal read unit, and a row is too small to index individually for this workload.

# 5 Four different notions of “key”

Many explanations of storage engines become confusing because they use “key” for several unrelated roles. `MergeTree` keeps the roles separate.

## 5.1 Partition key: the management boundary

`PARTITION BY` assigns each row to a partition. Rows from different partitions go into different parts, and parts from different partitions are not merged together.

The partition key is valuable for:

- dropping or moving a time range as whole parts;
- bounding merge work;
- partition-level pruning;
- backup and operational isolation.

It should usually be coarse. High-cardinality partitioning creates many independent streams of small parts. That increases metadata, filesystem objects, scheduling work, and read fan-out while preventing compaction across those boundaries.

The key lesson is: **partitioning is primarily a data-management decision, not the main query index**.

## 5.2 Sorting key: the physical clustering rule

`ORDER BY` defines the lexicographic order of rows inside every part. It determines:

- which predicates benefit most from locality and range pruning;
- compression quality, because similar values become adjacent;
- whether ordered reads and early `LIMIT` termination are possible;
- which rows meet during merge-time semantic transforms.

The sorting key is the most consequential table-design choice. It should reflect common filter prefixes and access patterns, not merely uniqueness or source-system identity.

## 5.3 Primary key: the sparse search structure

The `PRIMARY KEY` expression determines which values are stored in the sparse primary index. If it is omitted, it is derived from the sorting key. When explicitly different, it must be a prefix of the sorting key.

This means the primary key is not:

- a uniqueness constraint;
- a row locator;
- a dense B-tree entry for every row.

It is a compact summary of the sorted order at granule boundaries. Keeping it shorter than the full sorting key can reduce index memory while preserving a longer physical clustering key.

## 5.4 Granule and mark: the addressable I/O unit

A part is divided into granules. For each granule boundary, the primary index records key values, and mark files record positions in column streams. A predicate on the key is converted into ranges of marks; readers then seek to those marks in only the required columns.

Granularity is a fundamental trade-off:

- smaller granules improve pruning precision but enlarge indexes and mark metadata;
- larger granules reduce metadata but increase false-positive reads;
- adaptive granularity also considers bytes, preventing very wide rows from producing oversized read units.

This is a powerful general pattern: **index blocks, not rows, and make the data layout seekable at the same block boundaries**.

# 6 The immutable data part

A data part is the central abstraction. It is independently readable and largely self-describing. Conceptually, it contains:

- compressed column data;
- mark files that map granules to positions in column streams;
- the sparse primary index;
- partition values and part-level min/max metadata;
- optional data-skipping indexes, statistics, and projections;
- row count, column/type metadata, serialization metadata, and TTL metadata;
- checksums covering the files that belong to the part.

## 6.1 Logical layout and physical container are separate choices

The current code distinguishes two axes:

- `Wide` versus `Compact` controls how column data and marks are laid out. `Wide` uses separate files or streams per column; `Compact` groups the columns and is useful for small parts.
- `Full` versus `Packed` controls how the part's files are represented by the underlying part storage.

This separation matters architecturally. The query layer should reason about columns, marks, and indexes without being tightly coupled to one filesystem-object layout.

## 6.2 Part identity encodes lineage

A regular part name is derived from information equivalent to:

```text
partition-id_min-block_max-block_level[_mutation-version]
```

The block-number interval describes the logical insert range covered by the part. The level describes merge ancestry. The mutation version describes rewritten data. From this metadata the engine can determine whether two parts are disjoint, whether one part covers another, and whether a part is a mutation child of another.

This is more than naming. It gives the catalog a cheap algebra for replacement and recovery:

```text
part A covers part B
    if they belong to the same partition
    and A's block interval contains B's interval
    and A's merge/mutation lineage is at least as new
```

An engine built around immutable files needs an explicit version/containment model like this. File timestamps or directory enumeration order are not sufficient.

## 6.3 Immutability simplifies concurrency

After a part joins the working set, readers hold it as a reference to immutable data. A merge creates a new part instead of modifying its inputs. Publishing the new part changes catalog visibility; it does not rewrite objects currently used by readers.

That yields a simple reader rule:

> A query reads a stable vector of visible part references. Parts that become obsolete afterward remain valid until the readers holding them finish.

This is read-copy-update at part granularity. It avoids page latches and lets long scans coexist with inserts and compaction.

# 7 Part lifecycle and atomic replacement

The current part state machine is approximately:

```text
Temporary → PreActive → Active → Outdated → Deleting
                 └──────────────→ Outdated   (rollback or already covered)
```

- `Temporary`: files are still being generated and the part is not queryable.
- `PreActive`: the part is complete and registered for commit, but not visible to ordinary reads.
- `Active`: the part belongs to the current dataset.
- `Outdated`: a newer covering part has replaced it; existing readers may still hold it.
- `Deleting`: no reader owns it and cleanup is removing its storage.

Publication follows a disciplined sequence:

1. Build a complete part in temporary storage.
2. Finalize streams, indexes, metadata, and checksums.
3. Precommit the underlying part-storage transaction.
4. Give the part its final identity and place it in `PreActive` state.
5. Under the part-catalog lock, verify that it does not illegally intersect active parts.
6. Atomically make it `Active` and mark any parts it covers `Outdated`.
7. Delete obsolete parts only after visibility and ownership rules permit it.

The catalog transaction can roll back precommitted parts. Temporary names are recognizable and stale temporary directories can be reclaimed after interrupted work. On startup, the engine loads part metadata and uses the containment relation to reconstruct the active set.

This leads to three reusable storage-engine rules:

- **Never publish a partially written object.**
- **Make replacement an atomic metadata operation, even when physical deletion is delayed.**
- **Make abandoned work distinguishable from committed state.**

Exact power-loss durability still depends on configured synchronization behavior, but the structural failure model is clear: completed immutable parts are recoverable; temporary work is disposable.

# 8 Write path: batch, sort, materialize, publish

The foreground write path turns an input block into one or more self-contained parts.

```text
input block
    │ validate and evaluate expressions
    ▼
split by partition
    │
    ├── partition A ── sort by sorting key ── write temporary part ──┐
    └── partition B ── sort by sorting key ── write temporary part ──┤
                                                                    ▼
                                                        atomically publish batch
```

## 8.1 Split by partition before writing

The writer evaluates the partition expression and scatters rows into per-partition blocks. This guarantees that one part belongs to one partition and that future compaction never has to split a part merely to enforce partition boundaries.

It also explains why one poorly batched insert can create many parts: one part may be produced for every partition touched by the input block.

## 8.2 Sort each block once

Rows are sorted according to the sorting key. If the input is already sorted, the writer can avoid the permutation. Specialized `MergeTree` variants may also apply their merge semantics inside the new block, but they still produce a sorted part.

This is the core foreground cost. Sorting each batch independently avoids a random-write data structure and defers global consolidation to sequential background work.

## 8.3 Build data and access structures together

While writing column streams, the engine also builds the structures that describe those bytes:

- primary-index entries at granule boundaries;
- marks for seeking into column streams;
- part min/max metadata;
- configured skipping indexes and statistics;
- projections when configured for insert-time materialization;
- TTL and serialization metadata;
- checksums and size accounting.

Building these artifacts in the same immutable unit keeps them version-aligned. A reader never needs to reconcile an index updated separately from its data part.

## 8.4 Choose layout using part size

The writer can choose `Compact` for small parts and `Wide` for larger ones. It also selects a compression codec and reserves space before completing the part. This is an example of a useful separation:

- logical table semantics are stable;
- the physical encoding can be chosen per part.

Different generations of data may therefore coexist while the reader dispatches through a common part interface.

## 8.5 Apply backpressure when compaction falls behind

Part creation is cheap enough that clients can outpace background merging. The implementation monitors active parts per partition, inactive parts, total parts, and related storage pressure. It can delay inserts and eventually reject them with a `Too many parts` exception.

This is not merely defensive configuration. It closes the control loop:

```text
insert rate → part creation rate → merge backlog → part count
     ▲                                      │
     └────────── delay or reject ───────────┘
```

Without backpressure, an immutable-run engine can fail through metadata and scheduling explosion long before it runs out of raw disk capacity.

# 9 Read path: a pruning funnel

The read design reduces a table to a set of mark ranges, then schedules those ranges across readers.

```text
visible part snapshot
        │
        ▼
partition and part min/max pruning
        │
        ▼
part-level statistics and virtual-column pruning
        │
        ▼
sparse primary-index analysis
        │
        ▼
data-skipping indexes and cached conditions
        │
        ▼
mark ranges assigned to read workers
        │
        ▼
PREWHERE / filter columns first, remaining columns later
```

The exact set and ordering of optimizations can vary with the query, available indexes, mutations, and settings. The invariant is more important than the order:

> An index may discard a part or granule only when it can prove that the query predicate cannot match it.

False positives cost extra reads. False negatives produce wrong answers and are forbidden.

## 9.1 Take a visibility snapshot

The engine first resolves the parts visible to the query or transaction. The query retains references to those parts, so later merges can change the active catalog without invalidating the scan.

## 9.2 Prune entire parts cheaply

Partition expressions, virtual part columns, and part min/max metadata can reject whole parts without opening column data. Part-level statistics can provide another coarse filter when they are valid for the query.

This stage is why part metadata should remain small, self-contained, and cheap to load.

## 9.3 Convert primary-key predicates into mark ranges

Because each part is sorted, the sparse primary index can locate candidate granules for equality and range predicates on useful key prefixes. The result is a collection of half-open mark ranges rather than individual row IDs.

The sparse design intentionally reads some extra rows around boundaries. Its index is small enough to keep resident or cache effectively even for very large datasets.

## 9.4 Refine ranges with skipping indexes

Data-skipping indexes summarize groups of rows using structures such as min/max sets, Bloom filters, or specialized text/vector structures. They refine mark ranges but do not replace the sorting-key design.

The current implementation can choose an application order per part, favoring cheap/coarse structures and considering index size. That reflects a broader principle: **an index has an evaluation cost as well as selectivity**.

The implementation also disables unsafe pruning when pending mutations, patch parts, masking policies, or read-time conversions make stored summaries stale. Optimization metadata is usable only while it describes the values the query will actually see.

## 9.5 Read columns late

After range selection, read pools divide mark ranges among streams. Column readers use marks to seek and decode only requested substreams. `PREWHERE` can read filter columns first, discard rows, and then load wider payload columns for survivors.

This separates two independent forms of pruning:

- **horizontal pruning** removes rows or granules;
- **vertical pruning** avoids unused columns.

Both are required for an efficient columnar engine.

## 9.6 Preserve or reconstruct order only when needed

Because each part is sorted, the engine can read in key order, reverse order, or ordinary parallel order depending on the plan. Globally ordered output may require merging sorted streams from multiple parts. `FINAL` may additionally apply engine-specific row reconciliation during the read.

Avoiding these operations when the query does not need them is as important as supporting them.

## 9.7 Projections are alternate physical layouts

A projection is another part-like physical representation attached to a parent part. Query planning can choose it when its ordering or aggregation better matches the query. During compaction, projections are merged or rebuilt along with the parent.

This is a general extensibility pattern: keep the table's logical interface stable while allowing multiple version-aligned physical layouts.

# 10 Compaction: the engine's continuous optimizer

Every insert increases the number of sorted runs. If no merge occurred, read amplification, open files, metadata, and scheduling overhead would grow without bound. Compaction restores the intended shape of the table.

## 10.1 Separate eligibility from policy

The current design has two conceptually different decisions:

1. **Can these parts be merged safely?**
2. **Which safe range is the best use of resources now?**

Eligibility checks invariants such as:

- all parts belong to the same partition;
- their logical block ranges form a valid adjacent range;
- no part is already participating in conflicting background work;
- no uncommitted or outdated part can later appear in a gap and invalidate the result;
- transaction visibility and mutation ordering are respected;
- a storage location has enough reserved space.

Policy then scores eligible ranges using size ratios, age, part pressure, maximum merge size, available executor capacity, and special work such as TTL.

Keeping correctness predicates separate from scheduling heuristics is an excellent design choice. Heuristics can evolve without weakening data invariants.

## 10.2 Merge sorted inputs into another immutable part

The execution path is a multiway ordered merge:

```text
sorted part A ─┐
sorted part B ─┼─ merge transform ─ write temporary result ─ atomic replace
sorted part C ─┘
```

The result covers the input block-number interval and advances merge lineage. Once published, inputs become `Outdated` and are removed later.

The same publication protocol used by inserts is reused by compaction. This sharply reduces the number of consistency mechanisms an engine must get right.

## 10.3 Horizontal and vertical merge algorithms

The current `MergeTask` can choose between:

- **Horizontal merge:** merge all columns together row by row.
- **Vertical merge:** first merge key and index-relevant columns to determine row provenance, then gather ordinary columns separately.

Horizontal merging is simpler and works well for narrower or smaller inputs. Vertical merging reduces peak memory and repeated movement of wide rows when there are many non-key columns, at the cost of extra bookkeeping and passes.

This illustrates a broader pattern: separate the logical merge result from the physical algorithm used to produce it.

## 10.4 Compaction is a maintenance framework

While rewriting data, a merge can also:

- apply row, column, move, and recompression TTL rules;
- rebuild or merge projections;
- materialize missing skipping indexes and statistics;
- apply pending patches or delete masks;
- adopt current serialization or compression choices;
- implement engine-family row semantics.

Piggybacking maintenance on an already necessary rewrite amortizes I/O. The danger is unlimited scope: every added responsibility increases merge latency and backlog risk. Resource accounting and observability must grow with the maintenance features.

# 11 Updates, deletes, and merge-time semantics

Immutable columnar parts make arbitrary row updates expensive. `MergeTree` therefore uses several forms of deferred transformation rather than one universal in-place update path.

## 11.1 Full mutations rewrite parts

A mutation identifies affected parts and produces replacement parts with a higher mutation version. This is conceptually compaction with a transformation applied. Unaffected columns may sometimes be reused, but the publication model remains “new part replaces old part.”

## 11.2 Lightweight changes use visibility or delta structures

The current code supports lightweight delete masks and patch parts for lightweight updates. These can affect what a reader sees before the base part is fully rewritten. Later merges absorb the logical change into ordinary parts.

This introduces an important correctness rule: stored indexes and statistics describe a particular physical version. If an overlay changes indexed values, pruning must either understand the overlay or stop using the stale summary.

## 11.3 The `MergeTree` family changes the merge transform

The base architecture remains the same across much of the family. What changes is how rows with equal sorting keys are reconciled during a merge:

- ordinary `MergeTree` preserves rows;
- `ReplacingMergeTree` chooses a representative, optionally by version;
- `SummingMergeTree` combines numeric measures;
- `AggregatingMergeTree` combines aggregate states;
- collapsing variants interpret sign/version columns.

These semantics are generally eventual because equal-key rows can remain in different parts until compaction. `FINAL` requests read-time reconciliation when the caller needs the merged view immediately, trading CPU and memory for stronger query-time semantics.

The architectural lesson is to implement such variants as **merge policies over the same immutable-part substrate**, not as separate storage engines from scratch.

# 12 Background execution and resource governance

Background work is part of normal operation, so it needs an explicit control plane.

`BackgroundJobsAssignee` instances decide when a table has data-processing, moving, or streaming work. Tasks are submitted to bounded executors for merges/mutations, moves, fetches, and common work. When no work is available or an executor is full, scheduling backs off; new work triggers earlier retries.

Several details are worth generalizing:

- **Tasks are incremental.** Long merges execute in steps, allowing the executor to share workers and observe cancellation.
- **Space is reserved before rewriting.** A merge temporarily needs both inputs and output.
- **Conflicting parts are tagged.** Selection prevents two tasks from rewriting overlapping logical ranges.
- **Different resource classes use different pools.** A backlog of remote fetches should not silently consume every merge worker.
- **Pressure feeds back to writers.** Part-count thresholds delay or reject ingestion when maintenance cannot keep up.

A background scheduler that only answers “what work exists?” is incomplete. It must also answer “what work is safe, affordable, and most valuable now?”

# 13 Storage abstraction, tiering, and replication

## 13.1 Keep logical parts above the storage backend

`IMergeTreeDataPart` describes the logical part, while `IDataPartStorage`, disks, volumes, and storage policies handle physical placement and file operations. This allows the same part model to work across local disks, remote object storage, packed layouts, moves between volumes, and zero-copy-related mechanisms.

Because a part is immutable, tiering can move or replace whole objects instead of coordinating page-level writes. Checksums and self-contained metadata make verification possible at the same boundary.

## 13.2 Replication coordinates part operations, not row writes

`StorageReplicatedMergeTree` extends the same local part model with Keeper-backed logs and per-replica queues. The replicated queue tracks the parts that should exist, parts expected from queued operations, future parts, mutations, and conflicting range operations. A replica may execute a merge locally or fetch an already produced covering part.

The key architectural point is that replication is layered above deterministic immutable-part operations:

```text
shared operation log / ordering
             │
             ▼
replica queue chooses merge, fetch, mutate, or drop
             │
             ▼
same local part publication and replacement model
```

Designing a stable local storage object first makes distributed coordination much smaller. The replicated protocol talks about named part ranges and transformations instead of synchronizing arbitrary page mutations.

# 14 The most important invariants

An implementation can change algorithms and file formats while preserving these invariants:

1. A visible part is complete, internally consistent, and independently readable.
2. A regular part belongs to exactly one partition.
3. Rows inside a part obey the declared sorting order.
4. The primary index and marks describe the exact bytes of their part.
5. Active regular parts do not illegally overlap; replacement follows the part-containment relation.
6. Readers retain a stable set of visible immutable parts.
7. A merge publishes its output before its inputs become physically removable.
8. Pruning structures may return false positives but never false negatives.
9. Background operations on overlapping logical ranges are serialized.
10. Temporary and obsolete objects are distinguishable from active objects after restart.
11. Writers are throttled before part growth overwhelms maintenance.
12. Replication and tiering preserve part identity and verification metadata.

These invariants are more useful than memorizing individual classes. They form the contract around which the source is organized.

# 15 A practical blueprint for building a smaller engine

Trying to reproduce all of `MergeTree` at once would obscure the essential ideas. A reasonable implementation sequence is:

## 15.1 Stage 1: define the units and keys

Specify:

- the partition expression;
- the physical sorting key;
- the sparse-index key prefix;
- the target granule size;
- the immutable segment/part identity and containment rules.

Do this before choosing compression libraries or cache policies. Incorrect boundaries are much harder to change later than encodings.

## 15.2 Stage 2: build one self-contained immutable part

Implement a writer that:

1. accepts a columnar batch;
2. sorts it;
3. writes compressed column streams;
4. writes marks and a sparse primary index;
5. records schema, row count, and checksums;
6. finalizes into an independently readable directory or object.

Implement a reader that can scan selected columns and seek to mark ranges.

## 15.3 Stage 3: add atomic catalog publication

Maintain an in-memory catalog of active parts backed by recoverable on-disk identities. Build new parts under temporary names, finalize them, then atomically publish. Keep obsolete parts alive while readers retain references.

At this stage, make restart recovery and interrupted-write cleanup work. Delaying recovery design usually creates formats that cannot be reasoned about after failure.

## 15.4 Stage 4: add the pruning funnel

Start with:

- partition pruning;
- part-level min/max pruning;
- sparse-primary-index range search;
- column projection.

Then add `PREWHERE`-like late materialization and optional skipping indexes. Every new pruning structure needs an explicit validity rule under schema changes and updates.

## 15.5 Stage 5: add compaction as atomic replacement

Select adjacent compatible parts in one partition, merge their sorted streams, write a temporary output, and replace inputs atomically. Start with a simple size-ratio policy and strict resource limits.

Measure at least:

- parts per partition;
- merge queue age;
- bytes read and written by compaction;
- write amplification;
- read amplification in parts and granules;
- temporary space reservations;
- rejected or delayed writes.

## 15.6 Stage 6: close the control loop

Add bounded worker pools, cancellation, retries with backoff, disk-space reservations, and ingestion throttling. Test a sustained input rate above compaction capacity; a safe engine should degrade predictably rather than accumulate unbounded work.

## 15.7 Stage 7: choose an update model explicitly

Pick one or more:

- full part rewrite;
- delete bitmap or visibility mask;
- delta/patch part applied at read time and absorbed by compaction;
- merge-time version selection.

Document when indexes remain valid. Do not allow update overlays to silently invalidate pruning metadata.

## 15.8 Stage 8: add higher-level features through part transformations

TTL, recompression, projections, alternate merge semantics, tiering, and replication should reuse the immutable part and atomic replacement protocol. A feature that requires a separate visibility mechanism deserves careful skepticism.

# 16 Design trade-offs to reason about

## 16.1 Sorting-key locality versus ingest cost

A wider or more complex key may improve pruning and compression but costs more during every sort and merge. Only early key prefixes are useful for many range predicates.

## 16.2 Granule size versus read amplification

Small granules improve selective queries but increase primary-index, mark, cache, and scheduling overhead. Wide rows need byte-aware limits, not only row counts.

## 16.3 Insert batch size versus freshness

Larger batches produce fewer, better-compressed parts and amortize sorting and metadata. Smaller batches reduce latency but push work into compaction and may trigger part-count backpressure.

## 16.4 Merge aggressiveness versus write amplification

Aggressive merging reduces read fan-out and part count quickly but repeatedly rewrites young data. Conservative merging saves background I/O but leaves more parts for readers.

## 16.5 Partition isolation versus fragmentation

Partitions make lifecycle operations cheap and bound merge scope. Excessive cardinality fragments data into merge-incompatible islands.

## 16.6 Read-time reconciliation versus write-time materialization

Delete masks, patches, and `FINAL` can make changes visible sooner without immediately rewriting all data. They also complicate reads and index validity. Background materialization moves that cost back to compaction.

## 16.7 Rich part metadata versus metadata overhead

Self-contained parts simplify recovery, replication, and pruning. Too many small parts multiply the cost of opening, caching, checking, and scheduling that metadata. The part count is therefore a first-class health signal.

# 17 Common misconceptions

## 17.1 “The primary key uniquely identifies a row”

It does not. `MergeTree` permits duplicate keys. The primary key is a sparse search structure over sorted data.

## 17.2 “The table is globally sorted”

Each part is sorted. A query may merge ordered streams when global order matters. Background compaction reduces the number of runs but does not imply one permanent file.

## 17.3 “Partitioning is the main performance index”

Partition pruning can remove coarse ranges, but the sorting key and granules drive normal range-read efficiency. Over-partitioning is actively harmful.

## 17.4 “A merge only concatenates files”

A normal merge performs an ordered merge and may apply row semantics, TTL, patches, codecs, indexes, statistics, and projections. Some compatible cases can use cheaper paths, but logical compaction is a rewrite.

## 17.5 “Background merging will eventually fix any ingest pattern”

Only if its sustained capacity exceeds part creation and rewrite demand. The engine needs batching guidance, resource governance, and backpressure.

## 17.6 “An index is always safe if it was correct when written”

Read-time mutations, patches, type conversions, or masking can make old summaries describe different values from those visible to the query. Index validity is version-dependent.

# 18 Mapping the design back to the current source

The following files are useful entry points when validating or extending this mental model:

| Design responsibility | Current source entry point |
| --- | --- |
| Table-level part catalog, metadata, lifecycle, transactions | `src/Storages/MergeTree/MergeTreeData.h` and `MergeTreeData.cpp` |
| Logical part and per-part metadata | `src/Storages/MergeTree/IMergeTreeDataPart.h` |
| Part identity and containment | `src/Storages/MergeTree/MergeTreePartInfo.h` |
| Part state machine | `src/Storages/MergeTree/MergeTreeDataPartState.h` |
| Insert sink and commit orchestration | `src/Storages/MergeTree/MergeTreeSink.cpp` |
| Partition split, sorting, and temporary-part writing | `src/Storages/MergeTree/MergeTreeDataWriter.cpp` |
| Part and mark-range selection | `src/Storages/MergeTree/MergeTreeDataSelectExecutor.cpp` |
| Query-plan read step and index statistics | `src/Processors/QueryPlan/ReadFromMergeTree.h` and `ReadFromMergeTree.cpp` |
| Column readers, read pools, and sources | `src/Storages/MergeTree/IMergeTreeReader.h`, `MergeTreeReadPool*`, and `MergeTreeSource*` |
| Merge selection and mutation construction | `src/Storages/MergeTree/MergeTreeDataMergerMutator.cpp` |
| Eligibility, collection, and merge-selection policies | `src/Storages/MergeTree/Compaction/` |
| Merge execution, including horizontal and vertical algorithms | `src/Storages/MergeTree/MergeTask.cpp` |
| Mutation execution | `src/Storages/MergeTree/MutateTask.cpp` |
| Background scheduling and executor handoff | `src/Storages/MergeTree/BackgroundJobsAssignee.cpp` and `MergeTreeBackgroundExecutor.cpp` |
| Physical part-storage abstraction | `src/Storages/MergeTree/IDataPartStorage.h` and `DataPartStorageOnDisk*` |
| Non-replicated engine orchestration | `src/Storages/StorageMergeTree.cpp` |
| Replication layer and desired-part queue | `src/Storages/StorageReplicatedMergeTree.cpp` and `MergeTree/ReplicatedMergeTreeQueue.h` |

The source has many additional optimizations, but most of them attach to one of five stable seams:

1. build an immutable part;
2. publish or replace parts;
3. prune parts and granules;
4. transform sorted parts in the background;
5. schedule and govern resource use.

# 19 Final takeaway

The deepest idea in `MergeTree` is not the sparse primary index or the merge selector in isolation. It is the decision to make an immutable, sorted, self-describing part the common currency of the whole system.

That one boundary aligns:

- writes with atomic publication;
- reads with snapshot references;
- indexes with immutable bytes;
- compaction with replacement;
- updates with transformation or overlays;
- TTL and recompression with maintenance rewrites;
- tiering and backup with whole-object movement;
- replication with named range operations;
- recovery with checksums and containment metadata.

For a new analytical storage engine, the most useful starting question is therefore not “Which index should I build?” It is:

> What is my immutable publication unit, how is it addressed and validated, and how can every long-term maintenance operation replace it safely?

Once that answer is solid, indexing, compaction policies, caches, projections, and replication have a stable framework in which to evolve.
