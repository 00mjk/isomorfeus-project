## LucidChannel

Isomorfeus-transport provides the LucidChannel::Mixin and LucidChannel::Base class.
These can be used for subscriptions and publishing messages.
Policies must be defined, the must allow :subscribe, :send_message and :unsubscribe methods for the channel class.

### Class based Channels

```ruby
# create a channel
class MyChannel < LucidChannel::Base
  # for processing received messages
  on_message do |message|
    puts "received: " + message
  end
end

# subscribe to channel
MyChannel.subscribe
# or via the promise api
MyChannel.promise_subscribe.then do
  # something 
end

# send message
MyChannel.send_message('uiuiui')

# unsubscribe
MyChannel.unsubscribe
# or via the promise api
MyChannel.promise_unsubscribe.then do
  # something else
end
```

If sending of a message failed, the message will be bounced back and received by the message processor block and the error argument will contain
the reason. Otherwise the error argument will be nil.

### Custom Channels

```ruby
class MyChannel < LucidChannel::Base
  channel :cats # custom channels mut be declared
  channel :dogs

  # message processors can be given per channel
  on_message :cats do |message, error|
    puts "received: " + message
  end

  on_message :dogs do |message, error|
    puts "received: " + message
  end
end

# subscribe to a custom channel
MyChannel.subscribe(:cats)
# or via the promise api
MyChannel.promise_subscribe(:cats).then do
  # something 
end

# send message, give channel name
MyChannel.send_message('uiuiui', :cats)

# or unsubscribe
MyChannel.unsubscribe(:cats)
# or via the promise api
MyChannel.promise_unsubscribe(:cats).then do
  # something else
end
```

If sending of a message failed, the message will be bounced back and received by the message processor block and the error argument will contain
the reason. Otherwise the error argument will be nil.

### Server Side Processing

Also the server may receive messages and process them or cancel relaying of messages. This can be achieved with a server_on_message block.
If a server_on_message block is provided, it MUST return true for the message to be published.
```ruby
class MyChannel < LucidChannel::Base
  channel :cats # custom channels mut be declared
  channel :dogs

  # message processors can be given per channel
  on_message :cats do |message, error|
    puts "received: " + message
  end

  on_message :dogs do |message, error|
    puts "received: " + message
  end

  # provide server side processing block
  server_on_message :cats do |message|
    # server can now relay messages or anything else
    if message.include?('dog') 
      MyChannel.send_message(message, :dogs)
      false  # if false is returned or anything else than true, the message is NOT published at all, instead returned to the sender with the error 'Message cancelled!'
    else
      true   # only if true is returned, the message is published to the channel.
    end
  end
end

# subscribe to a custom channel
MyChannel.subscribe(:cats)

# send message, give channel name
MyChannel.send_message('uiuiui', :cats)

# or unsubscribe
MyChannel.unsubscribe(:cats)
```
