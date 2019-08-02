module Isomorfeus
  module Operation
    module Handler
      class OperationHandler < LucidHandler::Base
        on_request do |pub_sub_client, session_id, current_user, request, response|
          result = { error: 'No such thing' }
          # promise_send_path('Isomorfeus::Operation::Handler::OperationHandler', self.to_s, props_hash)
          request.keys.each do |operation_class_name|
            if Isomorfeus.valid_operation_class_name?(operation_class_name)
              operation_class = Isomorfeus.cached_operation_class(operation_class_name)
              if operation_class
                request[operation_class_name].each_key do |props_json|
                  begin
                    props = Oj.load(props_json, mode: :strict)
                    props.merge!({pub_sub_client: pub_sub_client, session_id: session_id, current_user: current_user})
                    operation_result = operation_class.run(props)
                    result = { success: 'ok' , result: operation_result}
                  rescue Exception => e
                    result = if Isomorfeus.production?
                               { error: { operation_class_name => 'No such thing!' }}
                             else
                               { error: { operation_class_name => e.message }}
                             end
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
