# frozen_string_literal: true

module Isomorfeus
  module Transport
    module ServerProcessor
      def process_request(client, current_user, request)
        Thread.current[:isomorfeus_pub_sub_client] = client

        response = { response: { agent_ids: {}} }

        if request.key?('request') && request['request'].key?('agent_ids')
          request['request']['agent_ids'].each_key do |agent_id|
            request['request']['agent_ids'][agent_id].each_key do |handler_class_name|
              begin
                handler = Isomorfeus.cached_handler_class(handler_class_name) if Isomorfeus.valid_handler_class_name?(handler_class_name)
                if handler
                  result = handler.new.process_request(client, current_user, request['request']['agent_ids'][agent_id][handler_class_name], response)
                  response[:response][:agent_ids][agent_id] = result
                else
                  response[:response][:agent_ids][agent_id] = { error: { handler_class_name => 'No such handler!'}}
                end
              rescue
                response[:response][:agent_ids][agent_id] = { error: { handler_class_name => 'No such handler!'}}
              end
            end
          end
        elsif request.key?('notification')
          begin
            channel = request['notification']['channel']
            class_name =  request['notification']['class']
            if Isomorfeus.valid_channel_class_name?(class_name) && channel
              client.publish(request['notification']['channel'], Oj.dump({ 'notification' => request['notification'] }, mode: :strict))
            else
              response[:response] = 'No such thing!'
            end
          rescue
            response[:response] = 'No such thing!'
          end
        elsif request.key?('subscribe') && request['subscribe'].key?('agent_ids')
          begin
            agent_id = request['subscribe']['agent_ids'].keys.first
            channel = request['subscribe']['agent_ids'][agent_id]['channel']
            class_name = request['subscribe']['agent_ids'][agent_id]['class']
            if Isomorfeus.valid_channel_class_name?(class_name) && channel
              client.subscribe(channel)
              response[:response][:agent_ids][agent_id] = { success: channel }
            else
              response[:response][:agent_ids][agent_id] = { error: "No such thing!"}
            end
          rescue
            response[:response][:agent_ids][agent_id] = { error: { key => 'No such handler!'}}
          end
        elsif request.key?('unsubscribe') && request['unsubscribe'].key?('agent_ids')
          begin
            agent_id = request['unsubscribe']['agent_ids'].keys.first
            channel = request['unsubscribe']['agent_ids'][agent_id]['channel']
            class_name = request['unsubscribe']['agent_ids'][agent_id]['class']
            if Isomorfeus.valid_channel_class_name?(class_name) && channel
              client.unsubscribe(channel)
              response[:response][:agent_ids][agent_id] = { success: channel }
            else
              response[:response][:agent_ids][agent_id] = { error: 'No such thing!'}
            end
          rescue
            response[:response][:agent_ids][agent_id] = { error: { key => 'No such handler!'}}
          end
        else
          response[:response] = { error: 'No such thing!'}
        end
        response
      end
    end
  end
end
