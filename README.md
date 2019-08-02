# isomorfeus-operation

there are 3 kinds of Operations:
- LucidQuickOp
- LucidOperation
- LucidLocalOperation

```ruby
class MyQuickOp < LucidQuickOp::Base
  prop :a_prop

  op do
    props.a_prop == 'a_value'
    # do something
  end
end

MyQuickOp.promise_run(a_prop: 'a_value')
```

Quick remote procedure call, always executed on the server.
LucidOperation too is always executed on the Server. It allows to define Operations in gherkin human language style:
```
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
Its barely tested so far and no other docs.
