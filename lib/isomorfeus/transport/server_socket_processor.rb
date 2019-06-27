module Isomorfeus
  module Transport
    class ServerSocketProcessor
      include Isomorfeus::Transport::ServerProcessor

      def initialize(session_id, user)
        @session_id = session_id
        @user = user
      end

      def on_message(client, data)
        request_hash = Oj.load(data, mode: :strict)
        result = process_request(client, @session_id, @user, request_hash)
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
    end
  end
end
