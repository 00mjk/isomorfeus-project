# frozen_string_literal: true

module Isomorfeus
  module Data
    module Handler
      class Arango < LucidHandler::Base
        on_request do |pub_sub_client, current_user, response_agent|
          # promise_send_path('Isomorfeus::Data::Handler::Generic', action, type, self.to_s, props_hash)
          response_agent.request.each_key do |action|
            if action == 'load'
              response_agent.request[action].each_key do |type|
                if %w[collection graph document edge].include?(type)
                  response_agent.request.each_key do |type_class_name|
                    if Isomorfeus.send("valid_#{type}_class_name?", type_class_name)
                      type_class = Isomorfeus.send("cached_#{type}_class", type_class_name)
                      if type_class
                        props_json = response_agent.request[type_class_name]
                        begin
                          props = Oj.load(props_json, mode: :strict)
                          props.merge!({pub_sub_client: pub_sub_client, current_user: current_user})
                          if current_user.authorized?(type_class, :load, *props)
                            loaded_type = type_class.load(props)
                            loaded_type.instance_exec do
                              type_class.on_load_block.call(pub_sub_client, current_user) if type_class.on_load_block
                            end
                            response_agent.outer_result = { data: loaded_type.to_transport }
                            if %w[collection graph].include?(type)
                              response_agent.outer_result.deep_merge!(data: loaded_type.included_items_to_transport)
                            end
                            response_agent.agent_result = { success: 'ok' }
                          else
                            response_agent.error = { error: 'Access denied!' }
                          end
                        rescue Exception => e
                          response_agent.error = { error: { type_class_name => "Isomorfeus::Data::Handler::Arango: #{e.message}" }}
                        end
                      else
                        response_agent.error = { error: { type_class_name => 'No such thing!' }}
                      end
                    else
                      response_agent.error = { error: { type_class_name => 'No such thing!' }}
                    end
                  end
                else
                  response_agent.error = { error: { type => 'No such thing!' }}
                end
              end
            elsif action == 'store'
            else
              response_agent.error = { error: { action => 'No such thing!' }}
            end
          end
        end
      end
    end
  end
end
