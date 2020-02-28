# frozen_string_literal: true

module Isomorfeus
  module Transport
    module ServerProcessor
      def process_request(request, handler_instance_cache, response_agent_array)
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
                  handler.process_request(response_agent)
                else
                  response_agent.error = { error: { handler_class_name => 'No such handler!'}}
                end
              rescue Exception => e
                response_agent.error = { response: { error: "#{handler_class_name}: #{e.message}\n#{e.backtrace.join("\n")}" }}
              end
            end
          end
        elsif request.key?('notification')
          begin
            channel = request['notification']['channel']
            channel_class_name = request['notification']['class']
            if Isomorfeus.valid_channel_class_name?(channel_class_name) && channel
              channel_class = Isomorfeus.cached_channel_class(channel_class_name)
              if channel_class && channel_class.valid_channel?(channel)
                if Isomorfeus.current_user.authorized?(channel_class_name, :send_message, channel)
                  allow_publish = if channel_class.server_is_processing_messages?(channel)
                                    channel_class.server_process_message(request['notification']['message'], channel)
                                  else
                                    true
                                  end
                  if allow_publish == true
                    Isomorfeus.pub_sub_client.publish("#{channel_class_name}_#{channel}", Oj.dump({ 'notification' => request['notification'] }, mode: :strict))
                  else
                    response_agent = OpenStruct.new
                    response_agent.result = { notification: request['notification'].merge(error: 'Message cancelled!') }
                    response_agent_array << response_agent
                  end
                else
                  response_agent = OpenStruct.new
                  response_agent.result = { notification: request['notification'].merge(error: 'Not authorized!') }
                  response_agent_array << response_agent
                end
              else
                response_agent = OpenStruct.new
                response_agent.result = { notification: request['notification'].merge(error: "Not a valid channel #{channel} for #{channel_class_name}!") }
                response_agent_array << response_agent
              end
            else
              response_agent = OpenStruct.new
              response_agent.result = { notification: request['notification'].merge(error: "Not a valid Channel class #{channel_class_name}!") }
              response_agent_array << response_agent
            end
          rescue Exception => e
            response_agent = OpenStruct.new
            response_agent.result = { notification: request['notification'].merge(error: "Isomorfeus::Transport::ServerProcessor: #{e.message}\n#{e.backtrace.join("\n")}") }
            response_agent_array << response_agent
          end
        elsif request.key?('subscribe') && request['subscribe'].key?('agent_ids')
          begin
            agent_id = request['subscribe']['agent_ids'].keys.first
            response_agent = Isomorfeus::Transport::ResponseAgent.new(agent_id, request['subscribe']['agent_ids'][agent_id])
            response_agent_array << response_agent
            channel = response_agent.request['channel']
            channel_class_name = response_agent.request['class']
            if Isomorfeus.valid_channel_class_name?(channel_class_name) && channel
              channel_class = Isomorfeus.cached_channel_class(channel_class_name)
              if channel_class && channel_class.valid_channel?(channel)
                if Isomorfeus.current_user.authorized?(channel_class, :subscribe, channel)
                  Isomorfeus.pub_sub_client.subscribe("#{channel_class_name}_#{channel}")
                  response_agent.agent_result = { success: channel }
                else
                  response_agent.error = { error: "Not authorized!"}
                end
              else
                response_agent = OpenStruct.new
                response_agent.result = { response: { error: "Not a valid channel #{channel} for #{channel_class_name}!" }}
                response_agent_array << response_agent
              end
            else
              response_agent.error = { error: "Not a valid Channel class #{channel_class_name}!" }
            end
          rescue Exception => e
            response_agent.error = { error: "Isomorfeus::Transport::ServerProcessor: #{e.message}\n#{e.backtrace.join("\n")}" }
          end
        elsif request.key?('unsubscribe') && request['unsubscribe'].key?('agent_ids')
          begin
            agent_id = request['unsubscribe']['agent_ids'].keys.first
            response_agent = Isomorfeus::Transport::ResponseAgent.new(agent_id, request['unsubscribe']['agent_ids'][agent_id])
            response_agent_array << response_agent
            channel = response_agent.request['channel']
            channel_class_name = response_agent.request['class']
            if Isomorfeus.valid_channel_class_name?(channel_class_name) && channel
              channel_class = Isomorfeus.cached_channel_class(channel_class_name)
              if channel_class && channel_class.valid_channel?(channel)
                if Isomorfeus.current_user.authorized?(channel_class, :unsubscribe, channel)
                  Isomorfeus.pub_sub_client.unsubscribe("#{channel_class_name}_#{channel}")
                  response_agent.agent_result = { success: channel }
                else
                  response_agent.error = { error: "Not authorized!"}
                end
              else
                response_agent = OpenStruct.new
                response_agent.result = { response: { error: "Not a valid channel #{channel} for #{channel_class_name}!" }}
                response_agent_array << response_agent
              end
            else
              response_agent.error = { error: "Not a valid Channel class #{channel_class_name}!" }
            end
          rescue Exception => e
            response_agent.error = { error: "Isomorfeus::Transport::ServerProcessor: #{e.message}\n#{e.backtrace.join("\n")}" }
          end
        else
          response_agent.error = { error: "No such thing!" }
        end
      end
    end
  end
end
