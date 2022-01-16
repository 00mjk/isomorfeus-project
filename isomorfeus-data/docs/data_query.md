### LucidQuery

Allows for isomorphically querying data.

It may at first seem practical to isomorpfivally use a compley query api, but that imposes several security issues, as each query will have to
parsed and paramaters checked to make sure that only allowed data is returned. Instead using a query class, that executes the query server side
with policy applied and able to check the passed props is way more secure and reducing complexity.

It supports the following methods for querying data:
- `execute(props:)` -> LucidQueryResult
  Convenience method useful for querying in a component render block. It returns at first a LucidQueryResult. After data has been loaded
  the LucidQueryResult will have its data available and a render is triggered. Transport request bundling applies.
  This method is optimistic and assumes success. Failure cannot be handled.

- `promise_execute(props:)` -> promise with LucidQueryResult when resolved
  This method returns a promise. This method always triggers a query when called, but subject to transport request bundling, the actual request may be
  delayed, bundled together with other request or fulfilled by another identical request.
  Typical use is from component callbacks, component preload blocks, component event handlers or outside of components,
  but not from within render blocks.

The allowed props *must* be declared. See section Props belows.

A `execute_query` block must be defined. This block must return a hash of LucidData objects,
which get then wrapped in a LucidQueryResult. Example:
```ruby
class MyQuery < LucidQuery::Base
  execute_query do
    { queried_object: MyObject.new(key: '2') } # supply object as instance
  end
end
```
MyQuery can then be executed and the result be accessed:
```ruby
MyQuery.promise_execute.then do |query_result|
  query_result.queried_object # The object as returned in the hash above. The hash key can be accessed with a method.
end
```
The query ability can be provided to other classes by mixin:
```ruby
class MyNode
  include LucidQuery::Mixin

  # now prop, execute and promise_execute can be used.
end
```

### Props
Props are used by queries and *must* be declared when used.
See [the isomorfeus-react props documentation](https://github.com/isomorfeus/isomorfeus-react/blob/master/docs/props.md#prop-declaration).

Example:
```ruby
class MyQuery < LucidQuery::Base
  prop :count, class: Integer

  execute_query do
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
