# Types

```ruby
LucidComposableGraph # - can include any other type and itself

LucidDocument # -> maps to Arango::Document, Arango::Vertex (would be like  ActiveRecord or Node)
LucidEdge # -> Arango::Edge
LucidDocumentCollection # -> Arango::DocumentCollection
LucidEdgeCollection # -> Arango::EdgeCollection
LucidGraph # -> Arango::Graph

LucidGenericDocument # -> any db (would be like  ActiveRecord or Node)
LucidGenericEdge # -> any db
LucidGenericCollection # -> any db
# to build graphs from that use LucidComposableGraph

LucidRemoteObject # -> drb like remote object calls to ...
LucidStorableObject # -> serializable, queryable ruby objects, uses Arango::Document internally.
```
