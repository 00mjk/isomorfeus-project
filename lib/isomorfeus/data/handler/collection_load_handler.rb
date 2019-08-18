# frozen_string_literal: true

module Isomorfeus
  module Data
    module Handler
      class CollectionLoadHandler < LucidHandler::Base
        on_request do |pub_sub_client, current_user, request, response|
          result = { error: 'No such thing' }
          # promise_send_path('Isomorfeus::Data::Handler::CollectionLoadHandler', self.to_s, props_hash)
          request.each_key do |collection_class_name|
            if Isomorfeus.valid_collection_class_name?(collection_class_name)
              collection_class = Isomorfeus.cached_collection_class(collection_class_name)
              if collection_class
                props_json = request[collection_class_name]
                begin
                  props = Oj.load(props_json, mode: :strict)
                  props.merge!({pub_sub_client: pub_sub_client, current_user: current_user})
                  if current_user.authorized?(collection_class, :load, *props)
                    collection = collection_class.load(props)
                    collection.instance_exec do
                      collection_class.on_load_block.call(pub_sub_client, current_user) if collection_class.on_load_block
                    end
                    response.deep_merge!(data: collection.to_transport)
                    response.deep_merge!(data: collection.included_items_to_transport)
                    result = { success: 'ok' }
                  else
                    result = { error: 'Access denied!' }
                  end
                rescue Exception => e
                  result = if Isomorfeus.production?
                             { error: { collection_class_name => 'No such thing!' }}
                           else
                             { error: { collection_class_name => "Isomorfeus::Data::Handler::CollectionLoadHandler: #{e.message}" }}
                           end
                end
              else
                result = { error: { collection_class_name => 'No such thing!' }}
              end
            else
              result = { error: { collection_class_name => 'No such thing!' }}
            end
          end
          result
        end
      end
    end
  end
end
