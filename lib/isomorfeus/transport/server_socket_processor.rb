module Isomorfeus
  module Transport
    class ServerSocketProcessor
      include Isomorfeus::Transport::ServerProcessor

      def on_message(client, data)
        request_hash = Oj.load(data, mode: :strict)
        result = process_request(client, user(client), request_hash)
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
