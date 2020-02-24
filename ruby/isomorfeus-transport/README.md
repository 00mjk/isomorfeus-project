# isomorfeus-transport

Transport and PubSub for Isomorfeus.

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

## Usage

- [Authentication and Current User](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-transport/docs/authentication.md)
- [Channels (PubSub)](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-transport/docs/channels.md)
