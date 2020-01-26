module Isomorfeus
  module Transport
    class ServerSocketProcessor
      include Isomorfeus::Transport::ServerProcessor

      def on_message(client, data)
        if Isomorfeus.development?
          write_lock = Isomorfeus.zeitwerk_lock.try_write_lock
          if write_lock
            Isomorfeus.zeitwerk.reload
            Isomorfeus.zeitwerk_lock.release_write_lock
          end
          Isomorfeus.zeitwerk_lock.acquire_read_lock
        end
        request_hash = Oj.load(data, mode: :strict)
        handler_instance_cache = {}
        response_agent_array = []
        Thread.current[:isomorfeus_user] = user(client)
        Thread.current[:isomorfeus_pub_sub_client] = client
        process_request(request_hash, handler_instance_cache, response_agent_array)
        handler_instance_cache.each_value do |handler|
          handler.resolve if handler.resolving?
        end
        result = {}
        response_agent_array.each do |response_agent|
          result.deep_merge!(response_agent.result)
        end
        client.write Oj.dump(result, mode: :strict)
      ensure
        Thread.current[:isomorfeus_user] = nil
        Thread.current[:isomorfeus_pub_sub_client] = nil
        Isomorfeus.zeitwerk_lock.release_read_lock if Isomorfeus.development?
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
        # TODO get session cooke and load user from session
        current_user = client.instance_variable_get(:@isomorfeus_user)
        return current_user if current_user
        # TODO get session cooke and load user from session
        Anonymous.new
      end
    end
  end
end
