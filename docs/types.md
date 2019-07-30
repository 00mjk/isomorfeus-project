# Types

In addition do `LucidNode` and `LucidEdge` isomorfeus-data provides the following "types":
- `LucidArray` - a array of things, can be loaded from the client: `MyArray.load(some_prop: 'some_val')`
- `LucidHash` -  a simple key value class, can be loaded from the client. `MyHash.load(some_prop: 'some_val')`
- `LucidCollection` - a collection of LucidNodes, can be loaded from the client `MyColl.load(some_prop: 'some_val')`
- `LucidGraph` - a graph that can be combined out of LucidNodes, LucidEdges, LucidArrays, LucidHashes, LucidCollections and other LucidGraphs, can be loaded on the client: `MyGraph.load(some_prop: 'some_val')`

LucidNodes and LucidEdges cannot be directly loaded on the client. They must be part of a graph or collection. Usually thats what needed anyway, eg: some current_user along with some other data. Loading single nodes, when having combinable graphs available, does not seem to be feasible and also simplifies policies and code significantly.

All of the types provided have a `query` dsl which allows for filling them with the actual data. For example:
```class MyArray < LucidArray
  query do 
    [1, 2, 3]
  end
end```
