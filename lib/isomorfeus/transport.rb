module Isomorfeus
  module Transport
    class << self
      attr_accessor :socket

      def delay(ms = 1000, &block)
        `setTimeout(#{block.to_n}, ms)`
      end

      def init!
        @requests_in_progress = { requests: {}, agent_ids: {} }
        @socket = nil
        connect if Isomorfeus.on_browser?
      end

      def connect
        return if @socket && @socket.ready_state < 2
        if Isomorfeus.on_browser?
          window_protocol = `window.location.protocol`
          ws_protocol = window_protocol == 'https:' ? 'wss:' : 'ws:'
          ws_url = "#{ws_protocol}#{`window.location.host`}#{Isomorfeus.api_websocket_path}"
        else
          ws_url = Isomorfeus::TopLevel.transport_ws_url
        end
        @socket = Isomorfeus::Transport::Websocket.new(ws_url)
        @socket.on_error do
          @socket.close
          delay do
            Isomorfeus::Transport.connect
          end
        end
        @socket.on_message do |event|
          json_hash = `Opal.Hash.$new(JSON.parse(event.data))`
          Isomorfeus::Transport::ClientProcessor.process(json_hash)
        end
        true
      end

      def disconnect
        @socket.close if @socket
        @socket = nil
      end

      def promise_send_path(*path, &block)
        request = {}
        path.inject(request) do |memo, key|
          memo[key] = {}
        end
        Isomorfeus::Transport.promise_send_request(request, &block)
      end

      def promise_send_request(request, &block)
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
          @socket.send(`JSON.stringify(#{{request: { agent_ids: { agent.id => request }}}.to_n})`)
        end
        agent.promise
      end

      def send_notification(processor_class, message)
        @socket.send(`JSON.stringify(#{{notification: { class: processor_class.to_s, message: message}}.to_n})`)
        true
      end

      def subscribe(processor_class, &block)
        request = { subscribe: true, class: processor_class.to_s }
        if request_in_progress?(request)
          agent = get_agent_for_request_in_progress(request)
        else
          agent = Isomorfeus::Transport::RequestAgent.new(request)
          register_request_in_progress(request, agent.id)
          @socket.send(`JSON.stringify(#{{subscribe: { agent_ids: { agent.id => request }}}.to_n})`)
        end
        result_promise = agent.promise.then do |response|
          response[:agent_response]
        end
        if block_given?
          result_promise = result_promise.then do |response|
            block.call(response)
          end
        end
        result_promise
      end

      def unsubscribe(processor_class, &block)
        request = { unsubscribe: true, class: processor_class.to_s }
        if request_in_progress?(request)
          agent = get_agent_for_request_in_progress(request)
        else
          agent = Isomorfeus::Transport::RequestAgent.new(request)
          register_request_in_progress(request, agent.id)
          @socket.send(`JSON.stringify(#{{unsubscribe: { agent_ids: { agent.id => request }}}.to_n})`)
        end
        result_promise = agent.promise.then do |response|
          response[:agent_response]
        end
        if block_given?
          result_promise = result_promise.then do |response|
            block.call(response)
          end
        end
        result_promise
      end

      def busy?
        @requests_in_progress.size != 0
      end

      def requests_in_progress
        @requests_in_progress
      end

      def request_in_progress?(request)
        @requests_in_progress[:requests].key?(request)
      end

      def get_agent_for_request_in_progress(request)
        agent_id = @requests_in_progress[:requests][request]
        Isomorfeus::Transport::RequestAgent.get(agent_id)
      end

      def register_request_in_progress(request, agent_id)
        @requests_in_progress[:requests][request] = agent_id
        @requests_in_progress[:agent_ids][agent_id] = request
      end

      def unregister_request_in_progress(agent_id)
        request = @requests_in_progress[:agent_ids].delete(agent_id)
        @requests_in_progress[:requests].delete(request)
      end
    end
  end
end