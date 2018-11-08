module Isomorfeus
  module Transport
    def self.promise_send(request)
      if request.has_key?(:agent_id)
        agent_id = request.delete(:agent_id)
        Isomorfeus.client_transport_driver.send_request('request' => request)
        Isomorfeus::Transport::RequestAgent.get(agent_id).promise
      else
        agent = Isomorfeus::Transport::RequestAgent.new
        Isomorfeus.client_transport_driver.send_request('request' => { agent_id: { agent.id => request }})
        agent.promise
      end
    end

    def self.busy?
      Isomorfeus.store.get_state[:transport_state][:request_count] != 0
    end

    def self.process_response_or_notification(data)
      if data.has_key?(:notification)
        Isomorfeus.store.dispatch(data.merge!(type: 'TRANSPORT_NOTIFICATION'))
      elsif data.has_key?(:response)
        Isomorfeus.store.native.dispatch(data.merge!(type: 'TRANSPORT_RESPONSE'))
      elsif data.has_key?(:dma)
        if data.has_key?(:args)
          data[:module].constantize.send("process_#{data[:processor]}", *data[:args])
        else
          data[:module].constantize.send("process_#{data[:processor]}")
        end
      end
    end
  end
end