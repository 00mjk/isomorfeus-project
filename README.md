# isomorfeus-transport

Base for the various transport options for isomorfeus.

## Installation
isomorfeus-transport is usually installed with the installer.
Otherwise add to your Gemfile:
```ruby
gem 'isomorfeus-transport'
```
and bundle install/update

## Configuration options

Client and Server:
- Isomorfeus.api_path - path for server side endpoint, default: `/isomorfeus/api/endpoint`

Client only:
- Isomorfeus.client_transport_driver - driver to use for communicating with server and pub sub.
- Isomorfeus.transport_notification_channel_prefix - default: `isomorfeus-transport-notifications-`

Server only:
- Isomorfeus.authorization_driver - driver to use for authorization
- Isomorfeus.middlewares - all the rack middlewares to load
- Isomorfeus.transport_middleware_requires_use - boolean, require user for anything transport related