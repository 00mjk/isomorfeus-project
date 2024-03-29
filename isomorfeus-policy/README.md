# isomorfeus-policy

Policy for Isomorfeus

### Community and Support
At the [Isomorfeus Framework Project](https://isomorfeus.com)

## Usage

Policy is enforced on the server, however, the same policy rules are also available on the client to allow for making consistent decisions everywhere.

Everything that is not explicitly allowed somewhere is denied.

Place the policy files in your projects `app/policies` directory.

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

These methods, when called, look for a Policy class. The Policy class must be named after the user class plus the word 'Policy'.
Example:

For a class `MyUser` the policy class must be `MyUserPolicy`.

### Simple Rules
Example Policy:
```ruby
class MyUserPolicy < LucidPolicy::Base
  # allow access to all methods of a class
  allow BlaBlaGraph
  # class names can be given as strings which benefits autoload performance as the class can be loaded later on
  allow 'BlaBlaGraph'

  # allow access to all methods of multiple classes
  allow BlaBlaGraph, BlaComposition

  # allow access to a single method of a class
  allow BlaBlaGraph, :load

  # or allow multiple methods of a class
  allow BlaBlaGraph, :load, :save

  # deny access to all methods of multiple classes
  deny BlaGraph, SuperOperation

  deny others # or: allow others

  # in a otherwise empty policy the following can be used too:
  # allow all
  # deny all

  # further conditions can be used
  allow BlaBlaGraph, :member_feature, only_if: :registered?
    # this will call the method registered? on the user instance. The method must return a boolean.
    # permission is granted if the method returned true
    # method name must be given as symbol
    # other versions:
    allow BlaBlaGraph, :member_feature, if: :registered?

  allow BlaBlaGraph, :public_feature, only_if_not: :registered?
    # this will call the method registered? on the user instance. The method must return a boolean.
    # permission is granted if the method returned false
    # method name must be given as symbol
    # other versions:
    allow BlaBlaGraph, :member_feature, only_unless: :registered?
    allow BlaBlaGraph, :member_feature, unless: :registered?
    allow BlaBlaGraph, :member_feature, if_not: :registered?

  # a proc can be passed directly to a rules condition
  allow BlaBlaGraph, :member_feature, if: proc { |user, props| user.registered? }
  # permission is granted if the block returns true

  # similar for deny, though:
  deny BlaBlaGraph, :member_feature, if: proc { |user, props| !user.registered? }
  # permission is denied if the block returns true
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

### Custom Rules
Besides calling methods or executing blocks from allow or deny, custom rules can be defined. Example:
```ruby
class MyUserPolicy < LucidPolicy::Base
  rule BlaGraph, :load, :count do |user, target_class_name, target_method, props|
    allow if user.verified?
    allow if user.admin?
    deny
  end
end
```
Within the rule block the `allow` and `deny` methods must be used to allow or deny access.
They accept no arguments. Within the block the default is to deny, so any matching allow wins.

### Combining Policies
Policies can be combined. Across policies, the first Policy rule that permits access wins.
The outer policy is considered first, then the other policies.
If the outer policy allows, then the other policies are not considered.
If the outer policy has a `allow all` or a `allow others` rule, then there is a good chance the other policies are never considered.
The recommended default rule for combined policies is `deny others`.

Given a:
```ruby
  class AdminRolePolicy < LucidPolicy::Base
    rule BlaGraph, :load, :count do |user, target_class_name, target_method, props|
      allow if user.verified?
      deny
    end
  end
```
another policy can include the rules. Example:
```ruby
class MyUserPolicy < LucidPolicy::Base
  combine_with AdminRolePolicy

  # conditions as for allow and deny can be used too
  combine_with AdminRolePolicy, if: :admin?
    # this will call the method admin? on the user instance. The method must return a boolean.
    # this will execute the AdminRolePolicy rules only if the method returned true
    # method name must be given as symbol

  combine_with AdminRolePolicy, if_not: :normal_guy?
    # this will call the method normal_guy?? on the user instance. The method must return a boolean.
    # this will execute the AdminRolePolicy rules only if the method returned false
    # method name must be given as symbol
    # other versions:
    combine_with AdminRolePolicy, unless: :normal_guy?

  # a block can be passed directly to a rules condition
  combine_with AdminRolePolicy, if: proc { |user| user.admin? }
  # this will execute the AdminRolePolicy rules only if the condition block returns true

  deny others
end
```
### Debugging Policies or finding out the winning rule
Its possible to start recording the reason for a authorization result:
```ruby
my_user.record_authorization_reason
```
When then authorizing:
```ruby
my_user.authorized?(BlaGraph, :load)
```
the reason for access or denied access, the winning rule, can be inspected:
```ruby
my_user.authozation_reason
```

It will be a Hash and show the responsible policy class, condition, condition result, etc. Example:
```ruby
{ combined:
  { class_name: "Resource",
    others: :deny,
    policy_class: "CombinedPolicy" },
  policy_class: "UserPolicy" }
```

Recording can be stopped again, for better performance:
```ruby
my_user.stop_to_record_authorization_reason
```
