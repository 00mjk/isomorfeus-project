# LucidNode
Its a challenge to keep data safe in a isomorphic framework. To ensure safety of data several requirements must be followed in `isomorfeus-data`.
Ill explain the comiing days ...
First: The central element, the smalles entity of `isomorfeus-data` is a Node (In AR terms comparable to a Record), LucidNode.
The data for a Node must be explicitly made available.
Example:
```class MyNode < LucidNode
   attribute :name # attributes MUST be declared, only if declared it becomes accessable
   attribute :name, server_only: true # attribute value is not transported to the client
  # also validations work, similar to props for components
  attribute :name, class: String
  attribute :name, is_a: String
  # and in addition a block may be given
  attribute name, validate: proc { |value| value.is_a?(String) }
  # default value:
  attribute :name, default: 'no_name'
end```

The intention is to prevent accidential, read: automatic, information leaks. If information leaks, there must have been somebody who wrote `attribute :bla` within a Node class.

Jan Biedermann [11:05 Uhr]
If now a MyNode is created on the server with:
```class MyNode < LucidNode
  attribute :name
end

my_node = MyNode.new(id: '12', name: 'Flintstone', pass: '1234')

# then
my_node.name # => 'Flintstone'
my_node.pass # => method missing```
with:
```class MyNode < LucidNode
  attribute :name
  attribute :pass, server_only: true
end

my_node = MyNode.new(id: '12', name: 'Flintstone', pass: '1234')

# then, when accessing
my_node.name # => 'Flintstone'
my_node.pass # => '1234' on server
my_node.pass # => nil on client```