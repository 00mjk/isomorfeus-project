### Common API

### props (ignore for now)
props are used for load requests
```ruby
prop :a_prop
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
