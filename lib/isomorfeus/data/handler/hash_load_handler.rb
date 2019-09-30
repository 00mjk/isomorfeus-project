# frozen_string_literal: true

module Isomorfeus
  module Data
    module Handler
      class HashLoadHandler < LucidHandler::Base
        on_request do |pub_sub_client, current_user, response_agent|
          # promise_send_path('Isomorfeus::Data::Handler::HashLoadHandler', self.to_s, props_hash)
          response_agent.request.each_key do |hash_class_name|
            if Isomorfeus.valid_hash_class_name?(hash_class_name)
              hash_class = Isomorfeus.cached_hash_class(hash_class_name)
              if hash_class
                props_json = response_agent.request[hash_class_name]
                begin
                  props = Oj.load(props_json, mode: :strict)
                  props.merge!({pub_sub_client: pub_sub_client, current_user: current_user})
                  if current_user.authorized?(hash_class, :load, *props)
                    hash = hash_class.load(props)
                    hash.instance_exec do
                      hash_class.on_load_block.call(pub_sub_client, current_user) if hash_class.on_load_block
                    end
                    response_agent.outer_result = { data: hash.to_transport }
                    response_agent.agent_result = { success: 'ok' }
                  else
                    response_agent.error = { error: 'Access denied!' }
                  end
                rescue Exception => e
                  response_agent.error = if Isomorfeus.production?
                                           { error: { hash_class_name => 'No such thing!' }}
                                         else
                                           { error: { hash_class_name => "Isomorfeus::Data::Handler::HashLoadHandler: #{e.message}" }}
                                         end
                end
              else
                response_agent.error = { error: { hash_class_name => 'No such thing!' }}
              end
            else
              response_agent.error = { error: { hash_class_name => 'No such thing!' }}
            end
          end
        end
      end
    end
  end
end
