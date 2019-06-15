module Isomorfeus
  module Transport
    def self.init!
      @requests_in_progress = { requests: {}, agent_ids: {} }
    end

    def self.promise_send_path(*path, &block)
      request = {}
      path.inject(request) do |memo, key|
        memo[key] = {}
      end
      Isomorfeus::Transport.promise_send(request, &block)
    end

    def self.promise_send(request, &block)
      if request_in_progress?(request)
        agent = get_agent_for_request_in_progress(request)
      else
        agent = Isomorfeus::Transport::RequestAgent.new(request)
        if block_given?
          agent.promise.then do |response|
            block.call(response)
          end
        end
        register_request_in_progress(request, agent.id)
        Isomorfeus.client_transport_driver.send_request(request: { agent_ids: { agent.id => request }})
      end
      agent.promise
    end

    def self.busy?
      @requests_in_progress.size != 0
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

    def self.requests_in_progress
      @requests_in_progress
    end

    def self.request_in_progress?(request)
      @requests_in_progress[:requests].has_key?(request)
    end

    def self.get_agent_for_request_in_progress(request)
      agent_id = @requests_in_progress[:requests][request]
      Isomorfeus::Transport::RequestAgent.get(agent_id)
    end

    def self.register_request_in_progress(request, agent_id)
      @requests_in_progress[:requests][request] = agent_id
      @requests_in_progress[:agent_ids][agent_id] = request
    end

    def self.remove_request_in_progress(agent_id)
      request = @requests_in_progress[:agent_ids].delete(agent_id)
      @requests_in_progress[:requests].delete(request)
    end
  end
end