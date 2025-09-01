---
title: Lance-Trial
date: 2025-08-27 16:33:28
tags: 
- 原创
categories: 
- Database
- Lakehouse
---

**阅读更多**

<!--more-->

# 1 Rust API

Lance (Low-level API):

* The lance crate provides the low-level API.
* It's a modern columnar data format for ML and LLMs implemented in Rust.
* Focuses on the core data format operations: reading, writing, and managing Lance format files.
* Provides direct access to the underlying storage format with features like:
    * High-performance random access (100x faster than Parquet).
    * Zero-copy operations and automatic versioning.
    * Custom encodings and layouts for fast columnar scans.
    * Direct dataset manipulation and conversion utilities.

LanceDB (High-level API):

* The lancedb crate provides the high-level API.
* It's a vector database built on top of the Lance data format.
* Offers database-level abstractions and operations:
    * Vector similarity search with automatic indexing.
    * Full-text search capabilities.
    * SQL query interface via DataFusion.
    * Table management and schema operations.
    * Embedding management and retrieval workflows.

LanceDB is built on top of Lance and utilizes the underlying optimized storage format to build efficient disk-based indexes that power semantic search & retrieval applications. Lance handles the data format, while LanceDB provides the database functionality and user-friendly APIs for AI/ML applications.

# 2 Rust Demo

## 2.1 Official Demo

[lance/rust/examples](https://github.com/lancedb/lance/tree/main/rust/examples)

```sh
cargo clean
cargo run --example write_read_ds
```

## 2.2 Demo with High/Low Level API

```sh
mkdir -p lance_demo
cd lance_demo

cat > Cargo.toml << 'EOF'
[package]
name = "lance_demo_2"
version = "0.1.0"
edition = "2021"

[dependencies]
lance = "0.33.0"
lancedb = "0.21.3"
arrow = "55.2.0"
arrow-array = "55.2.0"
arrow-schema = "55.2.0"
tokio = { version = "1.0", features = ["full"] }
anyhow = "1.0"
futures = "0.3"
EOF

mkdir -p src
cat > src/main.rs << 'EOF'
use anyhow::Result;

mod high_level_lancedb;
mod low_level_lance;

#[tokio::main]
async fn main() -> Result<()> {
    println!("=== Low-level Lance API Example ===");
    low_level_lance::run_example().await?;

    println!("\n=== High-level LanceDB API Example ===");
    high_level_lancedb::run_example().await?;

    Ok(())
}
EOF

cat > src/low_level_lance.rs << 'EOF'
use anyhow::Result;
use arrow::array::{
    FixedSizeListArray, Float32Array, Int32Array, RecordBatch, RecordBatchIterator,
};
use arrow::datatypes::{DataType, Field, Schema};
use futures::TryStreamExt;
use lance::dataset::{Dataset, WriteParams};
use std::sync::Arc;

pub async fn run_example() -> Result<()> {
    // Define schema for our data
    let schema = Arc::new(Schema::new(vec![
        Field::new("id", DataType::Int32, false),
        Field::new("name", DataType::Utf8, false),
        Field::new(
            "vector",
            DataType::FixedSizeList(
                Arc::new(Field::new("item", DataType::Float32, true)),
                3, // 3-dimensional vectors for simplicity
            ),
            false,
        ),
        Field::new("price", DataType::Float32, false),
    ]));

    // Create sample data
    let batch = create_sample_batch(&schema)?;

    // Write data to Lance dataset
    let dataset_uri = "./data/lance_low_level";
    write_data_to_lance(dataset_uri, batch.clone()).await?;

    // Read data from Lance dataset
    read_data_from_lance(dataset_uri).await?;

    Ok(())
}

fn create_sample_batch(schema: &Schema) -> Result<RecordBatch> {
    // Create sample data
    let ids = Int32Array::from(vec![1, 2, 3, 4, 5]);

    let names =
        arrow::array::StringArray::from(vec!["apple", "banana", "cherry", "date", "elderberry"]);

    // Create 3D vectors
    let vector_data: Vec<Option<Vec<Option<f32>>>> = vec![
        Some(vec![Some(1.0), Some(2.0), Some(3.0)]),
        Some(vec![Some(4.0), Some(5.0), Some(6.0)]),
        Some(vec![Some(7.0), Some(8.0), Some(9.0)]),
        Some(vec![Some(10.0), Some(11.0), Some(12.0)]),
        Some(vec![Some(13.0), Some(14.0), Some(15.0)]),
    ];

    let vectors = FixedSizeListArray::from_iter_primitive::<arrow::datatypes::Float32Type, _, _>(
        vector_data,
        3,
    );

    let prices = Float32Array::from(vec![1.5, 2.0, 3.5, 4.0, 5.5]);

    let batch = RecordBatch::try_new(
        Arc::new(schema.clone()),
        vec![
            Arc::new(ids),
            Arc::new(names),
            Arc::new(vectors),
            Arc::new(prices),
        ],
    )?;

    Ok(batch)
}

async fn write_data_to_lance(uri: &str, batch: RecordBatch) -> Result<()> {
    println!("Writing data to Lance dataset at: {}", uri);

    // Create write parameters
    let write_params = WriteParams::default();

    // Write the dataset
    let batches = vec![batch.clone()];
    let schema = batch.schema();
    let reader = RecordBatchIterator::new(batches.into_iter().map(Ok), schema);

    Dataset::write(Box::new(reader), uri, Some(write_params)).await?;

    println!("✓ Data written successfully to Lance dataset");
    Ok(())
}

async fn read_data_from_lance(uri: &str) -> Result<()> {
    println!("Reading data from Lance dataset at: {}", uri);

    // Open the dataset
    let dataset = Dataset::open(uri).await?;

    println!("Dataset schema: {:?}", dataset.schema());
    println!("Dataset version: {}", dataset.version().version);
    println!("Number of fragments: {}", dataset.get_fragments().len());

    // Scan all data
    let scanner = dataset.scan();
    let stream = scanner.try_into_stream().await?;

    let batches: Vec<RecordBatch> = stream.try_collect().await?;

    println!("\nRead {} batches:", batches.len());
    for (i, batch) in batches.iter().enumerate() {
        println!("Batch {}: {} rows", i, batch.num_rows());

        // Print first few rows
        for row in 0..std::cmp::min(3, batch.num_rows()) {
            let id = batch
                .column(0)
                .as_any()
                .downcast_ref::<Int32Array>()
                .unwrap()
                .value(row);
            let name = batch
                .column(1)
                .as_any()
                .downcast_ref::<arrow::array::StringArray>()
                .unwrap()
                .value(row);
            let price = batch
                .column(3)
                .as_any()
                .downcast_ref::<Float32Array>()
                .unwrap()
                .value(row);

            println!("  Row {}: id={}, name={}, price={}", row, id, name, price);
        }
    }

    // Demonstrate filtering
    println!("\n--- Filtering example (price > 3.0) ---");
    let mut scanner = dataset.scan();
    scanner.filter("price > 3.0")?;
    let filtered_stream = scanner.try_into_stream().await?;
    let filtered_batches: Vec<RecordBatch> = filtered_stream.try_collect().await?;

    for batch in filtered_batches {
        for row in 0..batch.num_rows() {
            let id = batch
                .column(0)
                .as_any()
                .downcast_ref::<Int32Array>()
                .unwrap()
                .value(row);
            let name = batch
                .column(1)
                .as_any()
                .downcast_ref::<arrow::array::StringArray>()
                .unwrap()
                .value(row);
            let price = batch
                .column(3)
                .as_any()
                .downcast_ref::<Float32Array>()
                .unwrap()
                .value(row);

            println!("  Filtered row: id={}, name={}, price={}", id, name, price);
        }
    }

    Ok(())
}
EOF

cat > src/high_level_lancedb.rs << 'EOF'
use anyhow::Result;
use arrow::array::{FixedSizeListArray, Float32Array, Int32Array, RecordBatch};
use arrow::datatypes::{DataType, Field, Schema};
use arrow::record_batch::RecordBatchIterator;
use futures::TryStreamExt;
use lancedb::query::{ExecutableQuery, QueryBase};
use lancedb::{connect, Connection};
use std::sync::Arc;

pub async fn run_example() -> Result<()> {
    // Connect to LanceDB
    let db = connect("./data/lancedb_high_level").execute().await?;

    // Create and populate a table
    create_and_populate_table(&db).await?;

    // Query the table
    query_table(&db).await?;

    // Demonstrate vector search
    vector_search_example(&db).await?;

    Ok(())
}

async fn create_and_populate_table(db: &Connection) -> Result<()> {
    println!("Creating table and inserting data...");

    // Define schema
    let schema = Arc::new(Schema::new(vec![
        Field::new("id", DataType::Int32, false),
        Field::new("item", DataType::Utf8, false),
        Field::new(
            "vector",
            DataType::FixedSizeList(
                Arc::new(Field::new("item", DataType::Float32, true)),
                4, // 4-dimensional vectors
            ),
            false,
        ),
        Field::new("price", DataType::Float32, false),
        Field::new("category", DataType::Utf8, false),
    ]));

    // Create sample data
    let batch = create_sample_data(&schema)?;

    // Create table with data
    let reader = RecordBatchIterator::new(vec![Ok(batch)].into_iter(), schema.clone());
    let table = db
        .create_table("products", Box::new(reader))
        .execute()
        .await?;

    println!("✓ Table 'products' created with sample data");

    // Add more data to demonstrate append
    let additional_batch = create_additional_data(&schema)?;
    let add_reader =
        RecordBatchIterator::new(vec![Ok(additional_batch)].into_iter(), schema.clone());
    table.add(Box::new(add_reader)).execute().await?;

    println!("✓ Additional data appended to table");

    Ok(())
}

fn create_sample_data(schema: &Schema) -> Result<RecordBatch> {
    let ids = Int32Array::from(vec![1, 2, 3, 4, 5]);

    let items = arrow::array::StringArray::from(vec![
        "laptop",
        "mouse",
        "keyboard",
        "monitor",
        "headphones",
    ]);

    // Create 4D vectors for products
    let vector_data: Vec<Option<Vec<Option<f32>>>> = vec![
        Some(vec![Some(0.1), Some(0.2), Some(0.3), Some(0.4)]),
        Some(vec![Some(0.5), Some(0.6), Some(0.7), Some(0.8)]),
        Some(vec![Some(0.9), Some(1.0), Some(1.1), Some(1.2)]),
        Some(vec![Some(1.3), Some(1.4), Some(1.5), Some(1.6)]),
        Some(vec![Some(1.7), Some(1.8), Some(1.9), Some(2.0)]),
    ];

    let vectors = FixedSizeListArray::from_iter_primitive::<arrow::datatypes::Float32Type, _, _>(
        vector_data,
        4,
    );

    let prices = Float32Array::from(vec![999.99, 29.99, 79.99, 299.99, 149.99]);

    let categories = arrow::array::StringArray::from(vec![
        "electronics",
        "accessories",
        "accessories",
        "electronics",
        "accessories",
    ]);

    let batch = RecordBatch::try_new(
        Arc::new(schema.clone()),
        vec![
            Arc::new(ids),
            Arc::new(items),
            Arc::new(vectors),
            Arc::new(prices),
            Arc::new(categories),
        ],
    )?;

    Ok(batch)
}

fn create_additional_data(schema: &Schema) -> Result<RecordBatch> {
    let ids = Int32Array::from(vec![6, 7, 8]);

    let items = arrow::array::StringArray::from(vec!["tablet", "smartphone", "smartwatch"]);

    let vector_data: Vec<Option<Vec<Option<f32>>>> = vec![
        Some(vec![Some(2.1), Some(2.2), Some(2.3), Some(2.4)]),
        Some(vec![Some(2.5), Some(2.6), Some(2.7), Some(2.8)]),
        Some(vec![Some(2.9), Some(3.0), Some(3.1), Some(3.2)]),
    ];

    let vectors = FixedSizeListArray::from_iter_primitive::<arrow::datatypes::Float32Type, _, _>(
        vector_data,
        4,
    );

    let prices = Float32Array::from(vec![599.99, 799.99, 399.99]);

    let categories =
        arrow::array::StringArray::from(vec!["electronics", "electronics", "electronics"]);

    let batch = RecordBatch::try_new(
        Arc::new(schema.clone()),
        vec![
            Arc::new(ids),
            Arc::new(items),
            Arc::new(vectors),
            Arc::new(prices),
            Arc::new(categories),
        ],
    )?;

    Ok(batch)
}

async fn query_table(db: &Connection) -> Result<()> {
    println!("\n--- Querying table ---");

    let table = db.open_table("products").execute().await?;

    // Basic query - get all records
    println!("\nAll products:");
    let results = table
        .query()
        .execute()
        .await?
        .try_collect::<Vec<_>>()
        .await?;

    for batch in &results {
        print_batch_data(batch, "All products");
    }

    // Filtered query
    println!("\nProducts with price > 200:");
    let filtered_results = table
        .query()
        .only_if("price > 200")
        .execute()
        .await?
        .try_collect::<Vec<_>>()
        .await?;

    for batch in &filtered_results {
        print_batch_data(batch, "Expensive products");
    }

    // Limited query
    println!("\nFirst 3 products:");
    let limited_results = table
        .query()
        .limit(3)
        .execute()
        .await?
        .try_collect::<Vec<_>>()
        .await?;

    for batch in &limited_results {
        print_batch_data(batch, "First 3 products");
    }

    Ok(())
}

async fn vector_search_example(db: &Connection) -> Result<()> {
    println!("\n--- Vector Search Example ---");

    let table = db.open_table("products").execute().await?;

    // Search for similar vectors
    let query_vector = vec![1.0, 1.1, 1.2, 1.3];

    println!(
        "Searching for products similar to vector {:?}",
        query_vector
    );

    let search_results = table
        .query()
        .nearest_to(query_vector)?
        .limit(3)
        .execute()
        .await?
        .try_collect::<Vec<_>>()
        .await?;

    for batch in &search_results {
        print_batch_data(batch, "Similar products");
    }

    Ok(())
}

fn print_batch_data(batch: &RecordBatch, title: &str) {
    println!("\n{} ({} rows):", title, batch.num_rows());

    for row in 0..batch.num_rows() {
        let id = batch
            .column(0)
            .as_any()
            .downcast_ref::<Int32Array>()
            .unwrap()
            .value(row);
        let item = batch
            .column(1)
            .as_any()
            .downcast_ref::<arrow::array::StringArray>()
            .unwrap()
            .value(row);
        let price = batch
            .column(3)
            .as_any()
            .downcast_ref::<Float32Array>()
            .unwrap()
            .value(row);
        let category = batch
            .column(4)
            .as_any()
            .downcast_ref::<arrow::array::StringArray>()
            .unwrap()
            .value(row);

        // Extract vector values
        let vector_array = batch
            .column(2)
            .as_any()
            .downcast_ref::<FixedSizeListArray>()
            .unwrap();
        let vector_values = vector_array.value(row);
        let float_array = vector_values
            .as_any()
            .downcast_ref::<Float32Array>()
            .unwrap();
        let vector: Vec<f32> = (0..float_array.len())
            .map(|i| float_array.value(i))
            .collect();

        println!(
            "  ID: {}, Item: {}, Price: ${:.2}, Category: {}, Vector: {:?}",
            id, item, price, category, vector
        );
    }
}
EOF

cargo run
```

## 2.3 Demo with rust-ffi

[lance_rust_ffi_demo](https://github.com/liuyehcf/cpp-demo-projects/tree/main/lance/lance_rust_ffi_demo)

