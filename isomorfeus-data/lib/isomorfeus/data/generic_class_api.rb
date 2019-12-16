module Isomorfeus
  module Data
    module GenericClassApi
      if RUBY_ENGINE == 'opal'
        def create(key:, **things)
          instance = new(key: key, **things)
          instance.promise_save
          instance
        end

        def promise_create(key:, **things)
          new(key: key, **things).promise_save
        end

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
                `console.error(#{agent.response[:error].to_n})`
                raise agent.response[:error]
              end
              Isomorfeus.store.dispatch(type: 'DATA_DESTROY', data: agent.full_response[:data])
              agent.result = true
            end
          end
        end

        def load(key:)
          instance = self.new(key: key)
          self.promise_load(key: key, instance: instance) unless instance.loaded?
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
                `console.error(#{agent.response[:error].to_n})`
                raise agent.response[:error]
              end
              instance._load_from_store!
              Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: agent.full_response[:data])
              agent.result = instance
            end
          end
        end

        def promise_query(props = {})
          validate_props(props)
          props_json = props.to_json
          instance = self.new(key) unless instance
          Isomorfeus::Transport.promise_send_path( 'Isomorfeus::Data::Handler::Generic', self.name, 'query', props_json).then do |agent|
            if agent.processed
              agent.result
            else
              agent.processed = true
              if agent.response.key?(:error)
                `console.error(#{agent.response[:error].to_n})`
                raise agent.response[:error]
              end
              Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: agent.full_response[:data])
              agent.result = instance
            end
          end
        end

        # execute
        def execute_destroy(_); end
        def execute_load(_); end
        def execute_query(_); end
        def execute_save(_); end

        # callbacks
        def on_destroy(_); end
        def on_load(_); end
        def on_query(_); end
        def on_save(_); end
      else
        def promise_create(key:, **things)
          instance = self.create(key: key, **things)
          result_promise = Promise.new
          result_promise.resolve(instance)
          result_promise
        end

        def promise_destroy(key:)
          self.destroy(key: key)
          result_promise = Promise.new
          result_promise.resolve(true)
          result_promise
        end

        def promise_load(key:)
          instance = self.load(key: key)
          result_promise = Promise.new
          result_promise.resolve(instance)
          result_promise
        end

        def promise_query(props)
          instance = self.query(props)
          result_promise = Promise.new
          result_promise.resolve(instance)
          result_promise
        end

        # execute
        def execute_destroy(&block)
          @_destroy_block = block
        end

        def execute_load(&block)
          @_load_block = block
        end

        def execute_query(&block)
          @_query_block = block
        end

        def execute_save(&block)
          @_save_block = block
        end

        # callbacks
        def on_destroy(&block)
          @_on_destroy_block = block
        end

        def on_load(&block)
          @_on_load_block = block
        end

        def on_query(&block)
          @_on_query_block = block
        end

        def on_save(&block)
          @_on_save_block = block
        end
      end
    end
  end
end
