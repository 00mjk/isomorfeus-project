module Isomorfeus
  module Transport
    class ClientProcessor
      def self.process(json_hash)
        if json_hash.key?(:response)
          process_response(json_hash)
        elsif json_hash.key?(:notification)
          process_notification(json_hash)
        end
      end

      def self.process_notification(notification_hash)
        processor_class = "::#{notification_hash[:notification][:class]}".constantize
        processor_class.process_message(notification_hash[:notification][:message])
      end

      def self.process_response(response_hash)
        response_hash[:response][:agent_ids].keys.each do |agent_id|
          agent = Isomorfeus::Transport::RequestAgent.get!(agent_id)
          Isomorfeus::Transport.unregister_request_in_progress(agent_id)
          agent.promise.resolve(agent_response: response_hash[:response][:agent_ids][agent_id], full_response: response_hash)
        end
      end
    end
  end
end