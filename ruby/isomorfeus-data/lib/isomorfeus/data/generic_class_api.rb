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
                Isomorfeus.raise_error(message: agent.response[:error])
              end
              Isomorfeus.store.dispatch(type: 'DATA_DESTROY', data: agent.full_response[:data])
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
                `console.error(#{agent.response[:error].to_n})`
                Isomorfeus.raise_error(message: agent.response[:error])
              end
              instance._load_from_store!
              Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: agent.full_response[:data])
              agent.result = instance
            end
          end
        end

        def query(props:)
          query_result_instance = LucidData::QueryResult.new
          promise_query(props: props, query_result_instance: query_result_instance) unless query_result_instance.loaded?
          query_result_instance
        end

        def promise_query(props:, query_result_instance: nil)
          query_result_instance = LucidData::QueryResult.new unless query_result_instance
          props.each_key do |prop_name|
            Isomorfeus.raise_error(message: "#{self.to_s} No such query prop declared: '#{prop_name}'!") unless declared_props.key?(prop_name)
          end
          validate_props(props)
          data_props = { props: props, query_result_instance_key: query_result_instance.key }
          props_json = data_props.to_json
          Isomorfeus::Transport.promise_send_path( 'Isomorfeus::Data::Handler::Generic', self.name, :query, props_json).then do |agent|
            if agent.processed
              agent.result
            else
              agent.processed = true
              if agent.response.key?(:error)
                `console.error(#{agent.response[:error].to_n})`
                Isomorfeus.raise_error(message: agent.response[:error])
              end
              query_result_instance._load_from_store!
              Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: agent.full_response[:data])
              agent.result = query_result_instance
            end
          end
        end

        # execute
        def execute_destroy(_); end
        def execute_load(_); end
        def execute_query(_); end
        def execute_save(_); end
      else
        def promise_create(key:, **things)
          instance = self.create(key: key, **things)
          result_promise = Promise.new
          result_promise.resolve(instance)
          result_promise
        end

        def promise_destroy(key:)
          sid = self.destroy(key: key)
          result_promise = Promise.new
          result_promise.resolve(sid)
          result_promise
        end

        def destroy(key:, pub_sub_client: nil, current_user: nil)
          instance_exec(key: key, pub_sub_client: pub_sub_client, current_user: current_user, &@_destroy_block)
        end

        def promise_load(key:)
          instance = self.load(key: key)
          result_promise = Promise.new
          result_promise.resolve(instance)
          result_promise
        end

        def promise_query(props:)
          instance = self.query(props: props)
          result_promise = Promise.new
          result_promise.resolve(instance)
          result_promise
        end

        def query(props:, query_result_instance_key: nil, pub_sub_client: nil, current_user: nil)
          props.each_key do |prop_name|
            Isomorfeus.raise_error(message: "#{self.to_s} No such query prop declared: '#{prop_name}'!") unless declared_props.key?(prop_name)
          end
          validate_props(props)
          query_result = LucidData::QueryResult.new(key: query_result_instance_key)
          query_result.result_set = instance_exec(props: Isomorfeus::Transport::PropsProxy.new(props),
                                                  pub_sub_client: pub_sub_client, current_user: current_user, &@_query_block)
          query_result
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
      end
    end
  end
end
