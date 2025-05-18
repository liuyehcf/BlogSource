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
        try (Reader reader = OrcFile.createReader(new Path("/tmp/user.orc"),
                OrcFile.readerOptions(conf).filesystem(FileSystem.getLocal(conf)))) {

            RecordReader rows = reader.rows();
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

# 2 Tips

## 2.1 Java Dependency classifier

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

