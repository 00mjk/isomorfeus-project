# isomorfeus-policy

Policy for Isomorfeus


### Community and Support
At the [Isomorfeus Framework Project](http://isomorfeus.com) 

## Usage

Policy is enforced on the server, however, the same policy rules are also available on the client to allow for making consistent decisions everywhere.

Everything that is not explicitly allowed somewhere is denied.

Place the policy file in your projects `isomorfeus/policies`.

Any class that would like to authorize for accessing a resource needs to include the `LucidAuthorization::Mixin` 
or inherit from `LucidAuthorization::Base`. Example:

```ruby
class MyUser
  include LucdiAuthorization::Mixin
end
```
Any instance of that class then has the following methods available:
- `authorized?(target_class, method_name, props)` - returning true or false
- `authorized!(target_class, method_name, props)` - raising a exception if access is denied, otherwise returning true

These methods, when called, look for a Policy class. The Policy classs must be named after the user class plus the word 'Policy'.
Example:

For a class `MyUser` the policy class must be `MyUserPolicy`.

Example Policy:
```ruby
  class MyUserPolicy < LucidPolicy::Base

    allow BlaBlaGraph, :load

    deny BlaGraph, SuperOperation

    deny others # or: allow others
   
    # in a otherwise empty policy the following can be used too: 
    # allow all
    # deny all

    with_condition do |user_instance, target_class, target_method, *props|
       user_instance.class == AdminRole
    end

    refine BlaGraph, :load, :count do |user_instance, target_class, target_method, *props|
      allow if user_instance.verified?
      deny
    end
  end
```
and then any of:
```ruby
user.authorized?(target_class)
user.authorized?(target_class, target_method)
user.authorized?(target_class, target_method, *props)
```
or:
```ruby
user.authorized!(target_class)
user.authorized!(target_class, target_method)
user.authorized!(target_class, target_method, *props)
```
which will raise a LucidPolicy::Exception unless authorized
