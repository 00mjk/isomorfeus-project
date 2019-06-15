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
      attr_accessor :middlewares
      attr_accessor :transport_middleware_requires_user
      attr_accessor :server_pub_sub_driver

      def add_middleware(middleware)
        Isomorfeus.middlewares << middleware unless Isomorfeus.middlewares.include?(middleware)
      end

      def insert_middleware_after(existing_middleware, new_middleware)
        index_of_existing = Isomorfeus.middlewares.index(existing_middleware)
        unless Isomorfeus.middlewares.include?(new_middleware)
          if index_of_existing
            Isomorfeus.middlewares.insert(index_of_existing + 1, new_middleware)
          else
            Isomorfeus.middlewares << new_middleware
          end
        end
      end

      def insert_middleware_before(existing_middleware, new_middleware)
        index_of_existing = Isomorfeus.middlewares.index(existing_middleware)
        unless Isomorfeus.middlewares.include?(new_middleware)
          if index_of_existing
            Isomorfeus.middlewares.insert(index_of_existing, new_middleware)
          else
            Isomorfeus.middlewares << new_middleware
          end
        end
      end
    end
    self.authorization_driver = nil
    self.middlewares = Set.new
    self.transport_middleware_requires_user = true
  end

  self.api_path = '/isomorfeus/api/endpoint'
end
