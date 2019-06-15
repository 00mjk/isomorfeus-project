module Isomorfeus
  module Transport
    module RequestProcessor
      def process_request(session_id, current_user, request)
        response = { response: { agent_ids: {}} }

        if request.has_key?('request') && request['request'].has_key?('agent_ids')
          request['request']['agent_ids'].keys.each do |agent_id|
            request['request']['agent_ids'][agent_id].keys.each do |key|
              handler = "::#{key.underscore.camelize}Handler".constantize
              if handler
                response[:response][:agent_ids][agent_id] = handler.new.process_request(session_id, current_user, request['request']['agent_ids'][agent_id][key], response)
              else
                response[:response][:agent_ids][agent_id] = { error: { key => "No such handler!"}}
              end
            end
          end
        else
          response[:response] = 'No such thing!'
        end

        response
      end
    end
  end
end