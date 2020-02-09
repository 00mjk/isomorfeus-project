## LucidChannel

Isomorfeus-transport provides the LucidChannel::Mixin and LucidChannel::Base class.
These can be used for subscriptions and publishing messages.

### Subscriptions
```ruby
class MyChannel < LucidChannel::Base
end

# subscribe to channel
MyChannel.subscribe

# unsubscribe
MyChannel.unsubscribe
```

### Processing messages
```ruby
class MyChannel < LucidChannel::Base
  on_message do |message|
    puts "received: " + message
  end
end
```

### Sending messages
```ruby
MyChannel.send_message('uiuiui')
```
