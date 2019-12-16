### Common API

### props (ignore for now)
props are used for load requests
```ruby
prop :a_prop
```

### attributes
Its a challenge to keep data safe in a isomorphic framework. To ensure safety of data several requirements must be followed in `isomorfeus-data`.
Ill explain the comiing days ...
First: The central element, the smalles entity of `isomorfeus-data` is a Node (In AR terms comparable to a Record), LucidNode.
The data for a Node must be explicitly made available.
Example:
```
class MyNode < LucidNode
  attribute :name # attributes MUST be declared, only if declared it becomes accessable
  attribute :name, server_only: true # attribute value is not transported to the client
  # also validations work, similar to props for components
  attribute :name, class: String
  attribute :name, is_a: String
  # and in addition a block may be given
  attribute name, validate: proc { |value| value.is_a?(String) }
  # default value:
  attribute :name, default: 'no_name'
end
```
