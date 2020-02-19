module Isomorfeus
  # available settings

  if RUBY_ENGINE == 'opal'
    add_client_option(:api_websocket_path)
    add_client_option(:cookie_eater_path)
    add_client_option(:transport_init_class_names, [])

    def self.add_transport_init_class_name(init_class_name)
      transport_init_class_names << init_class_name
    end

    def self.current_user
      @current_user ||= init_current_user
    end

    def self.init_current_user
      if Isomorfeus.current_user_sid
        Isomorfeus.instance_from_sid(Isomorfeus.current_user_sid)
      else
        Anonymous.new
      end
    end

    def self.set_current_user(user)
      if user
        @current_user = user
        Isomorfeus.current_user_sid = user.to_sid
      else
        @current_user = Anonymous.new
      end
    end
  else
    class << self
      attr_accessor :api_websocket_path
      attr_accessor :cookie_eater_path
      attr_accessor :session_store
      attr_accessor :cookie_dbm_path

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

      def valid_channel_class_name?(class_name)
        valid_channel_class_names.include?(class_name)
      end

      def add_valid_channel_class(klass)
        valid_channel_class_names << raw_class_name(klass)
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

      def raw_class_name(klass)
        class_name = klass.name
        class_name = class_name.split('>::').last if class_name.start_with?('#<')
        class_name
      end

      def current_user
        Thread.current[:isomorfeus_user]
      end

      def pub_sub_client
        Thread.current[:isomorfeus_pub_sub_client]
      end
    end

    self.cookie_dbm_path = 'cookie'
    self.session_store = Isomorfeus::Transport::DbmSessionStore.new # dont use this one, but we keep it here to have at least something
  end

  # defaults
  self.api_websocket_path = '/isomorfeus/api/websocket'
  self.cookie_eater_path = '/isomorfeus/cookie/eat'
end
