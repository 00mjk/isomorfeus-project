### LucidData::Edge, LucidData::Link

allows for isomorphic access to Edges. Edges are most useful within a LucidData::Graph but may also be used standalone to work with their attributes.
Accessing the nodes of the edges from and to only works within a LucidData::Graph and only if the corresponding nodes are included in the Graph.
LucidData::Edge and LucidData::Link are the same. Use whichever you prefer.

### Creating a Edge

Edge attributes must be declared. The from and to nodes must be given.
From and to may be given as node instance or SID.

#### New Instantiation
```
class MyEdge < LucidData::Edge::Base
  attribute :color
end

a = MyEdge.new(key: '1234', attributes: { color: 'FF0000' }, from: my_node, to: my_other_node)
a = MyEdge.new(key: '1234', attributes: { color: 'FF0000' }, from: my_node.to_sid, to: my_other_node.to_sid)
```

#### Loading
```
class MyEdge < LucidData::Edge::Base
  execute_load do |key:|
    my_node = MyNode.load(key: '1')
    my_other_node = MyOtherNode.load(key: '2')
    new(key: key, attributes: { color: 'FF0000' }, from: my_node, to: my_other_node)
  end
end

a = MyEdge.load(key: '1234')
a[0] # -> 'a'
```

### Example and Specs
- [Example](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/isomorfeus/data/simple_edge.rb)
- [Specs](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/spec/data_edge_spec.rb)
