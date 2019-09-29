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

## Authentication

For authentication in isomorfeus there is a class `Anonymous`, so whenever no user is logged in, the anonymous user is passed on to operations or data loads. In my opinion it is more true than no user (nil), because in fact there probably is a user, just the user is unknown. The Anonymous user has a default policy that denies everything, the user will respond to .authorized?(whatever) always with false by default.
Of  course, the developer can add a Policy easily, to allow certain operations or data loads, or whatever or everything:
```ruby
class MyAnonymousPolicy < LucidPolicy::Base
 policy_for Anonymous
 allow all
end
```

A class representing a user should be a LucidNode and include LucidAuthentication::Mixin:
```ruby
class User < LucidGenericNode::Base
  include LucidAuthentication::Mixin
  authentication do |user_identifier, user_password_or token|
    # should return either a User instance or a Promise which reselves to a User instance
  end
end
```
With that its possible to do on the client (or server):
```ruby
User.promise_login(user_identifier, user_password_or_token).then do |user|
   # do something with user
end
```
or later on:
```ruby
user.promise_logout
```
The authentication in isomorfeus is prepared for external or alternate authentication schemes, example:
```ruby
User.promise_login(user_identifier, token, :facebook).then do |user|
   # do something with user
end
```
will call:
```ruby
User.promise_authentication_with_facebook(user_identifier, token)
```
which would have to be implemented.

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
