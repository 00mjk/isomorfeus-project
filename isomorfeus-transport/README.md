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

## Configuration options

Client and Server:
- Isomorfeus.api_websocket_path - path for server side endpoint, default: `/isomorfeus/api/websocket`

Server only:
- Isomorfeus.middlewares - all the rack middlewares to load

## Usage

- [Authentication and Current User](https://github.com/isomorfeus/isomorfeus-project/blob/master/isomorfeus-transport/docs/authentication.md)
- [Channels (PubSub)](https://github.com/isomorfeus/isomorfeus-project/blob/master/isomorfeus-transport/docs/channels.md)
