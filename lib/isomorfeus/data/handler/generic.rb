# frozen_string_literal: true

module Isomorfeus
  module Data
    module Handler
      class Generic < LucidHandler::Base
        # responsible for loading:
        # LucidGenericEdge
        # LucidGenericNode
        # LucidGenericCollection

        def process_request(pub_sub_client, current_user, response_agent)
          # promise_send_path('Isomorfeus::Data::Handler::Generic', type, self.to_s, action, props_hash)
          response_agent.request.each_key do |type|
            if %w[collection node edge].include?(type)
              response_agent.request[type].each_key do |type_class_name|
                if Isomorfeus.send("valid_generic_#{type}_class_name?", type_class_name)
                  type_class = Isomorfeus.send("cached_generic_#{type}_class", type_class_name)
                  if type_class
                    response_agent.request[type][type_class_name].each_key do |action|
                      if action == 'load' then process_load(pub_sub_client, current_user, response_agent, type, type_class, type_class_name, action)
                      elsif action == 'store' then process_store(pub_sub_client, current_user, response_agent, type, type_class, type_class_name, action)
                      else response_agent.error = { error: { action => 'No such thing!' }}
                      end
                    end
                  else response_agent.error = { error: { type_class_name => 'No such thing!' }}
                  end
                else response_agent.error = { error: { type_class_name => 'No such thing!' }}
                end
              end
            else response_agent.error = { error: { type => 'No such thing!' }}
            end
          end
        rescue Exception => e
          response_agent.error = if Isomorfeus.production? then { error: 'No such thing!' }
                                 else { error: "Isomorfeus::Data::Handler::Generic: #{e.message}" }
                                 end
        end

        def process_load(pub_sub_client, current_user, response_agent, type, type_class, type_class_name, action)
          props_json = response_agent.request[type][type_class_name][action]
          props = Oj.load(props_json, mode: :strict)
          props.merge!(pub_sub_client: pub_sub_client, current_user: current_user)
          if current_user.authorized?(type_class, :load, *props)
            loaded_type = type_class.load(props)
            loaded_type.instance_exec do
              type_class.on_load_block.call(pub_sub_client, current_user) if type_class.on_load_block
            end
            response_agent.outer_result = { data: loaded_type.to_transport }
            if %w[collection].include?(type)
              response_agent.outer_result.deep_merge!(data: loaded_type.included_items_to_transport)
            end
            response_agent.agent_result = { success: 'ok' }
          else response_agent.error = { error: 'Access denied!' }
          end
        end

        def process_store(pub_sub_client, current_user, response_agent, type, type_class, type_class_name, action)
          props_json = response_agent.request[type][type_class_name][action]
          props = Oj.load(props_json, mode: :strict)
          props.merge!(pub_sub_client: pub_sub_client, current_user: current_user)
          if current_user.authorized?(type_class, :store, *props)
            stored_type = type_class.new(props).store
            stored_type.instance_exec do
              type_class.on_store_block.call(pub_sub_client, current_user) if type_class.on_store_block
            end
            response_agent.outer_result = { data: stored_type.to_transport }
            response_agent.agent_result = { success: 'ok' }
          else response_agent.error = { error: 'Access denied!' }
          end
        end
      end
    end
  end
end
