---
title: DBMS-DataFormat-Orc
date: 2025-05-16 15:51:05
mathjax: true
tags: 
- 摘录
categories: 
- Database
- Data Format
---

**阅读更多**

<!--more-->

# 1 Java SDK Demo

```java
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.LocalFileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.orc.*;
import org.apache.orc.storage.ql.exec.vector.BytesColumnVector;
import org.apache.orc.storage.ql.exec.vector.LongColumnVector;
import org.apache.orc.storage.ql.exec.vector.VectorizedRowBatch;

import java.io.IOException;

public class OrcDemo {
    private static final Path path = new Path("/tmp/user.orc");
    private static final Configuration conf = new Configuration();
    private static final LocalFileSystem local;

    static {
        try {
            local = FileSystem.getLocal(conf);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public static void main(String[] args) throws IOException {
        write();
        read();
    }

    private static void write() throws IOException {
        TypeDescription schema =
                TypeDescription.fromString("struct<id:bigint,name:string,age:int>");

        if (local.exists(path)) {
            local.delete(path, false);
        }

        try (Writer writer = OrcFile.createWriter(path,
                OrcFile.writerOptions(conf).setSchema(schema).fileSystem(local))) {

            VectorizedRowBatch batch = schema.createRowBatch();
            LongColumnVector idCol = (LongColumnVector) batch.cols[0];
            BytesColumnVector nameCol = (BytesColumnVector) batch.cols[1];
            LongColumnVector ageCol = (LongColumnVector) batch.cols[2];

            for (int i = 0; i < 5; i++) {
                int row = batch.size++;
                idCol.vector[row] = i + 1;
                String name = "User" + (i + 1);
                byte[] nameBytes = name.getBytes();
                nameCol.setVal(row, nameBytes);
                ageCol.vector[row] = 20 + i;

                if (batch.size == batch.getMaxSize()) {
                    writer.addRowBatch(batch);
                    batch.reset();
                }
            }

            if (batch.size > 0) {
                writer.addRowBatch(batch);
            }

            System.out.println("Write Successfully");
        }
    }

    private static void read() throws IOException {
        try (Reader reader =
                OrcFile.createReader(path, OrcFile.readerOptions(conf).filesystem(local));
                RecordReader rows = reader.rows()) {

            TypeDescription schema = reader.getSchema();
            VectorizedRowBatch batch = schema.createRowBatch();

            while (rows.nextBatch(batch)) {
                LongColumnVector idCol = (LongColumnVector) batch.cols[0];
                BytesColumnVector nameCol = (BytesColumnVector) batch.cols[1];
                LongColumnVector ageCol = (LongColumnVector) batch.cols[2];

                for (int r = 0; r < batch.size; ++r) {
                    long id = idCol.vector[r];
                    String name = nameCol.toString(r);
                    int age = (int) ageCol.vector[r];

                    System.out.printf("User{id=%d, name='%s', age=%d}%n", id, name, age);
                }
            }
        }
    }
}
```

# 2 Tools

## 2.1 Parquet ORC Utils

```py
import argparse
import os

import pandas as pd
import pyarrow as pa
import pyarrow.orc as orc

def parse_arguments():
    parser = argparse.ArgumentParser(description="ORC reader using pyarrow")
    parser.add_argument("-f", "--file", required=True, help="Path to ORC file")
    parser.add_argument(
        "--show",
        nargs="?",
        const="0,10",
        default=None,
        type=str,
        help="Show ORC data rows. Format: start_row[,num_rows], e.g. --show 5,30"
    )
    parser.add_argument("--summary", action="store_true", help="Print summary statistics")
    return parser.parse_args()

def show_rows(table: pa.Table, show_arg):
    try:
        parts = show_arg.split(",")
        start = int(parts[0])
        if len(parts) > 1:
            length = int(parts[1])
        else:
            length = 10
    except Exception:
        print(f"Invalid --show argument format: '{show_arg}'. Expected format: start[,length]")
        return

    if start < 0:
        print(f"Start row must be >= 0 (got {start})")
        return

    if start > table.num_rows:
        print(f"Start row {start} out of bounds (max {table.num_rows})")
        return

    length = min(length, table.num_rows - start)
    if length <= 0:
        print("No rows to display.")
        return

    preview = table.slice(start, length)
    df = preview.to_pandas()
    df.index = range(start, start + length)
    print(df)

def summarize(table: pa.Table, file_path: str):
    print("Summary:")
    print(f"- File: {file_path}")
    print(f"- Total rows: {table.num_rows}")
    print(f"- Total columns: {table.num_columns}")
    print(f"- Column names: {table.column_names}")

    print("- Column types:")
    for name, col in zip(table.column_names, table.columns):
        print(f"  - {name}: {col.type}")

    print("- Null value counts:")
    for name in table.column_names:
        col = table[name]
        null_count = col.null_count
        print(f"  - {name}: {null_count} nulls")

    print(f"- File size: {os.path.getsize(file_path)} bytes")

    print("- Stripes:")
    with open(file_path, "rb") as f:
        reader = orc.ORCFile(f)
        n = reader.nstripes
        print(f"  - Total stripes: {n}")
        prev_end = 0
        for i in range(n):
            stripe = reader.read_stripe(i)
            print(f"    - Stripe {i}: {stripe.num_rows} rows, range: [{prev_end}, {prev_end + stripe.num_rows})")
            prev_end += stripe.num_rows

if __name__ == "__main__":
    args = parse_arguments()

    pd.set_option("display.max_rows", None)
    pd.set_option("display.max_columns", None)
    pd.set_option("display.width", None)
    pd.set_option("display.max_colwidth", None)

    with open(args.file, "rb") as f:
        reader = orc.ORCFile(f)
        table = reader.read()

        if args.show:
            show_rows(table, args.show)

        if args.summary:
            summarize(table, args.file)
```

# 3 Tips

## 3.1 Java Dependency classifier

Orc's java dependency has two difference versions, one use hive's class, another don't. Which means the same mechod will have different signature, and these two versions cannot work together. Otherwise you may get following error message:

```
java.lang.NoSuchMethodError: org.apache.orc.TypeDescription.createRowBatch(I)Lorg/apache/hadoop/hive/ql/exec/vector/VectorizedRowBatch;
```

With hive:

* `org.apache.orc.TypeDescription.createRowBatch(I)Lorg/apache/hadoop/hive/ql/exec/vector/VectorizedRowBatch;`

```xml
<dependency>
    <groupId>org.apache.orc</groupId>
    <artifactId>orc-core</artifactId>
    <version>1.9.4</version>
</dependency>
```

Without hive:

* `org.apache.orc.TypeDescription.createRowBatch(I)Lorg/apache/orc/storage/ql/exec/vector/VectorizedRowBatch;`

```xml
<dependency>
    <groupId>org.apache.orc</groupId>
    <artifactId>orc-core</artifactId>
    <classifier>nohive</classifier>
    <version>1.9.4</version>
</dependency>
```

