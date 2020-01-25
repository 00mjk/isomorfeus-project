## Common API

### Loading Data

All LucidData *classes* support the following methods for loading data based on a key:
- `load(key:)` -> instance
  Convenience method useful for loading in a component render block. It returns at first a empty object with the key set. After data has been loaded
  the object will have its data available and a render is triggered. Transport request bundling applies.
  This method is optimistic and assumes success. Failure cannot be handled.
  
- `promise_load(key:)` -> promise with instance when resolved
  This method returns a promise. This method always triggers a load when called, but subject to transport request bundling, the actual request may be
  delayed, bundled together with other request or fulfilled by another identical request.
  Typical use is from component callbacks, component preload blocks, component event handlers or outside of components,
  but not from within render blocks.

A `execute_load` block must be defined, to execute the actual load of data. This blocks must return a instance if the class at hand or a Hash
resembling the arguments to `self.new`, see documentation of the individual classes.
Returning nil indicates that the requested item does not exist. Alternatively a exception may be thrown.

### Querying Data

All LucidData *classes* support the following methods for querying data:
- `query(props:)` -> LucidData::QueryResult
  Convenience method useful for querying in a component render block. It returns at first a LucidData::QueryResult. After data has been loaded
  the LucidData::QueryResult will have its data available and a render is triggered. Transport request bundling applies.
  This method is optimistic and assumes success. Failure cannot be handled.
  
- `promise_query(props:)` -> promise with LucidData::QueryResult when resolved
  This method returns a promise. This method always triggers a query when called, but subject to transport request bundling, the actual request may be
  delayed, bundled together with other request or fulfilled by another identical request.
  Typical use is from component callbacks, component preload blocks, component event handlers or outside of components,
  but not from within render blocks.
  
The allowed props *must* be declared. See section Props belows.

A `execute_query` blocks must be defined. These blocks must return a hash of LucidData objects,
which get then wrapped in a LucidData::QueryResult. Example:
```ruby
class MyGraph < LucidData::Graph::Base
  execute_query do |props:, current_user:, pub_sub_client:|
    { queried_graph: self.new(key: '2') } 
  end
end
```
MyGraph can then be queried and the result be accessed:
```ruby
MyGraph.promise_query(props: {}).then do |query_result|
  query_result.queried_graph # The graph as returned in the hash above. The hash key can accessed with a method. 
end
```

### Saving Data

All LucidData *instances* support the following methods for saving data:
- `save` -> self
  Optimistic convenience method, assuming success. Failure cannot be handled.

- `promise_save` -> promise with self when resolved
  This method returns a promise. This method always triggers a save when called, but subject to transport request bundling, the actual request may be
  delayed, bundled together with other request or fulfilled by another identical request.
  Typical use is from component callbacks, component preload blocks, component event handlers or outside of components, 
  but not from within render blocks.

A `execute_save` block must be defined, to execute the actual save of data. This block must return a instance if the class at hand or a Hash
resembling the arguments to `self.new`, see documentation of the individual classes.
Returning nil indicates that the save failed for some reason. Alternatively a exception may be thrown.

### Destroying Data

All LucidData *instances* support the following methods for destroying data:
- `destroy` -> true
  Optimistic convenience method, assuming success. Failure cannot be handled.

- `promise_destroy` -> promise with true when resolved
  This method returns a promise. This method always triggers a destroy when called, but subject to transport request bundling,
  the actual request may be delayed, bundled together with other request or fulfilled by another identical request.
  Typical use is from component callbacks, component preload blocks, component event handlers or outside of components, 
  but not from within render blocks.

All LucidData *classes* support the following methods for destroying data:
- `destroy(key:)` -> true
  Optimistic convenience method, assuming success. Failure cannot be handled.

- `promise_destroy(key:)` -> promise with true when resolved
  This method returns a promise. This method always triggers a destroy when called, but subject to transport request bundling,
  the actual request may be delayed, bundled together with other request or fulfilled by another identical request.
  Typical use is from component callbacks, component preload blocks, component event handlers or outside of components, 
  but not from within render blocks.

A `execute_destry` block must be defined, to execute the actual load of data. These blocks must return a instance if the class at hand or a Hash
resembling the arguments to `self.new`, see documentation of the individual classes.

### Creating Data

Creating is the same as instantiating with new and then saving the object.
 
All LucidData *classes* support the following methods for creating data:
- `create(key:, **args)` -> instance
  Optimistic convenience method, assuming success. Failure cannot be handled.

- `promise_create(key:, **args)` -> promise with instance when resolved
  This method returns a promise. This method always triggers a create when called, but subject to transport request bundling,
  the actual request may be delayed, bundled together with other request or fulfilled by another identical request.
  Typical use is from component callbacks, component preload blocks, component event handlers or outside of components, 
  but not from within render blocks.
  
For creating the `execute_save` block is used.

### Reloading Data

All LucidData *instances* support the following methods for reloading data from the server:
- `reload` -> self
  Optimistic convenience method, assuming success. Failure cannot be handled.

- `promise_reload` -> promise with self when resolved
  This method returns a promise. This method always triggers a reload when called, but subject to transport request bundling,
  the actual request may be delayed, bundled together with other request or fulfilled by another identical request.
  Typical use is from component callbacks, component preload blocks, component event handlers or outside of components, 
  but not from within render blocks.

### Attributes

All LucidData classes, except LucidData::Array, support attributes, some require them to be useful.
Attributes can be declared and validated just like props and the same options as for props apply to attributes. Just instead of `prop` use `attribute`.
See [the isomorfeus-react props documentation](https://github.com/isomorfeus/isomorfeus-react/blob/master/ruby/docs/props.md#prop-declaration).

The following classes support Attributes:
- LucidData::Hash
- LucidData::Edge
- LucidData::Document
- LucidData::Collection
- LucidData::EdgeCollection
- LucidData::Graph
- LucidData::Composition

Declaration of attributes for LucidData::Hash is optional.

For all other classes, when attributes are used, they *must* be declared.

### Props
Props are used by queries and *must* be declared.
See [the isomorfeus-react props documentation](https://github.com/isomorfeus/isomorfeus-react/blob/master/ruby/docs/props.md#prop-declaration).

Example:
```
class MyArray < LucidData::Array
    prop :count, class: Integer
    execute_query do |props:|
        c = props[:count]
    ...

```
Later on the client:
```
MyArray.promise_query(props: { count: 12 }).then do |my_array|
  ...
```
