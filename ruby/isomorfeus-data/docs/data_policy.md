### Policy for Data

Permission must be granted for current user to allow access to data.
The default user within Isomorfeus is Anonymous with a default policy to allow everything,
see [Policy Docs](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-policy/README.md)
After restricting the default policy, access to data must be explicitly allowed.

#### Creating Data

The :create method must be allowed. Example:

Given a custom data class with a execute_create block:
```ruby
class MyNode < LucidData::Node::Base
  execute_create do |instance:|
    # 
  end
end
```

And code to create data on the client:
```ruby
# either by promise
MyNode.promise_create(*args).then {}
# or optimistic
MyNode.create(*args)
```

The Policy allowing the :create method, for example for MyUser:
```ruby
class MyUserPolicy
  allow MyNode, :create 
end
```

#### Loading Data

Likewise as for creating for loading:
```ruby
class MyUserPolicy
  allow MyNode, :load
end
```

#### Saving Data
Likewise for saving:
```ruby
class MyUserPolicy
  allow MyNode, :save
end
```

#### Destroying Data
Likewise for destroying:
```ruby
class MyUserPolicy
  allow MyNode, :destroy
end
```
