# frozen_string_literal: true

module Isomorfeus
  module Operation
    module Handler
      class OperationHandler < LucidHandler::Base
        on_request do |response_agent|
          # promise_send_path('Isomorfeus::Operation::Handler::OperationHandler', self.to_s, props_hash)
          response_agent.request.each_key do |operation_class_name|
            if Isomorfeus.valid_operation_class_name?(operation_class_name)
              operation_class = Isomorfeus.cached_operation_class(operation_class_name)
              if operation_class
                props = response_agent.request[operation_class_name]
                props.transform_keys!(&:to_sym)
                begin
                  if Isomorfeus.current_user.authorized?(operation_class, :promise_run, props)
                    operation_promise = operation_class.promise_run(**props)
                    if operation_promise.realized?
                      state = operation_promise.resolved? ? :resolved : :rejected
                      result_hash = { state => operation_promise.value }
                      if operation_promise.error
                        e = operation_promise.error
                        result_hash[:error] = { message: e.message, class_name: e.class.to_s, back_trace: e.backtrace }
                      end
                      response_agent.agent_result = { success: 'ok' , result: result_hash }
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
                        state = operation_promise.resolved? ? :resolved : :rejected
                        result_hash = { state => operation_promise.value }
                        if operation_promise.error
                          e = operation_promise.error
                          result_hash[:error] = { message: e.message, class_name: e.class.to_s, back_trace: e.backtrace }
                        end
                        response_agent.agent_result = { success: 'ok' , result: result_hash }
                      end
                    end
                  else
                    response_agent.error = { error: 'Access denied!' }
                  end
                rescue Exception => e
                  response_agent.error = { error: { operation_class_name => "Isomorfeus::Operation::Handler::OperationHandler: #{e.message}" }}
                end
              else
                response_agent.error = { error: { operation_class_name => 'Could not get operation class!' }}
              end
            else
              response_agent.error = { error: { operation_class_name => 'No such operation class!' }}
            end
          end
        end
      end
    end
  end
end
