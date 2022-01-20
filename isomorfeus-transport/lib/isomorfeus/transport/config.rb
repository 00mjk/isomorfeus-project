module Isomorfeus
  # available settings
  class << self
    def cached_channel_classes
      @cached_channel_classes ||= {}
    end

    def cached_channel_class(class_name)
      return "::#{class_name}".constantize if Isomorfeus.development?
      return cached_channel_classes[class_name] if cached_channel_classes.key?(class_name)
      cached_channel_classes[class_name] = "::#{class_name}".constantize
    end

    def valid_channel_class_names
      @valid_channel_class_names ||= Set.new
    end

    def add_valid_channel_class(klass)
      valid_channel_class_names << raw_class_name(klass)
    end

    def raw_class_name(klass)
      class_name = klass.name
      class_name = class_name.split('>::').last if class_name.start_with?('#<')
      class_name
    end
  end

  if RUBY_ENGINE == 'opal'
    add_client_option(:api_websocket_host)
    add_client_option(:api_websocket_port)
    add_client_option(:api_websocket_path)
    add_client_option(:api_logout_path)
    add_client_option(:cookie_eater_path)
    add_client_option(:transport_init_class_names, [])

    class << self
      def valid_channel_class_name?(class_name)
        cached_channel_class(class_name) # because of autoloader
        valid_channel_class_names.include?(class_name)
      end

      def add_transport_init_class_name(init_class_name)
        transport_init_class_names << init_class_name
      end

      def current_user
        @current_user ||= init_current_user
      end

      def init_current_user
        if Isomorfeus.current_user_sid
          Isomorfeus.instance_from_sid(Isomorfeus.current_user_sid)
        else
          Anonymous.new
        end
      end

      def set_current_user(user)
        if user
          @current_user = user
          Isomorfeus.current_user_sid = user.sid
        else
          @current_user = Anonymous.new
        end
      end
    end
  else
    class << self
      attr_accessor :api_websocket_host
      attr_accessor :api_websocket_port
      attr_accessor :api_websocket_path
      attr_accessor :api_logout_path
      attr_accessor :cookie_eater_path
      attr_reader :session_store

      def valid_channel_class_name?(class_name)
        valid_channel_class_names.include?(class_name)
      end

      def add_middleware(middleware)
        Isomorfeus.middlewares << middleware
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

      def middlewares
        @middlewares ||= Set.new
      end

      def valid_handler_class_names
        @valid_handler_class_names ||= Set.new
      end

      def valid_handler_class_name?(class_name)
        valid_handler_class_names.include?(class_name)
      end

      def add_valid_handler_class(klass)
        valid_handler_class_names << raw_class_name(klass)
      end

      def cached_handler_classes
        @cached_handler_classes ||= {}
      end

      def cached_handler_class(class_name)
        return "::#{class_name}".constantize if Isomorfeus.development?
        return cached_handler_classes[class_name] if cached_handler_classes.key?(class_name)
        cached_handler_classes[class_name] = "::#{class_name}".constantize
      end

      def valid_user_class_names
        @valid_user_class_names ||= Set.new
      end

      def valid_user_class_name?(class_name)
        valid_user_class_names.include?(class_name)
      end

      def add_valid_user_class(klass)
        valid_user_class_names << raw_class_name(klass)
      end

      def cached_user_classes
        @cached_user_classes ||= {}
      end

      def cached_user_class(class_name)
        return "::#{class_name}".constantize if Isomorfeus.development?
        return cached_user_classes[class_name] if cached_user_classes.key?(class_name)
        cached_user_classes[class_name] = "::#{class_name}".constantize
      end

      def current_user
        Thread.current[:isomorfeus_user]
      end

      def pub_sub_client
        Thread.current[:isomorfeus_pub_sub_client]
      end

      def session_store
        @session_store ||= @session_store_init.call
      end

      def session_store_init(&block)
        @session_store_init = block
      end
    end

    self.session_store_init do
      store_path = File.expand_path(File.join(Isomorfeus.root, 'data', Isomorfeus.env, 'session_store'))
      Isomorfeus::Transport::HamsterSessionStore.new(store_path)
    end
  end

  # defaults
  self.api_websocket_host = 'localhost'
  self.api_websocket_port = '3000'
  self.api_websocket_path = '/isomorfeus/api/websocket'
  self.api_logout_path    = '/isomorfeus/api/logout'
  self.cookie_eater_path  = '/isomorfeus/cookie/eat'
end
