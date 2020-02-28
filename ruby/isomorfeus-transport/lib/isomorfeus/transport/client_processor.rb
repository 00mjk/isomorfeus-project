module Isomorfeus
  module Transport
    class ClientProcessor
      def self.process(json_hash)
        if json_hash.key?(:response)
          process_response(json_hash)
        elsif json_hash.key?(:notification)
          process_message(json_hash)
        end
      end

      def self.process_message(message_hash)
        processor_class_name = message_hash[:notification][:class]
        Isomorfeus.raise_error(message: "Not a valid channel class #{processor_class_name}!") unless Isomorfeus.valid_channel_class_name?(processor_class_name)
        processor_class = Isomorfeus.cached_channel_class(processor_class_name)
        unless processor_class.respond_to?(:process_message)
          Isomorfeus.raise_error(message: "Cannot process message, #{processor_class} must be a Channel and must have the on_message block defined!")
        end
        processor_class.process_message(message_hash[:notification][:message], message_hash[:notification][:error], message_hash[:notification][:channel])
      end

      def self.process_response(response_hash)
        response_hash[:response][:agent_ids].keys.each do |agent_id|
          agent = Isomorfeus::Transport::RequestAgent.get!(agent_id)
          Isomorfeus::Transport.unregister_request_in_progress(agent_id)
          unless agent.promise.realized?
            agent.full_response = response_hash
            agent.response = response_hash[:response][:agent_ids][agent_id]
            agent.promise.resolve(agent)
          end
        end
      end
    end
  end
end
