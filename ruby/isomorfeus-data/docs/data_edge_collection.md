### LucidData::EdgeCollection, LucidData::LinkCollection

allows for isomorphic access to a collection of LucidData::Edge, LucidData::Link objects.

EdgeCollection and LinkCollection are the same, use whichever term you prefer.

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
# or use links:
c = MyEdgeCollection.new(key: '1234', links: [a, b])

c[0].key # -> '1' - access key of first node
```

#### Loading
```
class MyEdgeCollection < LucidData::EdgeCollection::Base
  execute_load do |key:|
    a = MyEdge.new(key: '1') # also add to and from
    b = MyEdge.new(key: '2') # also add to and from
    { key: key, edges: [a, b] } # also here :links can be used.
  end
end

c = MyEdgeCollection.load(key: '1234')
c[0].key # -> '1' - access key of first node
```

### Example and Specs
- [Example](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/isomorfeus/data/simple_collection.rb)
- [Specs](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/spec/data_edge_collection_spec.rb)
