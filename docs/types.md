# Types

```ruby
LucidComposableGraph # - can include any other type and itself, except LRO and LSO

LucidArango::Document # -> maps to Arango::Document, Arango::Vertex (would be like  ActiveRecord or Node)
LucidArango::Edge # -> Arango::Edge
LucidArango::DocumentCollection # -> Arango::DocumentCollection
LucidArango::EdgeCollection # -> Arango::EdgeCollection
LucidArango::Graph # -> Arango::Graph

LucidData::Document # -> any db (would be like  ActiveRecord or Node)
LucidData::Edge # -> any db
LucidData::Collection # -> any db
# to build graphs from that use LucidComposableGraph
```

ObjectStore
```ruby
LucidRemoteObject # -> drb like remote object calls to ...
LucidStorableObject # -> serializable, queryable ruby objects, uses Arango::Document internally.
```

# API
## LucidComposableGraph
### props
props are used for load requests
```ruby
prop :a_prop
```

### composing a graph -> OK
```ruby
  compose_with :my_collection do MyCollection.load(a_prop: props.a_props) end
```

### loading a graph
```ruby
MyGraph.get(key) #<- for arango based graph
MyGraph.get_by #???
MyGraph.load(props)
MyGraph.fetch()
```

### modifying a graph
that means modifying the included elements directly. See modifying collections, nodes.

### querying  graph
a query is delegated to each included items.
```ruby
my_graph.query(query)
my_graph.find(Class, id)
my_graph.find_by(hash)
```

### saving changes -> OK
```
my_graph.save
```
will walk the graph, asking each loaded element for changes and call save on the element if it changed.


## LucidGraph
### querying
```ruby
class MyGraph < LucidArango::Graph::Base
  predefine_query :name do
  
  end
end
```

```ruby
my_graph.execute_query :name, props
```
