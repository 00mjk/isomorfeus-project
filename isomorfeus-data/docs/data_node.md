### LucidData::Node

allows for isomorphic access to Nodes.

Nodea are objects with attributes.

Accessing nodes from the edges only works within a LucidData::Graph and only if the corresponding edges and nodes are included in the Graph.

### Creating a Node

Node attributes must be declared.

#### New Instantiation
```
class MyNode < LucidData::Node::Base
  attribute :color
end

a = MyNode.new(attributes: { color: 'FF0000' })
a.promise_save do
  a.key # when creating a new node the key is known after saving it, e.g. -> '1234'
end
```

#### Loading
```
class MyNode < LucidData::Node::Base
  attribute :color
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
#   my_node.class.attributes
#   my_node.class.attribute_options
# instance:
#   my_node.my_attribute
#   my_node.my_attribute = value
#   my_node.changed_attributes
#   my_node.changed?
#   my_node.loaded?
#   my_node.valid_attribute?(attr, value)
#   my_node.validate_attribute!(attr, value)
#   my_node.to_transport
```
