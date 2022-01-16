### LucidOperation and LucidLocalOperation

LucidOperation can be triggerend from the client but is always executed on the Server. It allows to define Operations in gherkin human language style:
```ruby
class MyOperation < LucidOperation::Base
  prop :a_prop

  procedure <<~TEXT
     Given a bird
     When it flies
     Then be happy
  TEXT

  Given /a bird/ do
     props.a_prop == 'a_value'
  end

  # etc ...
end

MyOperation.promise_run(a_prop: 'a_value')
```

LucidLocalOperation is the same as LucidOperation, except its always executed locally, wherever that may be.

#### Policy

To allow execution permission must be granted. After restricting the default policy, the :promise_run method must be allowed. Example:

```ruby
class MyUserPolicy
  allow MyOperation, :promise_run
end
```
For more information see see [Policy Docs](https://github.com/isomorfeus/isomorfeus-project/blob/master/isomorfeus-policy/README.md).
