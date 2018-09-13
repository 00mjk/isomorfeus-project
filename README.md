# isomorfeus-transport

Various transport options for isomorfeus.
Supports:
- Pusher
- ActionCable
- WebSockets (NI)
- HTTP Ajax

## Installation
isomorfeus-transport is automatically installed if you use isomorfeus-resource.
Otherwise add to your Gemfile:
```ruby
gem 'isomorfeus-transport'
```
and bundle install/update

## Usage
### Pusher
in your client code add:
```ruby
require 'isomorfeus-transport-pusher'
```
Currently supports Pusher Channels.
```ruby

```
### ActionCable
in your client code add:
```ruby
require 'isomorfeus-transport-action-cable'
```
### WebSocket (NI)
in your client code add:
```ruby
require 'isomorfeus-transport-web-socket'
```
### HTTP Ajax
in your client code add:
```ruby
require 'isomorfeus-transport-http'
```
