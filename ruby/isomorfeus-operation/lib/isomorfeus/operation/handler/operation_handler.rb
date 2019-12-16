# frozen_string_literal: true

module Isomorfeus
  module Operation
    module Handler
      class OperationHandler < LucidHandler::Base
        on_request do |pub_sub_client, current_user, response_agent|
          # promise_send_path('Isomorfeus::Operation::Handler::OperationHandler', self.to_s, props_hash)
          response_agent.request.each_key do |operation_class_name|
            if Isomorfeus.valid_operation_class_name?(operation_class_name)
              operation_class = Isomorfeus.cached_operation_class(operation_class_name)
              if operation_class
                props_json = response_agent.request[operation_class_name]
                begin
                  props = Oj.load(props_json, mode: :strict)
                  props.merge!({pub_sub_client: pub_sub_client, current_user: current_user})
                  if current_user.authorized?(operation_class, :promise_run, props)
                    operation_promise = operation_class.promise_run(props)
                    if operation_promise.realized?
                      response_agent.agent_result = { success: 'ok' , result: operation_promise.value }
                    else
                      start = Time.now
                      timeout = false
                      while !operation_promise.realized?
                        if (Time.now - start) > 20
                          timeout = true
                          break
                        end
                        sleep 0.01
                      end
                      if timeout
                        response_agent.error = { error: 'Timeout' }
                      else
                        response_agent.agent_result = { success: 'ok' , result: operation_promise.value }
                      end
                    end
                  else
                    response_agent.error = { error: 'Access denied!' }
                  end
                rescue Exception => e
                  response_agent.error = if Isomorfeus.production?
                                           { error: { operation_class_name => 'No such thing!' }}
                                         else
                                           { error: { operation_class_name => "Isomorfeus::Operation::Handler::OperationHandler: #{e.message}" }}
                                         end
                end
              else
                response_agent.error = { error: { operation_class_name => 'No such thing!' }}
              end
            else
              response_agent.error = { error: { operation_class_name => 'No such thing!' }}
            end
          end
        end
      end
    end
  end
end
