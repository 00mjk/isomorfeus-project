# frozen_string_literal: true

module Isomorfeus
  module Data
    module Handler
      class ArrayLoadHandler < LucidHandler::Base
        on_request do |pub_sub_client, current_user, request, response|
          result = { error: 'No such thing' }
          # promise_send_path('Isomorfeus::Data::Handler::CollectionLoadHandler', self.to_s, props_hash)
          request.each_key do |array_class_name|
            if Isomorfeus.valid_array_class_name?(array_class_name)
              array_class = Isomorfeus.cached_array_class(array_class_name)
              if array_class
                props_json = request[array_class_name]
                begin
                  props = Oj.load(props_json, mode: :strict)
                  props.merge!({pub_sub_client: pub_sub_client, current_user: current_user})
                  if current_user.authorized?(array_class, :load, *props)
                    array = array_class.load(props)
                    array.instance_exec do
                      array_class.on_load_block.call(pub_sub_client, current_user) if array_class.on_load_block
                    end
                    response.deep_merge!(data: array.to_transport)
                    result = { success: 'ok' }
                  else
                    result = { error: 'Access denied!' }
                  end
                rescue Exception => e
                  result = if Isomorfeus.production?
                             { error: { array_class_name => 'No such thing!' }}
                           else
                             { error: { array_class_name => "Isomorfeus::Data::Handler::ArrayLoadHandler: #{e.message}" }}
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
