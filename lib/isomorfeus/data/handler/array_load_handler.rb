module Isomorfeus
  module Data
    module Handler
      class ArrayLoadHandler < LucidHandler::Base
        on_request do |pub_sub_client, session_id, current_user, request, response|
          result = { error: 'No such thing' }
          # promise_send_path('Isomorfeus::Data::Handler::CollectionLoadHandler', self.to_s, props_hash)
          request.each_key do |array_class_name|
            if Isomorfeus.valid_array_class_name?(array_class_name)
              array_class = Isomorfeus.cached_array_class(array_class_name)
              if array_class
                request[array_class_name].each_key do |props_json|
                  begin
                    props = Oj.load(props_json, mode: :strict)
                    props.merge!({pub_sub_client: pub_sub_client, session_id: session_id, current_user: current_user})
                    array = array_class.load(props)
                    array.instance_exec do
                      array_class.on_load_block.call(pub_sub_client, session_id, current_user) if array_class.on_load_block
                    end
                    response.deep_merge!(data: array.to_transport)
                    result = { success: 'ok' }
                  rescue Exception => e
                    result = if Isomorfeus.production?
                               { error: { array_class_name => 'No such thing!' }}
                             else
                               { error: { array_class_name => e.message }}
                             end
                  end
                end
              else
                result = { error: { array_class_name => 'No such thing!' }}
              end
            else
              result = { error: { array_class_name => 'No such thing!' }}
            end
          end
          result
        end
      end
    end
  end
end
