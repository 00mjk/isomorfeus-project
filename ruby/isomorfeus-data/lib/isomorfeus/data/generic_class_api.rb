module Isomorfeus
  module Data
    module GenericClassApi
      if RUBY_ENGINE == 'opal'
        def destroy(key:)
          promise_destroy(key: key)
          true
        end

        def promise_destroy(key:)
          Isomorfeus::Transport.promise_send_path( 'Isomorfeus::Data::Handler::Generic', self.name, :destroy, key: key).then do |agent|
            if agent.processed
              agent.result
            else
              agent.processed = true
              if agent.response.key?(:error)
                Isomorfeus.raise_error(message: agent.response[:error])
              end
              Isomorfeus.store.dispatch(type: 'DATA_DESTROY', data: [self.name, key])
              agent.result = true
            end
          end
        end

        def load(key:)
          instance = self.new(key: key)
          promise_load(key: key, instance: instance) unless instance.loaded?
          instance
        end

        def promise_load(key:, instance: nil)
          instance = self.new(key: key) unless instance
          Isomorfeus::Transport.promise_send_path( 'Isomorfeus::Data::Handler::Generic', self.name, :load, key: key).then do |agent|
            if agent.processed
              agent.result
            else
              agent.processed = true
              if agent.response.key?(:error)
                Isomorfeus.raise_error(message: agent.response[:error])
              end
              instance._load_from_store!
              Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: agent.full_response[:data])
              agent.result = instance
            end
          end
        end

        # execute
        def execute_create(_); end
        def execute_destroy(_); end
        def execute_load(_); end
        def execute_save(_); end
      else
        def destroy(key:)
          !!instance_exec(key: key, &@_destroy_block)
        end

        def promise_load(key:)
          instance = self.load(key: key)
          result_promise = Promise.new
          result_promise.resolve(instance)
          result_promise
        end

        def load(key:)
          data = instance_exec(key: key, &@_load_block)
          return nil unless data
          return data if data.class == self
          Isomorfeus.raise_error(message: "#{self.to_s}: execute_load must return a instance of #{self.to_s} or nil. Returned was: #{data.class}.") if data.class != self
          data
        end

        # execute
        def execute_create(&block)
          @_create_block = block
        end

        def execute_destroy(&block)
          @_destroy_block = block
        end

        def execute_load(&block)
          @_load_block = block
        end

        def execute_save(&block)
          @_save_block = block
        end
      end

      def create(key:, **things)
        new(key: key, **things).create
      end

      def promise_create(key:, **things)
        new(key: key, **things).promise_create
      end

      def save(instance:)
        instance.save
      end

      def promise_save(instance:)
        instance.promise_save
      end

      def current_user
        Isomorfeus.current_user
      end

      def pub_sub_client
        Isomorfeus.pub_sub_client
      end
    end
  end
end
