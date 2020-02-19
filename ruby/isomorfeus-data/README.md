# isomorfeus-data

Data access for Isomorfeus.

*Use Ruby for Graphs! ... and more!*

### Community and Support
At the [Isomorfeus Framework Project](http://isomorfeus.com) 

### Overview

Isomorfeus Data provides convenient access to all sorts of data for the distributes, isomorphic system.
Data is available in the same way on clients and server.

Isomorfeus Data supports arrays, hashes, collections, graphs, nodes, edges and compositions of any of those which can be loaded with one requests.

All LucidData classes are database agnostic. Any ORM or data source supported by ruby can be used.
Data must then be shaped (usually in to a Hash or Array) to fit the Isomorfeus Data classes.
 

### Core Concepts and Common API

- [Core Concepts](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/docs/concepts.md)
- [Common API](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/docs/common_api.md)
- [Data Policy](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/docs/data_policy.md)

### Available Classes

All classes follow the common principles and the common API above.

- [LucidData::Array](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/docs/data_array.md) - A array, easily accessible on client and server
- [LucidData::Collections](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/docs/data_collection.md) - A collection of LucidData::Node or LucidData::Vertex or LucidData::Document objects
- [LucidData::Composition](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/docs/data_composition.md) - A composition of any of those other classes, even graphs, for easy, one request access to arbitrary data
- [LucidData::Document, LucidData::Node, LucidData::Vertex](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/docs/data_node.md) - A node/document/vertex, can be used stand alone, in a collection or in a graph
- [LucidData::Edge, LucidData::Link](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/docs/data_edge.md) - A edge/link, can be used standalone, in a collection or in a graph
- [LucidData::EdgeCollection, LucidData::LinkCollection](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/docs/data_edge_collection.md)  - A collection of LucidData::Edge or LucidData::Link objects
- [LucidData::Graph](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/docs/data_graph.md) - A graph, which can be build from several LucidData::Collection objects and LucidData::EdgeCollection objects
- [LucidData::Hash](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/docs/data_hash.md) - A hash, easily accessible on client and server

For convenience the following generic classes are provided. They can be used when creating a separate class wouldn't be useful:
- LucidData::GenericCollection
- LucidData::GenericEdgeCollection 
- LucidData::GenericNode
- LucidData::GenericEdge

(more to come soon)
