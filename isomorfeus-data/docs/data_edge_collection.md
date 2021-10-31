### LucidData::EdgeCollection

allows for isomorphic access to a collection of LucidData::Edge objects.
Different edge classes are allowed in a collection.

### Creating a EdgeCollection

#### New Instantiation
```
class MyEdge < LucidData::Edge::Base
end

class MyEdgeCollection < LucidData::EdgeCollection::Base
end

a = MyEdge.new(key: '1') # also add to and from
b = MyEdge.new(key: '2') # also add to and from

c = MyEdgeCollection.new(key: '1234', edges: [a, b])

c[0].key # -> '1' - access key of first node
```

#### Loading
```
class MyEdgeCollection < LucidData::EdgeCollection::Base
  execute_load do |key:|
    a = MyEdge.new(key: '1') # also add to and from
    b = MyEdge.new(key: '2') # also add to and from
    new(key: key, edges: [a, b])
  end
end

c = MyEdgeCollection.load(key: '1234')
c[0].key # -> '1' - access key of first node
```

### Example and Specs
- [Example](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/isomorfeus/data/simple_collection.rb)
- [Specs](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/spec/data_edge_collection_spec.rb)
