module LucidData
  module Query
    module Mixin
      def self.included(base)
        base.extend(LucidPropDeclaration::Mixin)

        if RUBY_ENGINE == 'opal'
          base.instance_exec do
            def execute(props:)
              query_result_instance = LucidData::QueryResult.new
              promise_execute(props: props, query_result_instance: query_result_instance) unless query_result_instance.loaded?
              query_result_instance
            end

            def promise_execute(props:, query_result_instance: nil)
              query_result_instance = LucidData::QueryResult.new unless query_result_instance
              props.each_key do |prop_name|
                Isomorfeus.raise_error(message: "#{self.to_s} No such query prop declared: '#{prop_name}'!") unless declared_props.key?(prop_name)
              end
              validate_props(props)
              data_props = { props: props, query_result_instance_key: query_result_instance.key }
              props_json = data_props.to_json
              Isomorfeus::Transport.promise_send_path( 'Isomorfeus::Data::Handler::Generic', self.name, :execute, props_json).then do |agent|
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

            def execute_query(_); end
          end
        else
          unless base == LucidData::Node::Base || base == LucidData::Document::Base || base == LucidData::Vertex::Base
            Isomorfeus.add_valid_data_class(base)
          end

          base.instance_exec do
            def promise_execute(props:)
              instance = self.execute(props: props)
              result_promise = Promise.new
              result_promise.resolve(instance)
              result_promise
            end

            def execute(props:, query_result_instance_key: nil)
              props.each_key do |prop_name|
                Isomorfeus.raise_error(message: "#{self.to_s} No such query prop declared: '#{prop_name}'!") unless declared_props.key?(prop_name)
              end
              validate_props(props)
              query_result = LucidData::QueryResult.new(key: query_result_instance_key)
              query_result.result_set = instance_exec(props: LucidProps.new(props), &@_query_block)
              query_result
            end

            def execute_query(&block)
              @_query_block = block
            end

            def current_user
              Isomorfeus.current_user
            end

            def pub_sub_client
              Isomorfeus.pub_sub_client
            end
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
  end
end
