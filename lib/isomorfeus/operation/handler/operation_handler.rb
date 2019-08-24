# frozen_string_literal: true

module Isomorfeus
  module Operation
    module Handler
      class OperationHandler < LucidHandler::Base
        on_request do |pub_sub_client, current_user, request, response|
          result = { error: 'No such thing' }
          # promise_send_path('Isomorfeus::Operation::Handler::OperationHandler', self.to_s, props_hash)
          request.each_key do |operation_class_name|
            if Isomorfeus.valid_operation_class_name?(operation_class_name)
              operation_class = Isomorfeus.cached_operation_class(operation_class_name)
              if operation_class
                props_json = request[operation_class_name]
                begin
                  props = Oj.load(props_json, mode: :strict)
                  props.merge!({pub_sub_client: pub_sub_client, current_user: current_user})
                  if current_user.authorized?(operation_class, :promise_run, props)
                    operation_promise = operation_class.promise_run(props)
                    if operation_promise.realized?
                      result = { success: 'ok' , result: operation_promise.value }
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
                        result = { error: 'Timeout' }
                      else
                        result = { success: 'ok' , result: operation_promise.value }
                      end
                    end
                  else
                    result = { error: 'Access denied!' }
                  end
                rescue Exception => e
                  result = if Isomorfeus.production?
                             { error: { operation_class_name => 'No such thing!' }}
                           else
                             { error: { operation_class_name => "Isomorfeus::Operation::Handler::OperationHandler: #{e.message}" }}
                           end
                end
              else
                result = { error: { operation_class_name => 'No such thing!' }}
              end
            else
              result = { error: { operation_class_name => 'No such thing!' }}
            end
          end
          result
        end
      end
    end
  end
end
