### LucidQuickOp

LucidQuickOp can be triggerend from the client but is always executed on the Server.
```ruby
class MyQuickOp < LucidQuickOp::Base
  prop :a_prop

  op do
    if RUBY_ENGINE != 'opal' # keep asset size low and guard code against inclusion in client side assets
      props.a_prop == 'a_value'
      # do something
    end
  end
end

MyQuickOp.promise_run(a_prop: 'a_value')
```
#### Policy

To allow execution permission must be granted. After restricting the default policy, the :promise_run method must be allowed. Example:
```ruby
class MyUserPolicy
  allow MyQuickOp, :promise_run
end
```
For more information see see [Policy Docs](https://github.com/isomorfeus/isomorfeus-project/blob/master/isomorfeus-policy/README.md).
