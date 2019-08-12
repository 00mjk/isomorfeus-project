module Isomorfeus
  # available settings

  if RUBY_ENGINE == 'opal'
    def self.add_transport_init_class_name(init_class_name)
      transport_init_class_names << init_class_name
    end

    add_client_option(:api_websocket_path)
    add_client_option(:transport_init_class_names, [])
  else
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

      def valid_channel_class_names
        @valid_channel_class_names ||= Set.new
      end

      def valid_channel_class_name?(class_name)
        valid_channel_class_names.include?(class_name)
      end

      def add_valid_channel_class(klass)
        class_name = klass.name
        class_name = class_name.split('>::').last if class_name.start_with?('#<')
        valid_channel_class_names << class_name
      end

      def valid_handler_class_names
        @valid_handler_class_names ||= Set.new
      end

      def valid_handler_class_name?(class_name)
        valid_handler_class_names.include?(class_name)
      end

      def add_valid_handler_class(klass)
        class_name = klass.name
        class_name = class_name.split('>::').last if class_name.start_with?('#<')
        valid_handler_class_names << class_name
      end

      def cached_handler_classes
        @cached_handler_classes ||= {}
      end

      def cached_handler_class(class_name)
        return cached_handler_classes[class_name] if cached_handler_classes.key?(class_name)
        cached_handler_classes[class_name] = "::#{class_name}".constantize
      end
    end
    self.middlewares = Set.new
  end

  # defaults
  self.api_websocket_path = '/isomorfeus/api/websocket'
end
