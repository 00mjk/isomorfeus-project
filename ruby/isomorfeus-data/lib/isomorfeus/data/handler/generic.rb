# frozen_string_literal: true

module Isomorfeus
  module Data
    module Handler
      class Generic < LucidHandler::Base
        # responsible for loading:
        # LucidData::Array
        # LucidData::Hash
        # LucidData::Edge
        # LucidData::Document
        # LucidData::Collection
        # LucidData::EdgeCollection
        # LucidData::Graph
        # LucidData::Composition

        def process_request(response_agent)
          # promise_send_path('Isomorfeus::Data::Handler::Generic', self.to_s, action, props_hash)
          response_agent.request.each_key do |type_class_name|
            if Isomorfeus.valid_data_class_name?(type_class_name)
              type_class = Isomorfeus.cached_data_class(type_class_name)
              if type_class
                response_agent.request[type_class_name].each_key do |action|
                  case action
                  when 'load' then process_load(response_agent, type_class, type_class_name)
                  when 'execute' then process_execute(response_agent, type_class, type_class_name)
                  when 'save' then process_save(response_agent, type_class, type_class_name)
                  when 'destroy' then process_destroy(response_agent, type_class, type_class_name)
                  else response_agent.error = { error: { action => 'No such thing!' }}
                  end
                end
              else response_agent.error = { error: { type_class_name => 'No such class!' }}
              end
            else response_agent.error = { error: { type_class_name => 'Not a valid LucidData class!' }}
            end
          end
        rescue Exception => e
          response_agent.error = { error: "Isomorfeus::Data::Handler::Generic: #{e.message}\n#{e.backtrace.join("\n")}" }
        end

        def process_load(response_agent, type_class, type_class_name)
          # 'Isomorfeus::Data::Handler::Generic', self.name, :load, key: key
          props = response_agent.request[type_class_name]['load']
          props.transform_keys!(&:to_sym)
          if Isomorfeus.current_user.authorized?(type_class, :load, props)
            loaded_type = type_class.load(**props)
            if loaded_type
              response_agent.outer_result = {} unless response_agent.outer_result
              response_agent.outer_result.deep_merge!(data: loaded_type.to_transport)
              if loaded_type.respond_to?(:included_items_to_transport)
                response_agent.outer_result.deep_merge!(data: loaded_type.included_items_to_transport)
              end
              response_agent.agent_result = { success: 'ok' }
            else response_agent.error = { error: { type_class_name => 'Load returned nothing!' }}
            end
          else response_agent.error = { error: 'Access denied!' }
          end
        end

        def process_execute(response_agent, type_class, type_class_name)
          # 'Isomorfeus::Data::Handler::Generic', self.name, :execute, props_json
          props = response_agent.request[type_class_name]['execute']
          props.transform_keys!(&:to_sym)
          props[:props].transform_keys!(&:to_sym)
          if Isomorfeus.current_user.authorized?(type_class, :execute, props[:props])
            queried_type = type_class.execute(**props)
            if queried_type
              response_agent.outer_result = {} unless response_agent.outer_result
              response_agent.outer_result.deep_merge!(data: queried_type.to_transport)
              if queried_type.respond_to?(:included_items_to_transport)
                response_agent.outer_result.deep_merge!(data: queried_type.included_items_to_transport)
              end
              response_agent.agent_result = { success: 'ok' }
            else response_agent.error = { error: { type_class_name => 'Query returned nothing!' }}
            end
          else response_agent.error = { error: 'Access denied!' }
          end
        end

        def process_save(response_agent, type_class, type_class_name)
          # 'Isomorfeus::Data::Handler::Generic', self.name, :save, data_hash
          data = response_agent.request[type_class_name]['save']
          instance_data = data['instance']
          included_items_data = data.key?('included_items') ? data['included_items'] : nil
          if Isomorfeus.current_user.authorized?(type_class, :save, data)
            instance = type_class.instance_from_transport(instance_data, included_items_data)
            saved_type = type_class.save(instance: instance)
            if saved_type
              response_agent.outer_result = {} unless response_agent.outer_result
              response_agent.outer_result.deep_merge!(data: saved_type.to_transport)
              if saved_type.respond_to?(:included_items_to_transport)
                response_agent.outer_result.deep_merge!(data: saved_type.included_items_to_transport)
              end
              response_agent.agent_result = { success: 'ok' }
            else response_agent.error = { error: { type_class_name => 'Save returned nothing!' }}
            end
          else response_agent.error = { error: 'Access denied!' }
          end
        end

        def process_destroy(response_agent, type_class, type_class_name)
          props = response_agent.request[type_class_name]['destroy']
          props.transform_keys!(&:to_sym)
          if Isomorfeus.current_user.authorized?(type_class, :destroy, props)
            result = type_class.destroy(**props)
            if result
              response_agent.agent_result = { success: 'ok' }
            else
              response_agent.error = { error: { type_class_name => 'Destroy failed!' }}
            end
          else response_agent.error = { error: 'Access denied!' }
          end
        end
      end
    end
  end
end
