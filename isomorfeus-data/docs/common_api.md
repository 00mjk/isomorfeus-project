## Common API

Loading data from the client must be allowed by policy, see [Data Policy](https://github.com/isomorfeus/isomorfeus-project/blob/master/isomorfeus-data/docs/data_policy.md)

### Loading Data

All LucidData *classes* support the following methods for loading data based on a key:
- `load(key:)` -> instance
  Convenience method useful for loading in a isomorfeus-preact component render block. It returns at first a empty object with the key set. After data has been loaded the object will have its data available and a render is triggered. Transport request bundling applies.
  This method is optimistic and assumes success. Failure cannot be handled.
  On the client: Triggers a load only when data has not been loaded yet.
  On the server: The same as load!, always loads data immediately.

- `load!(key:)` -> instance
  The same as load but always triggers a load.

- `promise_load!(key:)` -> promise with instance when resolved
  This method returns a promise. This method always triggers a load when called, but subject to transport request bundling, the actual request may be delayed, bundled together with other request or fulfilled by another identical request.
  Typical use is from isomorfeus-preact component callbacks, component preload blocks, component event handlers or outside of components, but not from within component render blocks.

- `promise_load(key:)` -> promise with instance when resolved
  On the client: This method is the same as promise_load! but triggers load only when data has not been loaded yet.
  On the server: The same as promise_load!, always loads data.

A `execute_load` block can be defined for classes inheriting from LucidData classes, to execute load of data from other sources. This blocks must return a instance if the class. Returning nil indicates that the requested item does not exist. Alternatively a exception may be thrown.

### Creating Data

Creating is the same as instantiating with new and then saving the object.

All LucidData *classes* support the following methods for creating data:
- `create(key:, **args)` -> instance
  Optimistic convenience method, assuming success. Failure cannot be handled.

- `promise_create(key:, **args)` -> promise with instance when successful
  This method returns a promise. This method always triggers a create when called, but subject to transport request bundling,
  the actual request may be delayed, bundled together with other request or fulfilled by another identical request.
  Typical use is from component callbacks, component preload blocks, component event handlers or outside of components,
  but not from within render blocks.

For creating a `execute_create` block can be defined, to execute the actual creation of data in other sources. This block is executed within the instance und must return self.
Returning nil indicates that the create failed for some reason. Alternatively a exception may be thrown.

### Saving Data

All LucidData *instances* support the following methods for saving data:
- `save` -> self
  Optimistic convenience method, assuming success. Failure cannot be handled.

- `promise_save` -> promise with self when successful
  This method returns a promise. This method always triggers a save when called, but subject to transport request bundling, the actual request may be delayed, bundled together with other request or fulfilled by another identical request.
  Typical use is from component callbacks, component preload blocks, component event handlers or outside of components,
  but not from within component render blocks.

A `execute_save` block can be defined, to execute the actual save of data in other sources. This block is executed within the instance und must return self.
Returning nil indicates that the save failed for some reason. Alternatively a exception may be thrown.

### Destroying Data

All LucidData *classes* support the following methods for destroying data:
- `destroy(key:)` -> true
  Optimistic convenience method, assuming success. Failure cannot be handled.

- `promise_destroy(key:)` -> promise with true when successful
  This method returns a promise. This method always triggers a destroy when called, but subject to transport request bundling,
  the actual request may be delayed, bundled together with other request or fulfilled by another identical request.
  Typical use is from component callbacks, component preload blocks, component event handlers or outside of components,
  but not from within render blocks.

A `execute_destroy` block must be defined, to execute the actual load of data. These blocks must return `true` if the destroy succeeded or `false`
otherwise.

All LucidData *instances* support the following methods for destroying data:
- `destroy` -> true
  Optimistic convenience method, assuming success. Failure cannot be handled.

- `promise_destroy` -> promise with true when successful
  This method returns a promise. This method always triggers a destroy when called, but subject to transport request bundling,
  the actual request may be delayed, bundled together with other request or fulfilled by another identical request.
  Typical use is from component callbacks, component preload blocks, component event handlers or outside of components,
  but not from within render blocks.

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

LucidOject supports and requires attributes.
Attributes can be declared and validated just like props and the same options as for props apply to attributes. Just instead of `prop` use `attribute`.
See [the isomorfeus-preact props documentation](https://github.com/isomorfeus/isomorfeus-preact/blob/master/docs/props.md#prop-declaration).
