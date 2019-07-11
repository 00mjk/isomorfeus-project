# frozen_string_literal: true

module Isomorfeus
  module Transport
    module ServerProcessor
      def process_request(client, session_id, current_user, request)
        Thread.current[:isomorfeus_pub_sub_client] = client

        response = { response: { agent_ids: {}} }

        if request.key?('request') && request['request'].key?('agent_ids')
          request['request']['agent_ids'].keys.each do |agent_id|
            request['request']['agent_ids'][agent_id].keys.each do |key|
              handler = "::#{key.underscore.camelize}Handler".constantize
              if handler
                response[:response][:agent_ids][agent_id] = handler.new.process_request(client, session_id, current_user, request['request']['agent_ids'][agent_id][key], response)
              else
                response[:response][:agent_ids][agent_id] = { error: { key => 'No such handler!'}}
              end
            end
          end
        elsif request.key?('notification')
          if request['notification'].key?('channel')
            client.publish(request['notification']['channel'], Oj.dump({ 'notification' => request['notification'] }, mode: :strict))
          else
            response[:response] = 'No such thing!'
          end
        elsif request.key?('subscribe') && request['subscribe'].key?('agent_ids')
          agent_id = request['subscribe']['agent_ids'].keys.first
          channel = request['subscribe']['agent_ids'][agent_id]['channel']
          if channel
            client.subscribe(channel)
            response[:response][:agent_ids][agent_id] = { success: channel }
          else
            response[:response][:agent_ids][agent_id] = { error: "No such thing!"}
          end
        elsif request.key?('unsubscribe') && request['unsubscribe'].key?('agent_ids')
          agent_id = request['unsubscribe']['agent_ids'].keys.first
          channel = request['unsubscribe']['agent_ids'][agent_id]['channel']
          if channel
            client.unsubscribe(channel)
            response[:response][:agent_ids][agent_id] = { success: channel }
          else
            response[:response][:agent_ids][agent_id] = { error: 'No such thing!'}
          end
        else
          response[:response] = 'No such thing!'
        end
        response
      end
    end
  end
end
