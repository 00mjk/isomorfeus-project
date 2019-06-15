module Isomorfeus
  module Transport
    class Processor
      def self.process(json_hash)
        if json_hash.has_key?(:response)
          process_response(json_hash)
        elsif json_hash.has_key?(:notification)
          process_notification(json_hash)
        end
      end

      def self.process_notification(notification_hash)
        notification_hash[:notification].keys.each do |class_name|
          "::#{class_name.underscore.camelize}".constantize.process_notification(notification_hash[class_name])
        end
      end

      def self.process_response(response_hash)
        response_hash[:response][:agent_ids].keys.each do |agent_id|
          agent = Isomorfeus::Transport::RequestAgent.get!(agent_id)
          Isomorfeus::Transport.remove_request_in_progress(agent_id)
          agent.promise.resolve(agent_response: response_hash[:response][:agent_ids][agent_id], full_response: response_hash)
        end
      end
    end
  end
end