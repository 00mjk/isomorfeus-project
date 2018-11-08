module Isomorfeus
  # available settings

  if RUBY_ENGINE == 'opal'
    add_client_option(:api_path)
    add_client_option(:client_transport_driver)
    add_client_option(:transport_notification_channel_prefix, 'isomorfeus-transport-notifications-')
  else
  # defaults
    class << self
      attr_accessor :api_path
      attr_accessor :authorization_driver
      attr_accessor :transport_middleware_require_user
      attr_accessor :server_pub_sub_driver
    end
    self.authorization_driver = nil
    self.transport_middleware_require_user = true
  end

  self.api_path = '/isomorfeus/api/endpoint'
end
