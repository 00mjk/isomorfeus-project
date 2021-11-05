# isomorfeus-data

Data access for Isomorfeus.

*Use Ruby for Graphs! ... and more!*

### Community and Support
At the [Isomorfeus Framework Project](http://isomorfeus.com)

### Overview

Isomorfeus Data provides convenient access to data for the distributed, isomorphic system.
Data is available in the same way on clients and server.

Isomorfeus Data supports documents, objects and files.

### Core Concepts and Common API

- [Core Concepts](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/docs/concepts.md)
- [Common API](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/docs/common_api.md)
- [Data Policy](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/docs/data_policy.md)

### Available Classes

All classes follow the common principles and the common API above.

- [LucidDocument](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/docs/data_document.md) - for textual data with fields
- [LucidObject](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/docs/data_object.md) - for objects with attributes
- [LucidFile](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/docs/data_file.md) - for files like images, pdfs, etc.
- [LucidQuery](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/docs/data_query.md) - for isomorphic queries.

### Storage

isomorfeus-data relies on:
- [isomorfeus-ferret](https://github.com/isomorfeus/isomorfeus-ferret) as storage and index for documents
- [isomorfeus-hamster](https://github.com/isomorfeus/isomorfeus-hamster) as storage and index for objects
- the Filesystem for files
- [Oj](https://github.com/ohler55/oj) for serialization
