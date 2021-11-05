## Isomorfeus-Data Core Concepts

### Isomorphic Data Access and Behaviour

Isomorphism - means the the same -> it could be, but is not necessarily identical.

That is true for data access, representation and behaviour of isomorfeus-data.

The API throughout the system is the same, calls are expected to deliver the same results, the same data.

However, internal representation and implementation of LucidData classes and instances differs, depending on environment and
may inhibit different performance characteristics.

### Serialization

Everything stored or accessed with the LucidData classes must be JSON serializable.
Symbols will become Strings during serialization, within data they should be avoided. Use Strings instead of Symbols.

### Key

#### Key as identifier

To identify a data object uniquely each Isomorfeus LucidData Object requires a key. Objects of same class and key are expected to be the same throughout the system.
If at creation of a instance, when saving it, no key is given, a UUID is automatically assigned as key.

#### Example: Instantiating Data by key:
```
class MyNode < LucidObject::Base
end

MyNode.new(key: '123456')
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

### SID - System wide IDentifier
To identify a data object uniquely throughout the distributed isomorphic system the SID is used.
A SID identifies instances of the LucidData classes in the system.
A SID is for example used by the system within serialized data and on the client to identify data for instances or to instantiate new instances.
A SID is just a small array consisting of class name and key:

Example:
```
class MyNode < LucidObject::Base
end

n = MyNode.new(key: '231')
n.sid # -> ['MyNode', '231']
```

SID explained:
```
[  'MyNode',   '231'  ]   <- Array
       ^         ^
       |         |
 class name     key
```

### Revision

To detect parallel data changes and to be able to handle them, the LucidData classes support *revisions*.

 (more to come on this topic later)

### Classes and Mixins

To inherit from a LucidData class use the Base class, example:
```
class MyNode < LucidObject::Base
end
```

To include LucidData functionality as module use the Mixin module, example:
```
class MyNode
  include LucidObject::Mixin
end
```
