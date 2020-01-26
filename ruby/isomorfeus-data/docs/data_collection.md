### LucidData::Collection

allows for isomorphic access to a collection of LucidData::Node, LucidData::Document, LucidData::Vertex objects.

Node, Document and Vertex are the same, use whichever term you prefer.

Different node classes are allowed in a collection.

### Creating a Collection

#### New Instantiation
```
class MyNode < LucidData::Node::Base
end

class MyCollection < LucidData::Collection::Base
end

a = MyNode.new(key: '1')
b = MyNode.new(key: '2')

c = MyCollection.new(key: '1234', nodes: [a, b])
# here also the other terms work:
c = MyCollection.new(key: '1234', documents: [a, b])
c = MyCollection.new(key: '1234', vertices: [a, b])
c = MyCollection.new(key: '1234', vertexes: [a, b])

c[0].key # -> '1' - access key of first node
```

#### Loading
```
class MyCollection < LucidData::Collection::Base
  execute_load do |key:|
    a = MyNode.new(key: '1')
    b = MyNode.new(key: '2')
    { key: key, nodes: [a, b] } # also here the other terms work instead of nodes: documents, vertices, vertexes
  end
end

c = MyCollection.load(key: '1234')
c[0].key # -> '1' - access key of first node
```

### Example and Specs
- [Example](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/isomorfeus/data/simple_collection.rb)
- [Specs](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/spec/data_collection_spec.rb)
