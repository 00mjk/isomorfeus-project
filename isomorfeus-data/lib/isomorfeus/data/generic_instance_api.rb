module Isomorfeus
  module Data
    module GenericInstanceApi
      def key
        @key
      end

      def key=(k)
        @key = k.to_s
      end

      def changed?
        @_changed
      end

      def revision
        @_revision
      end

      def sid
        [@class_name, @key]
      end

      def sid_s
        "[#{@class_name}|#{@key}]"
      end

      if RUBY_ENGINE == 'opal'
        def loaded?
          Redux.fetch_by_path(*@_store_path) ? true : false
        end

        def create
          promise_create
          self
        end

        def promise_create
          data_hash = { instance: to_transport }
          data_hash.deep_merge!(included_items: included_items_to_transport) if respond_to?(:included_items_to_transport)
          class_name = self.class.name
          Isomorfeus::Transport.promise_send_path( 'Isomorfeus::Data::Handler::Generic', class_name, :create, data_hash).then do |agent|
            if agent.processed
              agent.result
            else
              agent.processed = true
              if agent.response.key?(:error)
                Isomorfeus.raise_error(message: agent.response[:error])
              end
              data = agent.full_response[:data]
              if data.key?(class_name) && data[class_name].key?(@key) && data[class_name][@key].key?('new_key')
                @key = data[class_name][@key]['new_key']
                @revision = data[class_name][@key]['revision'] if data[class_name][@key].key?('revision')
                _update_paths
              end
              _load_from_store!
              Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: data)
              agent.result = self
            end
          end
        end

        def destroy
          promise_destroy
          nil
        end

        def promise_destroy
          self.class.promise_destroy(key: @key)
        end

        def reload
          self.class.promise_load!(key: @key, instance: self)
          self
        end

        def promise_reload
          self.class.promise_load!(key: @key, instance: self)
        end

        def save
          promise_save
          self
        end

        def promise_save
          data_hash = { instance: to_transport }
          data_hash.deep_merge!(included_items: included_items_to_transport) if respond_to?(:included_items_to_transport)
          class_name = self.class.name
          Isomorfeus::Transport.promise_send_path( 'Isomorfeus::Data::Handler::Generic', class_name, :save, data_hash).then do |agent|
            if agent.processed
              agent.result
            else
              agent.processed = true
              if agent.response.key?(:error)
                Isomorfeus.raise_error(message: agent.response[:error])
              end
              data = agent.full_response[:data]
              if data.key?(class_name) && data[class_name].key?(@key) && data[class_name][@key].key?('new_key')
                @key = data[class_name][@key]['new_key']
                @revision = data[class_name][@key]['revision'] if data[class_name][@key].key?('revision')
                _update_paths
              end
              _load_from_store!
              Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: data)
              agent.result = self
            end
          end
        end
      else # RUBY_ENGINE
        def loaded?
          true
        end

        def create
          previous_key = self.key
          instance = instance_exec(&self.class.instance_variable_get(:@_create_block))
          return nil unless instance
          Isomorfeus.raise_error(message: "#{self.to_s}: execute_create must return self or nil. Returned was: #{instance.class}.") if instance != self
          instance_variable_set(:@previous_key, previous_key) if key != previous_key
          _unchange!
          self
        end

        def promise_create
          promise = Promise.new
          promise.resolve(create)
        end

        def destroy
          self.class.destroy(key: @key)
        end

        def promise_destroy
          self.class.promise_destroy(key: @key)
        end

        # reload must be implemented by mixin

        def promise_reload
          Promise.new.resolve(reload)
        end

        def save
          previous_key = self.key
          instance = instance_exec(&self.class.instance_variable_get(:@_save_block))
          return nil unless instance
          Isomorfeus.raise_error(message: "#{self.to_s}: execute_save must return self or nil. Returned was: #{instance.class}.") if instance != self
          instance_variable_set(:@previous_key, previous_key) if key != previous_key
          _unchange!
          self
        end

        def promise_save
          promise = Promise.new
          promise.resolve(save)
        end
      end # RUBY_ENGINE

      def current_user
        Isomorfeus.current_user
      end

      def pub_sub_client
        Isomorfeus.pub_sub_client
      end
    end
  end
end
