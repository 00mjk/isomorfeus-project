### LucidData::Node, LucidData::Document, LucidData::Vertex

allows for isomorphic access to Nodes, Documents, Vertices.
Accessing nodes from the edges only works within a LucidData::Graph and only if the corresponding edges and nodes are included in the Graph.
LucidData::Node, LucidData::Document and LucidData::Vertex are the same. Use whichever you prefer.

### Creating a Node

Node attributes must be declared.

#### New Instantiation
```
class MyNode < LucidData::Node::Base
  attribute :color
end

a = MyNode.new(key: '1234', attributes: { color: 'FF0000' })
a = MyNode.new(key: '1234', attributes: { color: 'FF0000' })
```

#### Loading
```
class MyNode < LucidData::Node::Base
  execute_load do |key:|
    { key: key, attributes: { color: 'FF0000' } }
  end
end

a = MyNode.load(key: '1234')
a.color # -> 'FF0000'
```

### Example and Specs
- [Example](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/isomorfeus/data/simple_node.rb)
- [Specs](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/spec/data_node_spec.rb)


```
class MyNode < LucidNode
  attribute :name
  attribute :pass, server_only: true
end

# then, when accessing
my_node.name # => 'Flintstone'
my_node.pass # => '1234' on server
my_node.pass # => nil on client```

# api
# class:
#   attribute :my_attribute, server_only: false|true, class: ClassName, is_a: ClassName, default: value, validate: block
#   my_document.class.attributes
#   my_document.class.attribute_options
# instance:
#   my_document.my_attribute
#   my_document.my_attribute = value
#   my_document.changed_attributes
#   my_document.changed?
#   my_document.loaded?
#   my_document.valid_attribute?(attr, value)
#   my_document.validate_attribute!(attr, value)
#   my_document.to_transport
```
