# frozen_string_literal: true

module Isomorfeus
  module Data
    module Handler
      class Object < LucidHandler::Base
        on_request do |response_agent|
          # promise_send_path('Isomorfeus::Data::Handler::Object', action, object_hash)
          response_agent.request.each_key do |array_class_name|
            if Isomorfeus.valid_array_class_name?(array_class_name)
              array_class = Isomorfeus.cached_array_class(array_class_name)
              if array_class
                props_json = response_agent.request[array_class_name]
                begin
                  props = Oj.load(props_json, mode: :strict)
                  if current_user.authorized?(array_class, :load, *props)
                    array = array_class.load(props)
                    array.instance_exec do
                      array_class.on_load_block.call() if array_class.on_load_block
                    end
                    response_agent.outer_result = { data: array.to_transport }
                    response_agent.agent_result = { success: 'ok' }
                  else
                    response_agent.error = { error: 'Access denied!' }
                  end
                rescue Exception => e
                  response_agent.error = { error: { array_class_name => "Isomorfeus::Data::Handler::Object: #{e.message}" }}
                end
              else
                response_agent.error = { error: { array_class_name => 'No such thing!' }}
              end
            else
              response_agent.error = { error: { array_class_name => 'No such thing!' }}
            end
          end
        end
      end
    end
  end
end
