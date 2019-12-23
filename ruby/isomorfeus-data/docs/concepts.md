## Isomorfeus-Data Core Concepts

### Isomorphic Data Access and Behaviour

Isomorphism - the same -> it could be but is not necessarily identical.

That is true for data access, representation and behaviour.

The API throughout the system is the same, calls are expected to deliver the same results, the same data.

However, internal representation and implementation of LucidData Classes differs, depending on environment and
may inhibit different performance characteristics.

### Serialization

Everything stored or accessed with the LucidData classes must be JSON serializable.
Symbols will become Strings during serialization, within data they should be avoided. Use Strings instead of Symbols.

### Key

#### Key as system wide Identifier

To identify a data object uniquely throughout the distributed isomorphic system, each Isomorfeus LucidData Object requires a key.
Objects of same class and key are expected to be the same throughout the system.

#### Example: Instantiating Data by key:
```
class MyNode < LucidData::Node::Base
end

MyNode.new(key: '123456')  # <- key is required 
```

#### Keys are Strings

Keys are strings. If something else is passed as key .to_s is called on it, transforming it to a string.

#### Example: Loading data by key, scenario with 2 clients and one server:

On client 1:
```
MyNode.load(key: '123456')
```

On client 1:
```
MyNode.load(key: '123456')
```

On server:
```
MyNode.load(key: '123456')
```

Each of those calls above is expected to load the same data object.
Data is now the same throughout the system.

But at any time, either a client or the server may change the data. What happens now, depends on the application implementation.
It is absolutely possible to distribute the change immediately throughout the system using LucidChannels from Isomorfeus-Transport.

#### Example: Multiple loads of the same class with the same key on a client
On a client:
```
a = MyNode.load(key: '123456')
b = MyNode.load(key: '123456')
```

Instances a and b provide access to the same data (as long as data is not changed by either of those) but are different objects:

```
a.a_attribute == b.a_attribute # -> true
a.object_id == b.object_id # -> false
``` 

### Revision

To detect parallel data changes and to be able to handle them, the LucidData classes support *revisions*.

 (more to come on this topic later)

### Attributes

All LucidData classes except LucidData::Array support attributes, some require them to be useful. See the Common API doc and class specific docs.
Attributes can be declared and validated just like props and the same options as for props apply to attributes. Just instead of `prop` use `attribute`.
See [the isomorfeus-react props documentation](https://github.com/isomorfeus/isomorfeus-react/blob/master/ruby/docs/props.md#prop-declaration).

### Classes and Mixins

To inherit from a LucidData class use the Base class, example:
```
class MyNode < LucidData::Node::Base
end
```

To include LucidData functionality as module use the Mixin module, example:
```
class MyNode
  include LucidData::Node::Mixin
end
```

### SID - System wide IDentifier

A SID identifies a instance of the LucidData classes in the system.
A SID is for example used by the system within serialized data and on the client to identify data for instances or instantiate new instances.
A SID is just a small array consisting of class name and key:

Example: 
```
class MyNode < LucidData::Node::Base
end

n = MyNode.new(key: '231')
n.to_sid # -> ['MyNode', '231']
```


```
[  'MyNode',   '231'  ]   <- Array
       ^         ^
       |         |
 class name     key
```

