module Isomorfeus
  # available settings

  if RUBY_ENGINE == 'opal'
    add_client_option(:api_websocket_path)
  else
    # defaults
    class << self
      attr_accessor :api_websocket_path
      attr_accessor :middlewares

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
    self.middlewares = Set.new
  end

  self.api_websocket_path = '/isomorfeus/api/websocket'
end
