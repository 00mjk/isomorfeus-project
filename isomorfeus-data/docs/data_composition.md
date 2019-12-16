### LucidData::Composition

allows for isomorphic access to arbitrarily composed data.
Any of the other LucidData classes may be used to compose a LucidData::Composition

### Creating a Composition

#### Declaration of Data accessors
Data accessors of a Composition must be declared:

```
class MyComposition < LucidData::Composition::Base
  compose_with :a_collection
  compose_with :a_graph
  compose_with :another_graph
  compose_with :a_array
  compose_with :a_node
  compose_with :a_hash  
end
```

#### New Instantiation
Assuming we have above class MyComposition and in addition the LucidData classes for each part of the composition as declared above:
```
c = MyComposition.new(key: '1234', parts: {
  # parts are passed as hash with keys as declared:
  a_collection: MyCollection.new(key: '1'),
  a_graph: MyGraph.new(key: '1'),
  another_graph: MyGraph.new(key: '2'),
  a_array: MyArray.new(key: '1'),
  a_node: MyNode.new(key: '1'),
  a_hash: MyHash.new(key: '1')  
})
```

#### Loading
```
class MyComposition < LucidData::Composition::Base
  execute_load do |key:|
    { key: '1234', parts: {
      # parts are passed as hash with keys as declared:
      a_collection: MyCollection.new(key: '1'),
      a_graph: MyGraph.new(key: '1'),
      another_graph: MyGraph.new(key: '2'),
      a_node: MyNode.new(key: '1'),
      a_hash: MyHash.new(key: '1') 
    }
  end
end
```

### Accessing data of a Composition
access methods are available for each of the declared parts of a composition:

```
c = MyComposition.load(key: '123456')

c.a_collection # -> MyCollection instance
c.a_graph # -> MyGraph instance
c.another_graph # -> another MyGraph instance
c.a_array # -> MyArray instance
c.a_node # -> MyNode instance
c.a_hash # -> MyHash instance
```

### Example and Specs
- [Example](https://github.com/isomorfeus/isomorfeus-framework/blob/master/ruby/isomorfeus-data/test_app_files/isomorfeus/data/simple_composition.rb)
- [Specs](https://github.com/isomorfeus/isomorfeus-framework/blob/master/ruby/isomorfeus-data/test_app_files/spec/data_composition_spec.rb)
