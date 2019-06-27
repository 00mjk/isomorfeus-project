# isomorfeus-transport

Transport and PubSub for isomorfeus.

### Community and Support
At the [Isomorfeus Framework Project](http://isomorfeus.com) 

## Installation
isomorfeus-transport is usually installed with the installer.
Otherwise add to your Gemfile:
```ruby
gem 'isomorfeus-transport'
```
and bundle install/update

## Server Side Rendering
`yarn add ws`

The 'ws' module then needs to be imported in application_ssr.js:
```
import WebSocket from 'ws';
global.WebSocket = WebSocket;
```

## Configuration options

Client and Server:
- Isomorfeus.api_websocket_path - path for server side endpoint, default: `/isomorfeus/api/websocket`

Server only:
- Isomorfeus.middlewares - all the rack middlewares to load


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

### Sending mesages
```ruby
MyChannel.send_message('uiuiui')
```
