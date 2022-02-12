module LucidQuery
  module Mixin
    def self.included(base)
      base.extend(LucidPropDeclaration::Mixin)

      if RUBY_ENGINE == 'opal'
        base.instance_exec do
          def execute(key: nil, **props)
            props[:query_result_instance] = LucidQueryResult.new(key: key)
            promise_execute(props) unless props[:query_result_instance].loaded?
            props[:query_result_instance]
          end

          def promise_execute(key: nil, **props)
            query_result_instance = props.delete(:query_result_instance)
            query_result_instance = LucidQueryResult.new(key: key) unless query_result_instance

            return Promise.new.resolve(query_result_instance) if query_result_instance.loaded?

            props.each_key do |prop_name|
              Isomorfeus.raise_error(message: "#{self.to_s} No such query prop declared: '#{prop_name}'!") unless declared_props.key?(prop_name)
            end
            props = validated_props(props)
            props[:key] = query_result_instance.key
            Isomorfeus::Transport.promise_send_path( 'Isomorfeus::Data::Handler::Generic', self.name, :execute, props).then do |agent|
              agent.process do
                query_result_instance._load_from_store!
                Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: agent.full_response[:data])
                query_result_instance
              end
            end
          end

          def execute_query(_); end
        end
      else
        unless base == LucidQuery::Base
          Isomorfeus.add_valid_data_class(base)
        end

        base.instance_exec do
          def promise_execute(**props)
            instance = self.execute(**props)
            result_promise = Promise.new
            result_promise.resolve(instance)
            result_promise
          end

          def execute(**props)
            key = props.delete(:key)
            result_set = self.new(**props).instance_exec(&@_query_block)
            LucidQueryResult.new(key: key, result_set: result_set)
          end

          def execute_query(&block)
            @_query_block = block
          end
        end

        attr_reader :props

        def initialize(**props_hash)
          props_hash = self.class.validated_props(props_hash)
          @props = LucidProps.new(props_hash)
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
