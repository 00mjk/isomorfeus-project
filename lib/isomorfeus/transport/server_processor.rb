# frozen_string_literal: true

module Isomorfeus
  module Transport
    module ServerProcessor
      def process_request(client, current_user, request, handler_instance_cache, response_agent_array)
        Thread.current[:isomorfeus_pub_sub_client] = client

        if request.key?('request') && request['request'].key?('agent_ids')
          request['request']['agent_ids'].each_key do |agent_id|
            request['request']['agent_ids'][agent_id].each_key do |handler_class_name|
              response_agent = Isomorfeus::Transport::ResponseAgent.new(agent_id, request['request']['agent_ids'][agent_id][handler_class_name])
              response_agent_array << response_agent
              begin
                handler = if handler_instance_cache.key?(handler_class_name)
                            handler_instance_cache[handler_class_name]
                          else
                            handler_class = Isomorfeus.cached_handler_class(handler_class_name) if Isomorfeus.valid_handler_class_name?(handler_class_name)
                            handler_instance_cache[handler_class_name] = handler_class.new if handler_class
                          end
                if handler
                  handler.process_request(client, current_user, response_agent)
                else
                  response_agent.error = { error: { handler_class_name => 'No such handler!'}}
                end
              rescue Exception => e
                response_agent.error = if Isomorfeus.production? then { error: { handler_class_name => 'No such handler!'}}
                                       else { response: { error: "#{handler_class_name}: #{e.message}\n#{e.backtrace.join("\n")}" }}
                                       end
              end
            end
          end
        elsif request.key?('notification')
          begin
            channel = request['notification']['channel']
            class_name = request['notification']['class']

            if Isomorfeus.valid_channel_class_name?(class_name) && channel
              channel_class = Isomorfeus.cached_channel_class(class_name)
              if channel_class && current_user.authorized?(channel_class, :send_message, channel)
                client.publish(request['notification']['channel'], Oj.dump({ 'notification' => request['notification'] }, mode: :strict))
              else
                response_agent = OpenStruct.new
                response_agent_array << response_agent
                response_agent.result = { response: { error: 'Not authorized!' }}
              end
            else
              response_agent = OpenStruct.new
              response_agent_array << response_agent
              response_agent.result = { response: { error: 'No such thing!' }}
            end
          rescue Exception => e
            response_agent = OpenStruct.new
            response_agent_array << response_agent
            response_agent.result = if Isomorfeus.production? then { response: { error: 'No such thing!' }}
                                    else { response: { error: "Isomorfeus::Transport::ServerProcessor: #{e.message}\n#{e.backtrace.join("\n")}" }}
                                    end
          end
        elsif request.key?('subscribe') && request['subscribe'].key?('agent_ids')
          begin
            agent_id = request['subscribe']['agent_ids'].keys.first
            response_agent = Isomorfeus::Transport::ResponseAgent.new(agent_id, request['subscribe']['agent_ids'][agent_id])
            response_agent_array << response_agent
            channel = response_agent.request['channel']
            class_name = response_agent.request['class']
            if Isomorfeus.valid_channel_class_name?(class_name) && channel
              channel_class = Isomorfeus.cached_channel_class(class_name)
              if channel_class && current_user.authorized?(channel_class, :subscribe, channel)
                client.subscribe(channel)
                response_agent.agent_result = { success: channel }
              else
                response_agent.error = { error: "Not authorized!"}
              end
            else
              response_agent.error = { error: "No such thing!"}
            end
          rescue Exception => e
            response_agent.error = if Isomorfeus.production? then { error: 'No such thing!' }
                                   else { error: "Isomorfeus::Transport::ServerProcessor: #{e.message}\n#{e.backtrace.join("\n")}" }
                                   end
          end
        elsif request.key?('unsubscribe') && request['unsubscribe'].key?('agent_ids')
          begin
            agent_id = request['unsubscribe']['agent_ids'].keys.first
            response_agent = Isomorfeus::Transport::ResponseAgent.new(agent_id, request['unsubscribe']['agent_ids'][agent_id])
            response_agent_array << response_agent
            channel = response_agent.request['channel']
            class_name = response_agent.request['class']
            if Isomorfeus.valid_channel_class_name?(class_name) && channel
              channel_class = Isomorfeus.cached_channel_class(class_name)
              if channel_class && current_user.authorized?(channel_class, :unsubscribe, channel)
                client.unsubscribe(channel)
                response_agent.agent_result = { success: channel }
              else
                response_agent.error = { error: "Not authorized!"}
              end
            else
              response_agent.error = { error: 'No such thing!'}
            end
          rescue Exception => e
            response_agent.error = if Isomorfeus.production? then { error: 'No such thing!' }
                                   else { error: "Isomorfeus::Transport::ServerProcessor: #{e.message}\n#{e.backtrace.join("\n")}" }
                                   end
          end
        end
      end
    end
  end
end
