module Isomorfeus
  module Transport
    class ServerSocketProcessor
      include Isomorfeus::Transport::ServerProcessor

      def on_message(client, data)
        request_hash = Oj.load(data, mode: :strict)
        handler_instance_cache = {}
        response_agent_array = []
        process_request(client, user(client), request_hash, handler_instance_cache, response_agent_array)
        handler_instance_cache.each_value do |handler|
          handler.resolve if handler.resolving?
        end
        result = {}
        response_agent_array.each do |response_agent|
          result.deep_merge!(response_agent.result)
        end
        client.write Oj.dump(result, mode: :strict)
      end

      def on_close(client)
        # nothing for now
      end

      def on_open(client)
        # nothing for now
      end

      def on_shutdown(client)
        # nothing for now
      end

      def user(client)
        client.instance_variable_get(:@isomorfeus_user) || Anonymous.new
      end
    end
  end
end
