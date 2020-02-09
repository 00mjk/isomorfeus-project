### LucidQuickOp

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
# or
MyQuickOp.promise_run(props: { a_prop: 'a_value' })
```
#### Policy

To allow execution permission must be granted. After restricting the default policy, the :promise_run method must be allowed. Example:
```ruby
class MyUserPolicy
  allow MyQuickOp, :promise_run
end
```
For more information see see [Policy Docs](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-policy/README.md).
