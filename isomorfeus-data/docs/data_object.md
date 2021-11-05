### LucidObject

allows for isomorphic access to Objects.
Objects have attributes. Object attributes must be declared.

#### New Instantiation
```
class MyObject < LucidObject::Base
  attribute :color
end

a = MyObject.new(attributes: { color: 'FF0000' })
a.promise_save do
  a.key
end
```

#### Loading
```
class MyObject < LucidObject::Base
  attribute :color
end

a = MyObject.load(key: '1234')
a.color # -> 'FF0000'
```

#### Searching for Objects

Objects can be searched server side using the search method on the class. To make search results isomorphically available a LucidQuery::Base class must be used. The search method returns a array of objects. It accepts as query a attribute key and a value. The value must exactly match. All attributes can be searched by using '*'.

```ruby
class MyObject < LucidObject::Base
  field :name
end

# example, server side
top_docs = MyObject.search(:name, 'hamster')

# create query class:
class MyQuery < LucidQuery::Base
  execute_query do
    { hamsters: MyObject.search(:name, 'hamster') }
  end
end

# example, client side or everywhere else in the system:
MyQuery.promise_execute.then do |query_result|
  query_result.hamsters # The hash key can be accessed with a method.
end
```

For more information about Queries and how to pass props see the [query docs](https://github.com/isomorfeus/isomorfeus-project/blob/master/isomorfeus-data/docs/data_query.md).

### Example and Specs
- [Example](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/isomorfeus/data/simple_object.rb)
- [Specs](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/spec/data_object_spec.rb)

```
class MyObject < LucidObject::Base
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
