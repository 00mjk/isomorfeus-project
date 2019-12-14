# isomorfeus-policy

Policy for Isomorfeus


### Community and Support
At the [Isomorfeus Framework Project](http://isomorfeus.com) 

## Usage

Policy is enforced on the server, however, the same policy rules are also available on the client to allow for making consistent decisions everywhere.

Everything that is not explicitly allowed somewhere is denied.

Place the policy file in your projects `isomorfeus/policies`.

Example Policy:
```ruby
  class MySimplePolicy < LucidPolicy::Base

    policy_for UserOrRoleClass

    allow BlaBlaGraph, :load

    deny BlaGraph, SuperOperation

    deny others # or: allow others
   
    # in a otherwise empty policy the following can be used too: 
    # allow all
    # deny all

    with_condition do |user_or_role_instance, target_class, target_method, *props|
       role.class == AdminRole
    end

    refine BlaGraph, :load, :count do |user_or_role_instance, target_class, target_method, *props|
      allow if user_or_role_instance.verified?
      deny
    end
  end
```
and then any of:
```ruby
user_or_role_instance.authorized?(target_class)
user_or_role_instance.authorized?(target_class, target_method)
user_or_role_instance.authorized?(target_class, target_method, *props)
```
or:
```ruby
user_or_role_instance.authorized!(target_class)
user_or_role_instance.authorized!(target_class, target_method)
user_or_role_instance.authorized!(target_class, target_method, *props)
```
which will raise a LucidPolicy::Exception unless authorized
