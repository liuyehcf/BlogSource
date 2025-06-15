---
title: DBMS-DataFormat-Parquet
date: 2024-03-22 08:33:17
mathjax: true
tags: 
- 摘录
categories: 
- Database
- Data Format
---

**阅读更多**

<!--more-->

# 1 Format

![FileLayout](/images/DBMS-Format-Parquet/FileLayout.gif)

![file-format-overview](/images/DBMS-Format-Parquet/file-format-overview.jpeg)

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃┏━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━┓          ┃
┃┃┌ ─ ─ ─ ─ ─ ─ ┌ ─ ─ ─ ─ ─ ─ ┐┌ ─ ─ ─ ─ ─ ─  ┃          ┃
┃┃             │                            │ ┃          ┃
┃┃│             │             ││              ┃          ┃
┃┃             │                            │ ┃          ┃
┃┃│             │             ││              ┃ RowGroup ┃
┃┃             │                            │ ┃     1    ┃
┃┃│             │             ││              ┃          ┃
┃┃             │                            │ ┃          ┃
┃┃└ ─ ─ ─ ─ ─ ─ └ ─ ─ ─ ─ ─ ─ ┘└ ─ ─ ─ ─ ─ ─  ┃          ┃
┃┃ColumnChunk 1  ColumnChunk 2 ColumnChunk 3  ┃          ┃
┃┃ (Column "A")   (Column "B")  (Column "C")  ┃          ┃
┃┗━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━┛          ┃
┃┏━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━┓          ┃
┃┃┌ ─ ─ ─ ─ ─ ─ ┌ ─ ─ ─ ─ ─ ─ ┐┌ ─ ─ ─ ─ ─ ─  ┃          ┃
┃┃             │                            │ ┃          ┃
┃┃│             │             ││              ┃          ┃
┃┃             │                            │ ┃          ┃
┃┃│             │             ││              ┃ RowGroup ┃
┃┃             │                            │ ┃     2    ┃
┃┃│             │             ││              ┃          ┃
┃┃             │                            │ ┃          ┃
┃┃└ ─ ─ ─ ─ ─ ─ └ ─ ─ ─ ─ ─ ─ ┘└ ─ ─ ─ ─ ─ ─  ┃          ┃
┃┃ColumnChunk 4  ColumnChunk 5 ColumnChunk 6  ┃          ┃
┃┃ (Column "A")   (Column "B")  (Column "C")  ┃          ┃
┃┗━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━┛          ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃
┃ Data Page for ColumnChunk 1 ("A")             ◀─┃─ ─ ─│
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃     │
┃ Data Page for ColumnChunk 1 ("A")               ┃
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃     │
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃
┃ Data Page for ColumnChunk 2 ("B")               ┃     │
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃     │
┃ Data Page for ColumnChunk 3 ("C")               ┃
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃     │
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃
┃ Data Page for ColumnChunk 3 ("C")               ┃     │
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃     │
┃ Data Page for ColumnChunk 3 ("C")               ┃
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃     │
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃
┃ Data Page for ColumnChunk 4 ("A")             ◀─┃─ ─ ─│─ ┐
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃     │  │
┃ Data Page for ColumnChunk 5 ("B")               ┃
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃     │  │
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃
┃ Data Page for ColumnChunk 5 ("B")               ┃     │  │
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃     │  │
┃ Data Page for ColumnChunk 5 ("B")               ┃
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃     │  │
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃
┃ Data Page for ColumnChunk 6 ("C")               ┃     │  │
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃
┃┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ ┃     │  │
┃┃Footer                                        ┃ ┃
┃┃ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ ┃ ┃     │  │
┃┃ ┃File Metadata                             ┃ ┃ ┃
┃┃ ┃ Schema, etc                              ┃ ┃ ┃     │  │
┃┃ ┃ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓     ┃ ┃ ┃
┃┃ ┃ ┃Row Group 1 Metadata              ┃     ┃ ┃ ┃     │  │
┃┃ ┃ ┃┏━━━━━━━━━━━━━━━━━━━┓             ┃     ┃ ┃ ┃
┃┃ ┃ ┃┃Column "A" Metadata┃ Location of ┃     ┃ ┃ ┃     │  │
┃┃ ┃ ┃┗━━━━━━━━━━━━━━━━━━━┛ first Data  ┣ ─ ─ ╋ ╋ ╋ ─ ─
┃┃ ┃ ┃┏━━━━━━━━━━━━━━━━━━━┓ Page, row   ┃     ┃ ┃ ┃        │
┃┃ ┃ ┃┃Column "B" Metadata┃ counts,     ┃     ┃ ┃ ┃
┃┃ ┃ ┃┗━━━━━━━━━━━━━━━━━━━┛ sizes,      ┃     ┃ ┃ ┃        │
┃┃ ┃ ┃┏━━━━━━━━━━━━━━━━━━━┓ min/max     ┃     ┃ ┃ ┃
┃┃ ┃ ┃┃Column "C" Metadata┃ values, etc ┃     ┃ ┃ ┃        │
┃┃ ┃ ┃┗━━━━━━━━━━━━━━━━━━━┛             ┃     ┃ ┃ ┃
┃┃ ┃ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛     ┃ ┃ ┃        │
┃┃ ┃ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓     ┃ ┃ ┃
┃┃ ┃ ┃Row Group 2 Metadata              ┃     ┃ ┃ ┃        │
┃┃ ┃ ┃┏━━━━━━━━━━━━━━━━━━━┓ Location of ┃     ┃ ┃ ┃
┃┃ ┃ ┃┃Column "A" Metadata┃ first Data  ┃     ┃ ┃ ┃        │
┃┃ ┃ ┃┗━━━━━━━━━━━━━━━━━━━┛ Page, row   ┣ ─ ─ ╋ ╋ ╋ ─ ─ ─ ─
┃┃ ┃ ┃┏━━━━━━━━━━━━━━━━━━━┓ counts,     ┃     ┃ ┃ ┃
┃┃ ┃ ┃┃Column "B" Metadata┃ sizes,      ┃     ┃ ┃ ┃
┃┃ ┃ ┃┗━━━━━━━━━━━━━━━━━━━┛ min/max     ┃     ┃ ┃ ┃
┃┃ ┃ ┃┏━━━━━━━━━━━━━━━━━━━┓ values, etc ┃     ┃ ┃ ┃
┃┃ ┃ ┃┃Column "C" Metadata┃             ┃     ┃ ┃ ┃
┃┃ ┃ ┃┗━━━━━━━━━━━━━━━━━━━┛             ┃     ┃ ┃ ┃
┃┃ ┃ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛     ┃ ┃ ┃
┃┃ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ ┃ ┃
┃┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

## 1.1 Thrift Definition

[parquet thrift definition](https://github.com/apache/parquet-format/blob/master/src/main/thrift/parquet.thrift)

## 1.2 Nested Encoding

**Repetition Levels**: It tells us at what repeated field in the field's path the value has repeated

**Definition Levels**: It specifies how many fields in the field's path that could be undefined (because they are optional or repeated) are actually present in the record

See the following image from [Dremel: Interactive Analysis of Web-Scale Datasets](/resources/paper/Dremel-Interactive-Analysis-of-Web-Scale-Datasets.pdf)

![nested_encoding.jpeg](/images/DBMS-Format-Parquet/nested_encoding.jpeg)

**Field Definition**

* `DocId`:
    * Max Repetition level: `0` (`DocId` is not repeated)
    * Max Definition level: `0` (`DocId` is required)
* `Links.Forward`/`Links.Backward`:
    * Max Repetition level: `1` (`Links` is not repeated, `Forward`/`Backward` is repeated)
        * ordinal of `Forward`/`Backward` is `1`
    * Max Definition level: `2` (Both `Links` and `Forward`/`Backward` can be undefined)
* `Name.URL`:
    * Max Repetition level: `1` (`Name` is repeated, `URL` is not repeated)
        * ordinal of `Name` is `1`
    * Max Definition level: `2` (Both `Name` and `URL` can be undefined)
* `Name.Language.Code`:
    * Max Repetition level: `2` (Both `Name` and `Language` are repeated, `Code` is not repeated)
        * ordinal of `Name` is `1`
        * ordinal of `Language` is `2`
    * Max Definition level: `2` (Both `Name` and `Language` can be undefined, `Code` is required)
* `Name.Language.Country`:
    * Max Repetition level: `2` (Both `Name` and `Language` are repeated, `Country` is not repeated)
        * ordinal of `Name` is `1`
        * ordinal of `Language` is `2`
    * Max Definition level: `3` (Both `Name` and `Language` and `Country` can be undefined)

**Field Actual Values**

* `Links.Forward`
    * `20`: Both `Links` and `Forward` are not yet repeated, and both undefinable `Links` and `Forward` are present, so `(0, 2)`
    * `40`: `Forward` (ordinal is `1`) is lately repeated, and both undefinable `Links` and `Forward` are present, so `(1, 2)`
    * `60`: `Forward` (ordinal is `1`) is lately repeated, and both undefinable `Links` and `Forward` are present, so `(1, 2)`
    * `80`: Both `Links` and `Forward` are not yet repeated, and both undefinable `Links` and `Forward` are present, so `(0, 2)`
* `Links.Backward`
    * `NULL`: Both `Links` and `Backward` are not yet repeated, and only undefinable `Links` is present, so `(0, 1)`
    * `10`: Both `Links` and `Backward` are not yet repeated, and both undefinable `Links` and `Backward` are present, so `(0, 2)`
    * `30`: `Backward` (ordinal is `1`) is lately repeated, and both undefinable `Links` and `Backward` are present, so `(1, 2)`
* `Name.URL`
    * `http://A`: Both `Name` and `URL` are not yet repeated, and both undefinable `Name` and `URL` are present, so `(0, 2)`
    * `http://B`: `Name` (ordinal is `1`) is lately repeated, and both undefinable `Name` and `URL` are present, so `(1, 2)`
    * `NULL`: `Name` (ordinal is `1`) is lately repeated, and only undefinable `Name` is present, so `(1, 1)`
    * `http://C`: Both `Name` and `URL` are not yet repeated, and both undefinable `Name` and `URL` are present, so `(0, 2)`
* `Name.Language.Code`
    * `en-us`: Both `Name` and `Language` are not yet repeated, and both undefinable `Name` and `Language` are present, so `(0, 2)`
    * `en`: `Language` (ordinal is `2`) is lately repeated, and both undefinable `Name` and `Language` are present, so `(2, 2)`
    * `NULL`: `Name` (ordinal is `1`) is lately repeated, and only undefinable `Name` is present, so `(1, 1)`
    * `en-gb`: `Name` (ordinal is `1`) is lately repeated, and both undefinable `Name` and `Language` are present, so `(1, 2)`
    * `NULL`: Both `Name` and `Language` are not yet repeated, and only undefinable `Name` is present, so `(0, 1)`
* `Name.Language.Country`
    * `us`: Both `Name` and `Language` are not yet repeated, and both undefinable `Name` and `Language` and `Country` are present, so `(0, 3)`
    * `NULL`: `Language` (ordinal is `2`) is lately repeated, and only undefinable `Name` and `Language` are present, so `(2, 2)`
    * `NULL`: `Name` (ordinal is `1`) is lately repeated, and only undefinable `Name` is present, so `(1, 1)`
    * `gb`: `Name` (ordinal is `1`) is lately repeated, and both undefinable `Name` and `Language` and `Country` are present, so `(1, 3)`
    * `NULL`: Both `Name` and `Language` are not yet repeated, and only undefinable `Name` is present, so `(0, 1)`

### 1.2.1 Arrow Source Code

```cpp
#include <arrow/api.h>
#include <arrow/array.h>
#include <arrow/io/api.h>
#include <arrow/memory_pool.h>
#include <arrow/pretty_print.h>
#include <arrow/result.h>
#include <arrow/status.h>
#include <arrow/type_fwd.h>
#include <parquet/arrow/reader.h>
#include <parquet/arrow/writer.h>
#include <parquet/exception.h>

#include <filesystem>
#include <iostream>

arrow::Status execute() {
    arrow::MemoryPool* pool = arrow::default_memory_pool();

    // Define types
    const auto column_type1 = arrow::int64();
    const auto column_type2 = arrow::float64();
    const auto column_type3 = arrow::utf8();

    const auto doc_id_type = arrow::int64();

    const auto backward_type = arrow::int64();
    const auto backward_list_type = arrow::list(backward_type);
    const auto forward_type = arrow::int64();
    const auto forward_list_type = arrow::list(forward_type);
    const auto links_type = arrow::struct_(
            {arrow::field("Backward", backward_list_type, false), arrow::field("Fordward", forward_list_type, false)});

    const auto code_type = arrow::utf8();
    const auto country_type = arrow::utf8();
    const auto language_type =
            arrow::struct_({arrow::field("Code", code_type, false), arrow::field("Country", country_type, true)});
    const auto language_list_type = arrow::list(language_type);
    const auto url_type = arrow::utf8();
    const auto name_type =
            arrow::struct_({arrow::field("Language", language_list_type, false), arrow::field("Url", url_type, true)});
    const auto name_list_type = arrow::list(name_type);

    const auto document_type =
            arrow::struct_({arrow::field("DocId", doc_id_type, false), arrow::field("Links", links_type, true),
                            arrow::field("Name", name_list_type, false)});

    const auto schema = std::make_shared<arrow::Schema>(std::vector<std::shared_ptr<arrow::Field>>{
            arrow::field("Column1", column_type1, true), arrow::field("Column2", column_type2, false),
            arrow::field("Column3", column_type3, true), arrow::field("Document", document_type, false)});

    // Create Builders
    auto column_builder1 = std::make_shared<arrow::Int64Builder>(pool);
    auto column_builder2 = std::make_shared<arrow::DoubleBuilder>(pool);
    auto column_builder3 = std::make_shared<arrow::StringBuilder>(pool);

    auto doc_id_builder = std::make_shared<arrow::Int64Builder>(pool);
    auto backward_builder = std::make_shared<arrow::Int64Builder>(pool);
    auto backward_list_builder = std::make_shared<arrow::ListBuilder>(pool, backward_builder);
    auto forward_builder = std::make_shared<arrow::Int64Builder>(pool);
    auto forward_list_builder = std::make_shared<arrow::ListBuilder>(pool, forward_builder);
    std::vector<std::shared_ptr<arrow::ArrayBuilder>> vec;
    auto links_builder = std::make_shared<arrow::StructBuilder>(
            links_type, pool,
            std::vector<std::shared_ptr<arrow::ArrayBuilder>>{backward_list_builder, forward_list_builder});
    auto code_builder = std::make_shared<arrow::StringBuilder>(pool);
    auto country_builder = std::make_shared<arrow::StringBuilder>(pool);
    auto language_builder = std::make_shared<arrow::StructBuilder>(
            language_type, pool, std::vector<std::shared_ptr<arrow::ArrayBuilder>>{code_builder, country_builder});
    auto language_list_builder = std::make_shared<arrow::ListBuilder>(pool, language_builder);
    auto url_builder = std::make_shared<arrow::StringBuilder>(pool);
    auto name_builder = std::make_shared<arrow::StructBuilder>(
            name_type, pool, std::vector<std::shared_ptr<arrow::ArrayBuilder>>{language_list_builder, url_builder});
    auto name_list_builder = std::make_shared<arrow::ListBuilder>(pool, name_builder);
    auto document_builder = std::make_shared<arrow::StructBuilder>(
            document_type, pool,
            std::vector<std::shared_ptr<arrow::ArrayBuilder>>{doc_id_builder, links_builder, name_list_builder});

    ARROW_RETURN_NOT_OK(column_builder1->Append(1));
    ARROW_RETURN_NOT_OK(column_builder1->AppendNull());
    ARROW_RETURN_NOT_OK(column_builder2->Append(1.1));
    ARROW_RETURN_NOT_OK(column_builder2->Append(2.2));
    ARROW_RETURN_NOT_OK(column_builder3->AppendNull());
    ARROW_RETURN_NOT_OK(column_builder3->Append("hello world"));

    // DocId: 10
    {
        ARROW_RETURN_NOT_OK(document_builder->Append());
        // Append data to DocId
        ARROW_RETURN_NOT_OK(doc_id_builder->Append(10));
        // Append data to Links
        ARROW_RETURN_NOT_OK(links_builder->Append());
        ARROW_RETURN_NOT_OK(backward_list_builder->AppendNull());
        ARROW_RETURN_NOT_OK(forward_list_builder->Append());
        ARROW_RETURN_NOT_OK(forward_builder->Append(20));
        ARROW_RETURN_NOT_OK(forward_builder->Append(40));
        ARROW_RETURN_NOT_OK(forward_builder->Append(60));

        // Append data to Name1
        ARROW_RETURN_NOT_OK(name_list_builder->Append());
        ARROW_RETURN_NOT_OK(name_builder->Append());
        ARROW_RETURN_NOT_OK(language_list_builder->Append());
        ARROW_RETURN_NOT_OK(language_builder->Append());
        ARROW_RETURN_NOT_OK(code_builder->Append("en-us"));
        ARROW_RETURN_NOT_OK(country_builder->Append("us"));
        ARROW_RETURN_NOT_OK(language_builder->Append());
        ARROW_RETURN_NOT_OK(code_builder->Append("en"));
        ARROW_RETURN_NOT_OK(country_builder->AppendNull());
        ARROW_RETURN_NOT_OK(url_builder->Append("http://A"));
        // Append data to Name2
        ARROW_RETURN_NOT_OK(name_builder->Append());
        ARROW_RETURN_NOT_OK(language_list_builder->AppendNull());
        ARROW_RETURN_NOT_OK(url_builder->Append("http://B"));
        // Append data to Name3
        ARROW_RETURN_NOT_OK(name_builder->Append());
        ARROW_RETURN_NOT_OK(language_list_builder->Append());
        ARROW_RETURN_NOT_OK(language_builder->Append());
        ARROW_RETURN_NOT_OK(code_builder->Append("en-gb"));
        ARROW_RETURN_NOT_OK(country_builder->Append("gb"));
        ARROW_RETURN_NOT_OK(url_builder->AppendNull());
    }

    // DocId: 20
    {
        ARROW_RETURN_NOT_OK(document_builder->Append());
        // Append data to DocId
        ARROW_RETURN_NOT_OK(doc_id_builder->Append(20));
        // Append data to Links
        ARROW_RETURN_NOT_OK(links_builder->Append());
        ARROW_RETURN_NOT_OK(backward_list_builder->Append());
        ARROW_RETURN_NOT_OK(backward_builder->Append(10));
        ARROW_RETURN_NOT_OK(backward_builder->Append(30));
        ARROW_RETURN_NOT_OK(forward_list_builder->Append());
        ARROW_RETURN_NOT_OK(forward_builder->Append(80));

        ARROW_RETURN_NOT_OK(name_list_builder->Append());
        ARROW_RETURN_NOT_OK(name_builder->Append());
        // Append data to Name1
        ARROW_RETURN_NOT_OK(language_list_builder->AppendNull());
        ARROW_RETURN_NOT_OK(url_builder->Append("http://C"));
    }

    std::shared_ptr<arrow::Array> column1_array;
    ARROW_RETURN_NOT_OK(column_builder1->Finish(&column1_array));
    std::shared_ptr<arrow::Array> column2_array;
    ARROW_RETURN_NOT_OK(column_builder2->Finish(&column2_array));
    std::shared_ptr<arrow::Array> column3_array;
    ARROW_RETURN_NOT_OK(column_builder3->Finish(&column3_array));
    std::shared_ptr<arrow::Array> document_array;
    ARROW_RETURN_NOT_OK(document_builder->Finish(&document_array));

    // Create Table
    auto table = arrow::Table::Make(schema, {column1_array, column2_array, column3_array, document_array});

    // Write the table to a Parquet file
    const std::string file_path = "data.parquet";
    std::shared_ptr<arrow::io::FileOutputStream> outfile;
    ARROW_RETURN_NOT_OK(arrow::io::FileOutputStream::Open(file_path).Value(&outfile));
    ARROW_RETURN_NOT_OK(parquet::arrow::WriteTable(*table, arrow::default_memory_pool(), outfile, 10));

    // Read the Parquet file back into a table
    std::shared_ptr<arrow::io::ReadableFile> infile;
    ARROW_RETURN_NOT_OK(arrow::io::ReadableFile::Open(file_path, arrow::default_memory_pool()).Value(&infile));

    std::unique_ptr<parquet::arrow::FileReader> reader;
    ARROW_RETURN_NOT_OK(parquet::arrow::OpenFile(infile, arrow::default_memory_pool(), &reader));

    std::shared_ptr<arrow::Table> read_table;
    ARROW_RETURN_NOT_OK(reader->ReadTable(&read_table));

    // Print the table to std::cout
    std::stringstream ss;
    ARROW_RETURN_NOT_OK(arrow::PrettyPrint(*read_table.get(), {}, &ss));
    std::cout << ss.str() << std::endl;

    return arrow::Status::OK();
}

int main() {
    auto status = execute();
    if (!status.ok()) {
        std::cout << status.message() << std::endl;
    }
    return 0;
}
```

```sh
mkdir -p build
gcc -o build/arrow_parquet_demo arrow_parquet_demo.cpp -lstdc++ -std=gnu++17 -larrow -lparquet
build/arrow_parquet_demo
```

### 1.2.2 Native Reader

Get parquet thrift definition from [parquet.thrift](https://github.com/apache/parquet-format/blob/master/src/main/thrift/parquet.thrift) and then generate cpp file:

```sh
wget https://raw.githubusercontent.com/apache/parquet-format/master/src/main/thrift/parquet.thrift
thrift --gen cpp parquet.thrift
```

```cpp
#define BOOST_STACKTRACE_USE_BACKTRACE
#include <arrow/buffer.h>
#include <arrow/io/api.h>
#include <arrow/result.h>
#include <arrow/status.h>
#include <arrow/util/macros.h>
#include <arrow/util/rle_encoding.h>
#include <thrift/TApplicationException.h>
#include <thrift/protocol/TBinaryProtocol.h>
#include <thrift/protocol/TCompactProtocol.h>
#include <thrift/protocol/TDebugProtocol.h>
#include <thrift/protocol/TJSONProtocol.h>
#include <thrift/transport/TBufferTransports.h>

#include <boost/stacktrace.hpp>
#include <iostream>
#include <sstream>
#include <string>

#include "gen-cpp/parquet_types.h"

static constexpr size_t kDefaultPageHeaderSize = 16 * 1024;
static constexpr size_t kMaxPageHeaderSize = 16 * 1024 * 1024;

#define ASSERT_TRUE(expr)                                                                   \
    if (!(expr)) {                                                                          \
        std::stringstream ss;                                                               \
        ss << "Assertion '" << #expr << "' failed (" << __FILE__ << ":" << __LINE__ << ")"; \
        return arrow::Status::ExecutionError(ss.str());                                     \
    }

class ParquetNativeReader {
public:
    ParquetNativeReader(const std::string& path) {
        auto status = arrow::io::ReadableFile::Open(path, arrow::default_memory_pool()).Value(&_file);
        if (!status.ok()) {
            throw std::invalid_argument("wrong file path");
        }
    }

    arrow::Status parse() {
        ARROW_RETURN_NOT_OK(parse_footer());
        ARROW_RETURN_NOT_OK(parse_data());
        return arrow::Status::OK();
    }

private:
    class Dictionary {
    public:
        void take_over(std::shared_ptr<arrow::Buffer>&& buffer) { this->_buffer = buffer; }
        void add(const void* value) { _dictionaries.push_back(value); }
        const void* get(size_t idx) const { return _dictionaries[idx]; }

    private:
        std::shared_ptr<arrow::Buffer> _buffer;
        std::vector<const void*> _dictionaries;
    };

    struct ColumnData {
        ColumnData(std::vector<uint32_t>&& repetition_levels_, std::vector<uint32_t>&& definition_levels_,
                   std::vector<std::string>&& values_)
                : repetition_levels(std::move(repetition_levels_)),
                  definition_levels(std::move(definition_levels_)),
                  values(std::move(values_)) {}
        const std::vector<uint32_t> repetition_levels;
        const std::vector<uint32_t> definition_levels;
        const std::vector<std::string> values;
    };

    struct TreeElement {
        TreeElement(const std::string full_name_, const parquet::SchemaElement element_, TreeElement* const parent_)
                : full_name(full_name_), element(element_), parent(parent_) {}

        std::vector<const TreeElement*> ancestors() const {
            std::vector<const TreeElement*> ancestors;
            const TreeElement* cur = this;
            while (cur) {
                ancestors.push_back(cur);
                cur = cur->parent;
            }
            std::reverse(ancestors.begin(), ancestors.end());
            return ancestors;
        }

        const std::string full_name;
        const parquet::SchemaElement element;
        TreeElement* const parent;

        std::vector<TreeElement*> children;

        // Only set when leaf element
        uint32_t max_repetition_level;
        uint32_t max_definition_level;

        // Tmp data column for current row group
        std::shared_ptr<ColumnData> data;
    };

    class StructuredData {
    public:
        static arrow::Result<std::shared_ptr<StructuredData>> build(const std::vector<TreeElement*>& leafs) {
            auto root = std::make_shared<StructuredData>(true, nullptr);
            for (const auto& leaf : leafs) {
                ARROW_RETURN_NOT_OK(root->feed_column_data(leaf, leaf->data.get()));
            }

            return root;
        }

        StructuredData(const bool is_root_, const TreeElement* element_) : _is_root(is_root_), _element(element_) {}

        size_t repetition_num() const { return _nested_repetitions.size(); }

        const auto& get_repetition(const size_t repetition_idx) const { return _nested_repetitions[repetition_idx]; }

        std::vector<StructuredData*> get_ordered_nested_fields(const size_t repetition_idx) const {
            std::vector<StructuredData*> ordered_nested_fields;
            const auto& nested_repetition = _nested_repetitions[repetition_idx];

            for (const auto* child_element : _element->children) {
                const auto& name = child_element->element.name;
                if (auto it = nested_repetition.find(name); it != nested_repetition.end()) {
                    ordered_nested_fields.push_back(it->second.get());
                }
            }

            return ordered_nested_fields;
        }

        arrow::Status insert_value_to_tree(const std::string& value,
                                           const std::vector<size_t>& layer_idx_2_next_repetition_idx,
                                           const std::vector<const TreeElement*>& ancestors,
                                           const size_t start_layer_idx) {
            StructuredData* cur = this;
            for (size_t layer_idx = start_layer_idx; layer_idx < ancestors.size(); ++layer_idx) {
                const auto name = ancestors[layer_idx]->element.name;
                const auto next_repetition_idx = layer_idx_2_next_repetition_idx[layer_idx];
                if (cur->_nested_repetitions.size() <= next_repetition_idx) {
                    cur->_nested_repetitions.emplace_back();
                }
                if (cur->_nested_repetitions[next_repetition_idx].find(name) ==
                    cur->_nested_repetitions[next_repetition_idx].end()) {
                    cur->_nested_repetitions[next_repetition_idx][name] =
                            std::make_shared<StructuredData>(false, ancestors[layer_idx]);
                }
                cur = cur->_nested_repetitions[next_repetition_idx][name].get();
            }

            cur->_values.push_back(value);
            return arrow::Status::OK();
        }

        arrow::Status feed_column_data(TreeElement* element, const ColumnData* data) {
            ASSERT_TRUE(_is_root);
            const auto ancestors = element->ancestors();

            std::vector<size_t> layer_idx_2_next_repetition_idx(ancestors.size(), 0);
            std::vector<size_t> repeat_level_2_layer_idx;

            repeat_level_2_layer_idx.push_back(0);
            for (size_t layer = 0; layer < ancestors.size(); ++layer) {
                const auto ancestor = ancestors[layer];
                if (ancestor->element.repetition_type == parquet::FieldRepetitionType::REPEATED) {
                    repeat_level_2_layer_idx.push_back(layer);
                }
            }

            for (size_t i = 0; i < data->values.size(); ++i) {
                const auto repetition_level = data->repetition_levels[i];
                [[maybe_unused]] const auto definition_level = data->definition_levels[i];
                const auto& value = data->values[i];

                const auto start_layer_idx = repeat_level_2_layer_idx[repetition_level];

                StructuredData* cur = this;

                for (size_t layer_idx = 0; layer_idx < start_layer_idx; ++layer_idx) {
                    const auto& name = ancestors[layer_idx]->element.name;
                    ASSERT_TRUE(layer_idx_2_next_repetition_idx[layer_idx] >= 1);
                    const auto latest_repetition_idx = layer_idx_2_next_repetition_idx[layer_idx] - 1;
                    ASSERT_TRUE(cur->_nested_repetitions[latest_repetition_idx].find(name) !=
                                cur->_nested_repetitions[latest_repetition_idx].end());
                    cur = cur->_nested_repetitions[latest_repetition_idx][name].get();
                }

                // Reset layers after repetition layer
                for (size_t layer_idx = start_layer_idx + 1; layer_idx < layer_idx_2_next_repetition_idx.size();
                     ++layer_idx) {
                    layer_idx_2_next_repetition_idx[layer_idx] = 0;
                }

                ARROW_RETURN_NOT_OK(
                        cur->insert_value_to_tree(value, layer_idx_2_next_repetition_idx, ancestors, start_layer_idx));

                // Update row idxs of each layer
                for (size_t layer_idx = start_layer_idx; layer_idx < layer_idx_2_next_repetition_idx.size();
                     ++layer_idx) {
                    layer_idx_2_next_repetition_idx[layer_idx]++;
                }
            }

            return arrow::Status::OK();
        }

        arrow::Status to_pretty_string(std::stringstream& buffer, const std::string indent = "") const {
            buffer << indent << _element->element.name << ": \n";

            if (!_nested_repetitions.empty()) {
                ASSERT_TRUE(_values.empty());
                for (size_t repetition_idx = 0; repetition_idx < repetition_num(); ++repetition_idx) {
                    for (const auto* nested_field : get_ordered_nested_fields(repetition_idx)) {
                        ARROW_RETURN_NOT_OK(nested_field->to_pretty_string(buffer, indent + "    "));
                    }
                }
            } else {
                for (const auto& value : _values) {
                    buffer << indent << "    " << value << "\n";
                }
            }

            return arrow::Status::OK();
        }

    private:
        const bool _is_root;
        const TreeElement* _element;

        using FiledNameToNestedStructuredData = std::unordered_map<std::string, std::shared_ptr<StructuredData>>;
        // The size of _nested_data can be greater than 1 only for list layer
        std::vector<FiledNameToNestedStructuredData> _nested_repetitions;

        // Only leaf has values
        std::vector<std::string> _values;
    };

    arrow::Status parse_footer() {
        ARROW_ASSIGN_OR_RAISE(_file_size, _file->GetSize());

        reset_indent();
        print("Footer:");
        increase_indent();

        // Read Footer
        // 1. Magic Number
        uint64_t pos = _file_size;
        ARROW_ASSIGN_OR_RAISE(auto buffer, _file->ReadAt(pos - 4, 4));
        print("magic number: ", buffer->data_as<char>());
        pos -= 4;

        // 2. File Metadata length
        ARROW_ASSIGN_OR_RAISE(buffer, _file->ReadAt(pos - 4, 4));
        const auto footer_length = *buffer->data_as<int32_t>();
        print("file metadata length: ", footer_length);
        pos -= 4;

        // 3. Read the entire File Metadata
        ARROW_ASSIGN_OR_RAISE(buffer, _file->ReadAt(pos - footer_length, footer_length));
        pos -= footer_length;

        try {
            std::shared_ptr<apache::thrift::transport::TMemoryBuffer> t_mem_buffer(
                    new apache::thrift::transport::TMemoryBuffer(const_cast<uint8_t*>(buffer->data()), footer_length));
            apache::thrift::protocol::TCompactProtocolFactoryT<apache::thrift::transport::TMemoryBuffer>
                    t_proto_factory;
            std::shared_ptr<apache::thrift::protocol::TProtocol> t_proto = t_proto_factory.getProtocol(t_mem_buffer);
            _file_metadata.read(t_proto.get());
        } catch (const apache::thrift::TException& te) {
            std::cerr << "Thrift exception: " << te.what() << std::endl;
            return arrow::Status::IOError("Failed to deserialize Parquet metadata.");
        }

        print("num_rows: ", _file_metadata.num_rows);

        for (size_t i = 0; i < _file_metadata.row_groups.size(); ++i) {
            const auto& row_group = _file_metadata.row_groups[i];
            print("row group: ", i);
            increase_indent();
            if (row_group.__isset.file_offset) print("file_offset: ", row_group.file_offset);
            print("total_byte_size: ", row_group.total_byte_size);
            if (row_group.__isset.total_compressed_size)
                print("total_compressed_size: ", row_group.total_compressed_size);

            for (size_t j = 0; j < row_group.columns.size(); ++j) {
                const auto& column = row_group.columns[j];
                const auto& meta_data = column.meta_data;
                print("column: ", j);
                increase_indent();
                if (column.__isset.file_path) print("file_path: ", column.file_path);
                print("file_offset: ", column.file_offset);
                print("type: ", meta_data.type);
                print("path_in_schema: ", vector_to_string(column.meta_data.path_in_schema));
                print("encodings: ", vector_to_string(meta_data.encodings));
                print("codec: ", meta_data.codec);
                print("num_values: ", meta_data.num_values);
                print("total_compressed_size: ", meta_data.total_compressed_size);
                print("total_uncompressed_size: ", meta_data.total_uncompressed_size);
                print("data_page_offset: ", meta_data.data_page_offset);
                if (meta_data.__isset.dictionary_page_offset)
                    print("dictionary_page_offset: ", meta_data.dictionary_page_offset);
                if (meta_data.__isset.index_page_offset) print("index_page_offset: ", meta_data.index_page_offset);
                if (meta_data.__isset.bloom_filter_offset)
                    print("bloom_filter_offset: ", meta_data.bloom_filter_offset);
                if (meta_data.__isset.bloom_filter_length)
                    print("bloom_filter_length: ", meta_data.bloom_filter_length);

                decrease_indent();
            }
            decrease_indent();
        }
        decrease_indent();

        ARROW_RETURN_NOT_OK(parseTreeElements());
        return arrow::Status::OK();
    }

    arrow::Status parseTreeElements() {
        /*
         * Calculate max repetition levels and max definition levels.
         *
         * Parquet schema for this file.  This schema contains metadata for all the columns.
         * The schema is represented as a tree with a single root.  The nodes of the tree
         * are flattened to a list by doing a depth-first traversal.
         * The column metadata contains the path in the schema for that column which can be
         * used to map columns to nodes in the schema.
         * The first element is the root
         */
        ASSERT_TRUE(!_file_metadata.schema.empty());
        print("Column levels:");
        increase_indent();
        ASSERT_TRUE(_file_metadata.schema.front().name == "schema");
        auto it = _file_metadata.schema.begin();
        std::vector<std::string> paths;
        uint32_t max_repetition_level = 0;
        uint32_t max_definition_level = 0;

        std::function<void(TreeElement * parent, std::vector<parquet::SchemaElement>::iterator & it,
                           std::vector<std::string> & paths, uint32_t & max_repetition_level,
                           uint32_t & max_definition_level)>
                depth_first_visit;
        depth_first_visit = [this, &depth_first_visit](TreeElement* parent,
                                                       std::vector<parquet::SchemaElement>::iterator& it,
                                                       std::vector<std::string>& paths, uint32_t& max_repetition_level,
                                                       uint32_t& max_definition_level) -> void {
            const auto& element = *it;
            const bool is_repeated = (element.repetition_type == parquet::FieldRepetitionType::REPEATED);
            const bool is_optional =
                    (element.repetition_type == parquet::FieldRepetitionType::OPTIONAL ||
                     (element.__isset.converted_type && element.converted_type == parquet::ConvertedType::LIST));
            it++;

            paths.push_back(element.name);
            if (is_repeated) max_repetition_level++;
            if (is_optional) max_definition_level++;

            const auto unified_column_name = vector_to_string(paths, false, ".");

            auto cur = std::make_shared<TreeElement>(unified_column_name, element, parent);
            if (parent) parent->children.push_back(cur.get());
            _schema[unified_column_name] = cur;

            if (!element.__isset.num_children) {
                // Leaf
                _leafs.push_back(cur.get());
                cur->max_repetition_level = max_repetition_level;
                cur->max_definition_level = max_definition_level;
                print("column path: ", unified_column_name);
                increase_indent();
                print("max repetition level: ", max_repetition_level);
                print("max definition level: ", max_definition_level);
                decrease_indent();
            } else {
                for (int32_t child = 0; child < element.num_children; ++child) {
                    depth_first_visit(cur.get(), it, paths, max_repetition_level, max_definition_level);
                }
            }

            if (is_optional) max_definition_level--;
            if (is_repeated) max_repetition_level--;
            paths.pop_back();
        };

        depth_first_visit(nullptr, it, paths, max_repetition_level, max_definition_level);
        return arrow::Status::OK();
    }

    arrow::Status parse_data() {
        reset_indent();
        print("Data:");
        increase_indent();

        for (size_t i = 0; i < _file_metadata.row_groups.size(); ++i) {
            print("row group: ", i);
            increase_indent();
            const auto& row_group = _file_metadata.row_groups[i];

            for (size_t j = 0; j < row_group.columns.size(); ++j) {
                const auto& column = row_group.columns[j];
                const auto& meta_data = column.meta_data;
                const auto& unified_column_name = get_unified_column_name(column);

                print("column: ", unified_column_name);
                increase_indent();

                if (meta_data.total_compressed_size != meta_data.total_uncompressed_size) {
                    return arrow::Status::NotImplemented("Only support uncompressed column");
                }

                int64_t remain = meta_data.total_uncompressed_size;

                // Read one dictionary page
                if (!meta_data.__isset.dictionary_page_offset) {
                    return arrow::Status::NotImplemented("Only support dictionary");
                }
                Dictionary dictionary;
                {
                    parquet::PageHeader page_header;
                    ARROW_ASSIGN_OR_RAISE(const auto page_header_length,
                                          parse_page_header(meta_data.dictionary_page_offset, &page_header));
                    ARROW_ASSIGN_OR_RAISE(dictionary,
                                          parse_dictionary_page(meta_data.dictionary_page_offset + page_header_length,
                                                                page_header, column));
                    remain -= page_header_length;
                    remain -= page_header.uncompressed_page_size;
                }

                // Read all data pages
                parquet::PageHeader page_header;
                ARROW_ASSIGN_OR_RAISE(const auto page_header_length,
                                      parse_page_header(meta_data.data_page_offset, &page_header));
                ARROW_ASSIGN_OR_RAISE(auto data, parse_data_page(meta_data.data_page_offset + page_header_length,
                                                                 page_header, column, dictionary));

                _schema[unified_column_name]->data = std::move(data);

                remain -= page_header_length;
                remain -= page_header.uncompressed_page_size;

                // TODO Handle multi pages
                ASSERT_TRUE(remain == 0);

                decrease_indent();
            }

            ARROW_RETURN_NOT_OK(pretty_print_row_group());

            decrease_indent();
        }
        return arrow::Status::OK();
    }

    arrow::Result<uint64_t> parse_page_header(const uint64_t offset, parquet::PageHeader* page_header) {
        // We don't know the length of the page header, but the thrift deserialize process will stop when reaching boundary
        const auto page_header_length = std::min(kDefaultPageHeaderSize, _file_size - offset);
        ARROW_ASSIGN_OR_RAISE(auto buffer, _file->ReadAt(offset, page_header_length));
        try {
            std::shared_ptr<apache::thrift::transport::TMemoryBuffer> t_mem_buffer(
                    new apache::thrift::transport::TMemoryBuffer(const_cast<uint8_t*>(buffer->data()),
                                                                 page_header_length));
            apache::thrift::protocol::TCompactProtocolFactoryT<apache::thrift::transport::TMemoryBuffer>
                    t_proto_factory;
            std::shared_ptr<apache::thrift::protocol::TProtocol> t_proto = t_proto_factory.getProtocol(t_mem_buffer);
            page_header->read(t_proto.get());
            return page_header_length - t_mem_buffer->available_read();
        } catch (const apache::thrift::TException& te) {
            std::cerr << "Thrift exception: " << te.what() << std::endl;
            return arrow::Status::IOError("Failed to deserialize Parquet data page header.");
        }
    }

    arrow::Result<Dictionary> parse_dictionary_page(const uint64_t offset, const parquet::PageHeader& page_header,
                                                    const parquet::ColumnChunk& column) {
        if (page_header.dictionary_page_header.encoding != parquet::Encoding::PLAIN) {
            return arrow::Status::NotImplemented("Only support PLAIN encoding dictionary page");
        }
        if (page_header.compressed_page_size != page_header.uncompressed_page_size) {
            return arrow::Status::NotImplemented("Only support uncompressed dictionary page");
        }
        Dictionary dictionary;
        std::shared_ptr<arrow::Buffer> buffer;
        if (column.meta_data.type == parquet::Type::INT64) {
            ARROW_ASSIGN_OR_RAISE(buffer, _file->ReadAt(offset, page_header.uncompressed_page_size));
            const uint8_t* data = buffer->data();
            for (int32_t i = 0; i < page_header.dictionary_page_header.num_values; ++i) {
                dictionary.add(reinterpret_cast<const void*>(data + sizeof(int64_t) * i));
            }
        } else if (column.meta_data.type == parquet::Type::DOUBLE) {
            ARROW_ASSIGN_OR_RAISE(buffer, _file->ReadAt(offset, page_header.uncompressed_page_size));
            const uint8_t* data = buffer->data();
            for (int32_t i = 0; i < page_header.dictionary_page_header.num_values; ++i) {
                dictionary.add(reinterpret_cast<const void*>(data + sizeof(double) * i));
            }
        } else if (column.meta_data.type == parquet::Type::BYTE_ARRAY) {
            // Memory format: len1 str1 len2 str2 ...
            ARROW_ASSIGN_OR_RAISE(buffer, _file->ReadAt(offset, page_header.uncompressed_page_size));
            const uint8_t* data = buffer->data();
            size_t offset = 0;
            for (int32_t i = 0; i < page_header.dictionary_page_header.num_values; ++i) {
                const auto length = *reinterpret_cast<const uint32_t*>(data + offset);
                dictionary.add(reinterpret_cast<const void*>(data + offset));
                offset += sizeof(uint32_t) + length;
            }
        }
        dictionary.take_over(std::move(buffer));
        return dictionary;
    }

    arrow::Result<std::shared_ptr<ColumnData>> parse_data_page(const uint64_t offset,
                                                               const parquet::PageHeader& page_header,
                                                               const parquet::ColumnChunk& column,
                                                               const Dictionary& dictionary) {
        if (page_header.data_page_header.encoding != parquet::Encoding::RLE_DICTIONARY) {
            return arrow::Status::NotImplemented("Only support RLE_DICTIONARY encoding data page");
        }
        if (page_header.compressed_page_size != page_header.uncompressed_page_size) {
            return arrow::Status::NotImplemented("Only support uncompressed data page");
        }

        const auto unified_column_name = get_unified_column_name(column);
        const auto num_values = page_header.data_page_header.num_values;
        ARROW_ASSIGN_OR_RAISE(const auto buffer, _file->ReadAt(offset, page_header.uncompressed_page_size));
        const uint8_t* raw_buffer = buffer->data();

        uint64_t repetition_length;
        std::vector<uint32_t> repetition_levels;
        if (_schema[unified_column_name]->max_repetition_level != 0) {
            ARROW_RETURN_NOT_OK(
                    parse_repetition_levels(raw_buffer, page_header, column, &repetition_length, &repetition_levels));
        } else {
            repetition_length = 0;
            repetition_levels.resize(num_values, 0);
        }
        uint64_t definition_length;
        std::vector<uint32_t> definition_levels;
        if (_schema[unified_column_name]->max_definition_level != 0) {
            ARROW_RETURN_NOT_OK(parse_definition_levels(raw_buffer + repetition_length, page_header, column,
                                                        &definition_length, &definition_levels));
        } else {
            definition_length = 0;
            definition_levels.resize(num_values, 1);
        }

        const auto* element = _schema[unified_column_name].get();
        const auto max_definition_level = element->max_definition_level;

        // First bits is used to store the bit width
        const uint8_t bit_width = *(raw_buffer + repetition_length + definition_length);

        const uint64_t remain_length = page_header.uncompressed_page_size - repetition_length - definition_length - 1;
        if (remain_length == 0) {
            return std::make_shared<ColumnData>(std::move(repetition_levels), std::move(definition_levels),
                                                std::vector<std::string>{});
        }
        // The rest is the encoded binary
        arrow::util::RleDecoder value_decoder(
                raw_buffer + repetition_length + definition_length + 1,
                page_header.uncompressed_page_size - repetition_length - definition_length - 1, bit_width);

        std::vector<uint32_t> idxs(num_values);
        value_decoder.GetBatch(idxs.data(), num_values);

        auto get_value = [this, &column, &dictionary](const uint32_t idx) -> std::string {
            if (column.meta_data.type == parquet::Type::INT64) {
                return std::to_string(*reinterpret_cast<const int64_t*>(dictionary.get(idx)));
            } else if (column.meta_data.type == parquet::Type::DOUBLE) {
                return std::to_string(*reinterpret_cast<const double*>(dictionary.get(idx)));
            } else if (column.meta_data.type == parquet::Type::BYTE_ARRAY) {
                const uint32_t length = *reinterpret_cast<const uint32_t*>(dictionary.get(idx));
                return std::string(reinterpret_cast<const char*>(dictionary.get(idx)) + sizeof(uint32_t), length);
            } else {
                return std::string("unsupported type");
            }
        };
        std::vector<std::string> values;
        auto it = idxs.begin();
        if (definition_length == 0) {
            // All values are not null
            while (it != idxs.end()) {
                const auto idx = *it++;
                const auto value = get_value(idx);
                print(value);
                values.push_back(std::move(value));
            }
        } else {
            for (const auto definition_level : definition_levels) {
                if (definition_level < max_definition_level) {
                    const auto value = "NULL";
                    print(value);
                    values.push_back(std::move(value));
                } else {
                    const auto idx = *it++;
                    const auto value = get_value(idx);
                    print(value);
                    values.push_back(std::move(value));
                }
            }
        }

        return std::make_shared<ColumnData>(std::move(repetition_levels), std::move(definition_levels),
                                            std::move(values));
    }

    arrow::Status parse_repetition_levels(const uint8_t* buffer, const parquet::PageHeader& page_header,
                                          const parquet::ColumnChunk& column, uint64_t* length,
                                          std::vector<std::uint32_t>* repetition_levels) {
        const auto unified_column_name = get_unified_column_name(column);
        const auto max_repetition_level = _schema[unified_column_name]->max_repetition_level;
        if (max_repetition_level == 0) {
            *length = 0;
            return arrow::Status::OK();
        }
        const int32_t bit_width = std::ceil(std::log2(max_repetition_level + 1));
        const auto num_values = page_header.data_page_header.num_values;

        const uint32_t repetition_level_length = *reinterpret_cast<const uint32_t*>(buffer);
        *length = sizeof(uint32_t) + repetition_level_length;
        arrow::util::RleDecoder repetition_level_decoder(buffer + sizeof(uint32_t), repetition_level_length, bit_width);
        repetition_levels->resize(num_values);
        int values_read = repetition_level_decoder.GetBatch(repetition_levels->data(), num_values);
        ASSERT_TRUE(values_read == num_values);

        print("repetition_levels: ", vector_to_string(*repetition_levels));

        return arrow::Status::OK();
    }

    arrow::Status parse_definition_levels(const uint8_t* buffer, const parquet::PageHeader& page_header,
                                          const parquet::ColumnChunk& column, uint64_t* length,
                                          std::vector<std::uint32_t>* definition_levels) {
        const auto unified_column_name = get_unified_column_name(column);
        const auto max_definition_level = _schema[unified_column_name]->max_definition_level;
        if (max_definition_level == 0) {
            *length = 0;
            return arrow::Status::OK();
        }
        const int32_t bit_width = std::ceil(std::log2(max_definition_level + 1));
        const auto num_values = page_header.data_page_header.num_values;

        const uint32_t definition_level_length = *reinterpret_cast<const uint32_t*>(buffer);
        *length = sizeof(uint32_t) + definition_level_length;
        arrow::util::RleDecoder definition_decoder(buffer + sizeof(uint32_t), definition_level_length, bit_width);
        definition_levels->resize(num_values);
        int values_read = definition_decoder.GetBatch(definition_levels->data(), num_values);
        ASSERT_TRUE(values_read == num_values);

        print("definition_levels: ", vector_to_string(*definition_levels));

        return arrow::Status::OK();
    }

    arrow::Status pretty_print_row_group() {
        print("Structured Data: ");
        increase_indent();

        ARROW_ASSIGN_OR_RAISE(auto root, StructuredData::build(_leafs));

        for (size_t repetition_idx = 0; repetition_idx < root->repetition_num(); ++repetition_idx) {
            print("Row: ", repetition_idx);
            increase_indent();

            const auto& nested_fields = root->get_repetition(repetition_idx);

            ASSERT_TRUE(nested_fields.size() == 1);
            const auto& it = nested_fields.find("schema");
            ASSERT_TRUE(it != nested_fields.end());
            std::stringstream buffer;
            ARROW_RETURN_NOT_OK(it->second->to_pretty_string(buffer, ""));

            std::string line;
            while (std::getline(buffer, line)) {
                print(line);
            }

            decrease_indent();
        }

        decrease_indent();
        return arrow::Status::OK();
    }

    TreeElement* left_deep_child(TreeElement* root) {
        TreeElement* cur = root;
        while (!cur->children.empty()) {
            cur = cur->children.front();
        }
        return cur;
    }

    std::string get_unified_column_name(const parquet::ColumnChunk& column) {
        return "schema." + vector_to_string(column.meta_data.path_in_schema, false, ".");
    }

    template <typename Item>
    std::string vector_to_string(const std::vector<Item>& items, const bool boundary = true,
                                 const std::string delimiter = ", ") {
        std::stringstream buffer;
        for (const auto& item : items) {
            buffer << item << delimiter;
        }
        std::string str = buffer.str();
        if (!items.empty()) {
            str.resize(str.size() - delimiter.size());
        }
        if (boundary) {
            return "[" + str + "]";
        } else {
            return str;
        }
    }

    void increase_indent() { _indent += "    "; }

    void decrease_indent() {
        if (!_indent.empty()) _indent.resize(_indent.size() - 4);
    }

    void reset_indent() { _indent.resize(0); }

    template <typename... Args>
    void print(Args&&... args) {
        std::cout << _indent;
        (std::cout << ... << args);
        std::cout << std::endl;
    }

    std::shared_ptr<arrow::io::ReadableFile> _file;
    uint64_t _file_size;
    parquet::FileMetaData _file_metadata;

    std::shared_ptr<TreeElement> _root;
    std::unordered_map<std::string, std::shared_ptr<TreeElement>> _schema;
    std::vector<TreeElement*> _leafs;
    std::string _indent;
};

int main() {
    try {
        ParquetNativeReader reader("data.parquet");
        auto status = reader.parse();
        if (!status.ok()) {
            std::cout << status.message() << std::endl;
        }
    } catch (...) {
        std::cout << boost::stacktrace::stacktrace() << std::endl;
    }

    return 0;
}
```

```sh
mkdir -p build
gcc -o build/native_parquet_reader native_parquet_reader.cpp gen-cpp/parquet_types.cpp -lstdc++ -std=gnu++17 -larrow -lthrift -lm -ldl -lbacktrace -g
build/native_parquet_reader
```

## 1.3 Encryption

[Parquet Modular Encryption](https://github.com/apache/parquet-format/blob/master/Encryption.md)

**Encrypted footer mode**

* ![FileLayoutEncryptionEF](/images/DBMS-Format-Parquet/FileLayoutEncryptionEF.png)

**Plaintext footer mode**

* ![FileLayoutEncryptionPF](/images/DBMS-Format-Parquet/FileLayoutEncryptionPF.png)

### 1.3.1 Arrow Source Code

```cpp
#include <arrow/api.h>
#include <arrow/io/api.h>
#include <arrow/pretty_print.h>
#include <arrow/result.h>
#include <arrow/status.h>
#include <arrow/type_fwd.h>
#include <parquet/arrow/reader.h>
#include <parquet/arrow/writer.h>
#include <parquet/exception.h>

#include <filesystem>
#include <iostream>

arrow::Status execute(bool footer_plaintext, bool column_use_footer_key) {
    // Create a simple table
    arrow::Int64Builder int_col_builder;
    ARROW_RETURN_NOT_OK(int_col_builder.AppendValues({1, 2, 3, 4, 5}));
    arrow::DoubleBuilder double_col_builder;
    ARROW_RETURN_NOT_OK(double_col_builder.AppendValues({1.1, 2.2, 3.3, 4.4, 5.5}));
    arrow::StringBuilder str_col_builder;
    ARROW_RETURN_NOT_OK(str_col_builder.AppendValues({"Tom", "Jerry", "Alice", "Bob", "Jack"}));

    std::shared_ptr<arrow::Array> int_col_array;
    ARROW_RETURN_NOT_OK(int_col_builder.Finish(&int_col_array));
    std::shared_ptr<arrow::Array> double_col_array;
    ARROW_RETURN_NOT_OK(double_col_builder.Finish(&double_col_array));
    std::shared_ptr<arrow::Array> str_col_array;
    ARROW_RETURN_NOT_OK(str_col_builder.Finish(&str_col_array));
    std::shared_ptr<arrow::Schema> schema = arrow::schema({arrow::field("int_column", arrow::int64(), false),
                                                           arrow::field("double_column", arrow::float64(), false),
                                                           arrow::field("str_column", arrow::utf8(), false)});
    auto table = arrow::Table::Make(schema, {int_col_array, double_col_array, str_col_array});

    // Write the table to a Parquet file
    const std::string file_path = "encrypted_data.parquet";
    std::shared_ptr<arrow::io::FileOutputStream> outfile;
    ARROW_RETURN_NOT_OK(arrow::io::FileOutputStream::Open(file_path).Value(&outfile));

    // Lenght of key must be 16 or 24 or 32
    const std::string footer_key = "footer_key______________";
    const std::string int_column_key = "int_column_key__________";
    const std::string double_column_key = "double_column_key_______";
    const std::string str_column_key = "str_column_key__________";

    parquet::FileEncryptionProperties::Builder file_encryption_props_builder(footer_key);
    file_encryption_props_builder.algorithm(parquet::ParquetCipher::AES_GCM_V1);
    if (footer_plaintext) {
        file_encryption_props_builder.set_plaintext_footer();
    }
    if (!column_use_footer_key) {
        parquet::ColumnPathToEncryptionPropertiesMap encrypted_columns;
        {
            parquet::ColumnEncryptionProperties::Builder column_encryption_props_builder("int_column");
            column_encryption_props_builder.key(int_column_key);
        }
        {
            parquet::ColumnEncryptionProperties::Builder column_encryption_props_builder("double_column");
            column_encryption_props_builder.key(double_column_key);
        }
        {
            parquet::ColumnEncryptionProperties::Builder column_encryption_props_builder("str_column");
            column_encryption_props_builder.key(str_column_key);
        }
        file_encryption_props_builder.encrypted_columns(encrypted_columns);
    }
    std::shared_ptr<parquet::FileEncryptionProperties> file_encryption_props = file_encryption_props_builder.build();
    std::shared_ptr<parquet::WriterProperties> write_props =
            parquet::WriterProperties::Builder().encryption(file_encryption_props)->build();

    ARROW_RETURN_NOT_OK(parquet::arrow::WriteTable(*table, arrow::default_memory_pool(), outfile, 3, write_props));

    // Read the Parquet file back into a table
    std::shared_ptr<arrow::io::ReadableFile> infile;
    ARROW_RETURN_NOT_OK(arrow::io::ReadableFile::Open(file_path, arrow::default_memory_pool()).Value(&infile));

    parquet::FileDecryptionProperties::Builder file_decryption_props_builder;
    // Why footer key required if set_plaintext_footer is called
    file_decryption_props_builder.footer_key(footer_key);
    if (!column_use_footer_key) {
        parquet::ColumnPathToDecryptionPropertiesMap decrypted_columns;
        {
            parquet::ColumnDecryptionProperties::Builder column_decryption_props_builder("int_column");
            column_decryption_props_builder.key(int_column_key);
        }
        {
            parquet::ColumnDecryptionProperties::Builder column_decryption_props_builder("double_column");
            column_decryption_props_builder.key(double_column_key);
        }
        {
            parquet::ColumnDecryptionProperties::Builder column_decryption_props_builder("str_column");
            column_decryption_props_builder.key(str_column_key);
        }
        file_decryption_props_builder.column_keys(decrypted_columns);
    }
    std::shared_ptr<parquet::FileDecryptionProperties> file_decryption_props = file_decryption_props_builder.build();

    parquet::ReaderProperties read_props;
    read_props.file_decryption_properties(file_decryption_props);
    parquet::arrow::FileReaderBuilder file_reader_builder;
    ARROW_RETURN_NOT_OK(file_reader_builder.Open(infile, read_props));
    std::unique_ptr<parquet::arrow::FileReader> reader;
    ARROW_RETURN_NOT_OK(file_reader_builder.Build(&reader));

    std::shared_ptr<arrow::Table> read_table;
    ARROW_RETURN_NOT_OK(reader->ReadTable(&read_table));

    // Print the table to std::cout
    std::stringstream ss;
    ARROW_RETURN_NOT_OK(arrow::PrettyPrint(*read_table.get(), {}, &ss));
    std::cout << ss.str() << std::endl;

    return arrow::Status::OK();
}

int main(int argc, char** argv) {
    bool footer_plaintext = (std::strcmp(argv[1], "true") == 0);
    bool column_use_footer_key = (std::strcmp(argv[2], "true") == 0);
    auto status = execute(footer_plaintext, column_use_footer_key);
    if (!status.ok()) std::cout << status.message() << std::endl;
    return 0;
}
```

```sh
mkdir -p build
gcc -o build/arrow_parquet_encryption_demo arrow_parquet_encryption_demo.cpp -lstdc++ -std=gnu++17 -larrow -lparquet
build/arrow_parquet_encryption_demo false false
build/arrow_parquet_encryption_demo false true
build/arrow_parquet_encryption_demo true false
build/arrow_parquet_encryption_demo true true
```

### 1.3.2 Arrow Parse Decryption Metadata Source Code

```cpp
#include <arrow/buffer.h>
#include <arrow/io/api.h>
#include <arrow/result.h>
#include <arrow/status.h>
#include <arrow/util/key_value_metadata.h>
#include <parquet/arrow/reader.h>
#include <parquet/arrow/writer.h>
#include <parquet/exception.h>

#include <fstream>
#include <iostream>

arrow::Status exec() {
    std::shared_ptr<arrow::io::ReadableFile> _file;
    ARROW_RETURN_NOT_OK(arrow::io::ReadableFile::Open("encrypted_data.parquet", arrow::default_memory_pool()).Value(&_file));
    ARROW_ASSIGN_OR_RAISE(const auto _file_size, _file->GetSize());
    // Read Footer
    // 1. Magic Number
    uint64_t pos = _file_size;
    ARROW_ASSIGN_OR_RAISE(auto buffer, _file->ReadAt(pos - 4, 4));
    std::cout << "magic number: " << buffer->data_as<char>() << std::endl;
    pos -= 4;

    // 2. File CryptoMD and File Metadata length
    ARROW_ASSIGN_OR_RAISE(buffer, _file->ReadAt(pos - 4, 4));
    auto footer_length = *buffer->data_as<uint32_t>();
    std::cout << "FileCryptoMD and Footer length: " << footer_length << std::endl;
    pos -= 4;

    // 3. Read the entire File Metadata
    ARROW_ASSIGN_OR_RAISE(buffer, _file->ReadAt(pos - footer_length, footer_length));
    pos -= footer_length;
    auto crypto_metadata = parquet::FileCryptoMetaData::Make(buffer->data(), &footer_length);
    std::cout << "key_metadata: " << crypto_metadata->key_metadata() << std::endl;

    return arrow::Status::OK();
}

int main() {
    auto status = exec();
    if (!status.ok()) {
        std::cout << status.message() << std::endl;
    }

    return 0;
}
```

```sh
# generate encrypted_data.parquet with footer not plaintext
build/arrow_parquet_encryption_demo false false

mkdir -p build
gcc -o build/arrow_parquet_encryption_metadata_demo arrow_parquet_encryption_metadata_demo.cpp -lstdc++ -std=gnu++17 -larrow -lparquet && build/arrow_parquet_encryption_metadata_demo
```

# 2 Optimizing queries

In any query processing system, the following techniques generally improve performance:

1. Reduce the data that must be transferred from secondary storage for processing (reduce I/O)
1. Reduce the computational load for decoding the data (reduce CPU)
1. Interleave/pipeline the reading and decoding of the data (improve parallelism)

The same principles apply to querying Parquet files, as we describe below:

1. Decode optimization
1. Vectorized decode
1. Streaming decode
1. Dictionary preservation
1. Projection pushdown
1. Predicate pushdown
1. RowGroup pruning
1. Page pruning
1. Late materialization
1. I/O pushdown

# 3 Tools

## 3.1 parquet-tools

[parquet-tools](https://github.com/ktrueda/parquet-tools)

**Example:**

* `parquet-tools show data.parquet`: Display data
* `parquet-tools inspect data.parquet`: Display schema

## 3.2 Parquet Python Utils

```py
import argparse
import os

import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq

def parse_arguments():
    parser = argparse.ArgumentParser(description="Parquet reader using pyarrow")
    parser.add_argument("-f", "--file", required=True, help="Path to Parquet file")
    parser.add_argument(
        "--show",
        nargs="?",
        const="0,10",
        default=None,
        type=str,
        help="Show Parquet data rows. Format: start_row[,num_rows], e.g. --show 5,30"
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

    parquet_file = pq.ParquetFile(file_path)
    num_row_groups = parquet_file.num_row_groups
    print(f"- Number of row groups: {num_row_groups}")
    prev_end = 0
    for i in range(num_row_groups):
        rg_meta = parquet_file.metadata.row_group(i)
        print(f"  - Row group {i}: {rg_meta.num_rows} rows, range: [{prev_end}, {prev_end + rg_meta.num_rows})")
        prev_end += rg_meta.num_rows

if __name__ == "__main__":
    args = parse_arguments()

    pd.set_option("display.max_rows", None)
    pd.set_option("display.max_columns", None)
    pd.set_option("display.width", None)
    pd.set_option("display.max_colwidth", None)

    table = pq.read_table(args.file)

    if args.show:
        show_rows(table, args.show)

    if args.summary:
        summarize(table, args.file)
```

# 4 Reference

* [Querying Parquet with Millisecond Latency](https://arrow.apache.org/blog/2022/12/26/querying-parquet-with-millisecond-latency/)
