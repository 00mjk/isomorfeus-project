module Isomorfeus
  module Data
    module Handler
      class HashLoadHandler < LucidHandler::Base
        on_request do |pub_sub_client, session_id, current_user, request, response|
          result = { error: 'No such thing' }
          # promise_send_path('Isomorfeus::Data::Handler::HashLoadHandler', self.to_s, props_hash)
          request.each_key do |hash_class_name|
            if Isomorfeus.valid_hash_class_name?(hash_class_name)
              hash_class = Isomorfeus.cached_hash_class(hash_class_name)
              if hash_class
                request[hash_class_name].each_key do |props_json|
                  begin
                    props = Oj.load(props_json, mode: :strict)
                    props.merge!({pub_sub_client: pub_sub_client, session_id: session_id, current_user: current_user})
                    hash = hash_class.load(props)
                    hash.instance_exec do
                      hash_class.on_load_block.call(pub_sub_client, session_id, current_user) if hash_class.on_load_block
                    end
                    response.deep_merge!(data: hash.to_transport)
                    result = { success: 'ok' }
                  rescue Exception => e
                    result = if Isomorfeus.production?
                               { error: { hash_class_name => 'No such thing!' }}
                             else
                               { error: { hash_class_name => e.message }}
                             end
                  end
                end
              else
                result = { error: { hash_class_name => 'No such thing!' }}
              end
            else
              result = { error: { hash_class_name => 'No such thing!' }}
            end
          end
          result
        end
      end
    end
  end
end
