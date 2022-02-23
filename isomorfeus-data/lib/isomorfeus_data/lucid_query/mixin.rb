module LucidQuery
  module Mixin
    def self.included(base)
      base.extend(LucidPropDeclaration::Mixin)
      base.include(LucidI18n::Mixin)

      if RUBY_ENGINE == 'opal'
        base.instance_exec do
          def _generate_auto_key(props_s)
            component = nil
            component_name = '_'
            %x{
              let c = Opal.Preact.active_component();
              if (typeof c?.__ruby_instance !== 'undefined') { component = c.__ruby_instance; }
            }
            component_name = component.class.name if component
            "#{component_name}:_:#{self.name}:#{props_s}"
          end

          def _should_return?(lqri, gak)
            if on_ssr?
              lqri.loaded? && gak
            else on_browser?
              if Isomorfeus::TopLevel.hydrated
                if Isomorfeus::TopLevel.first_pass
                  lqri.loaded?
                else
                  lqri.loaded? && !gak
                end
              else
                lqri.loaded? && !gak
              end
            end
          end

          def execute(key: nil, **props)
            gak = key ? false : true
            key = _generate_auto_key(`JSON.stringify(props)`) unless key

            lqri = LucidQueryResult.new(key: key)
            return lqri if _should_return?(lqri, gak)
            props[:query_result_instance] = lqri
            promise_execute(key: gak ? nil : key, **props)
            lqri
          end

          def promise_execute(key: nil, **props)
            gak = key ? false : true
            key = _generate_auto_key(`JSON.stringify(props)`) unless key

            lqri = props.delete(:query_result_instance)
            lqri = LucidQueryResult.new(key: key) unless lqri
            return Promise.new.resolve(lqri) if _should_return?(lqri, gak)

            props.each_key do |prop_name|
              Isomorfeus.raise_error(message: "#{self.to_s} No such query prop declared: '#{prop_name}'!") unless declared_props.key?(prop_name)
            end
            props = validated_props(props)
            props[:key] = lqri.key
            Isomorfeus::Transport.promise_send_path( 'Isomorfeus::Data::Handler::Generic', self.name, :execute, props).then do |agent|
              agent.process do
                lqri._load_from_store!
                Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: agent.full_response[:data])
                lqri
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
