# isomorfeus-data

Data access for Isomorfeus.

### Community and Support

At the [Isomorfeus Framework Project](http://isomorfeus.com)

### Overview

Isomorfeus Data provides convenient access to data for the distributed, isomorphic system.
Data is available in the same way on clients and server.
Isomorfeus Data supports documents, objects and files.
Graphs can easily be implemented with objects.

### Core Concepts and Common API

- [Core Concepts](docs/concepts.md)
- [Common API](docs/common_api.md)
- [Data Policy](docs/data_policy.md)

### Available Classes

All classes follow the common principles and the common API above.

- [LucidDocument](docs/data_document.md) - for textual data with fields
- [LucidObject](docs/data_object.md) - for objects with attributes
- [LucidFile](docs/data_file.md) - for files like images, pdfs, etc.
- [LucidQuery](docs/data_query.md) - for isomorphic queries.

### Storage

isomorfeus-data relies on:

- [isomorfeus-ferret](https://github.com/isomorfeus/isomorfeus-ferret) as storage and index for documents
- [isomorfeus-hamster](https://github.com/isomorfeus/isomorfeus-hamster) as storage and index for objects
- the Filesystem for files
- [Oj](https://github.com/ohler55/oj) for serialization
