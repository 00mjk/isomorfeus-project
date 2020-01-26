### LucidData::Query

Allows for querying data.

It supports the following methods for querying data:
- `execute(props:)` -> LucidData::QueryResult
  Convenience method useful for querying in a component render block. It returns at first a LucidData::QueryResult. After data has been loaded
  the LucidData::QueryResult will have its data available and a render is triggered. Transport request bundling applies.
  This method is optimistic and assumes success. Failure cannot be handled.
  
- `promise_execute(props:)` -> promise with LucidData::QueryResult when resolved
  This method returns a promise. This method always triggers a query when called, but subject to transport request bundling, the actual request may be
  delayed, bundled together with other request or fulfilled by another identical request.
  Typical use is from component callbacks, component preload blocks, component event handlers or outside of components,
  but not from within render blocks.
  
The allowed props *must* be declared. See section Props belows.

A `execute_query` block must be defined. This block must return a hash of LucidData objects,
which get then wrapped in a LucidData::QueryResult. Example:
```ruby
class MyQuery < LucidData::Query::Base
  execute_query do |props:, current_user:, pub_sub_client:|
    { queried_graph: MyGraph.new(key: '2') } # supply graph as instance
  end
end
```
MyQuery can then be executed and the result be accessed:
```ruby
MyQuery.promise_execute(props: {}).then do |query_result|
  query_result.queried_graph # The graph as returned in the hash above. The hash key can be accessed with a method. 
end
```
The query ability can be provided to other classes by mixin:
```ruby
class MyNode
  include LucidData::Query::Mixin

  # now prop, execute and promise_execute can be used.
end
```

### Props
Props are used by queries and *must* be declared.
See [the isomorfeus-react props documentation](https://github.com/isomorfeus/isomorfeus-react/blob/master/ruby/docs/props.md#prop-declaration).

Example:
```ruby
class MyQuery < LucidData::Query::Base
  def some_other_method
    # do soemthing else
  end

  # for style and readability it is recommended to keep props and execute_query close:
  prop :count, class: Integer
  execute_query do |props:|
    c = props.count # access props as usual 
    # etc. ... 
  end
end
```
Later on the client:
```ruby
MyQuery.promise_execute(props: { count: 12 }).then do |query_result|
  # etc. ...
end
```
