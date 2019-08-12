module Isomorfeus
  module Transport
    class << self
      if RUBY_ENGINE == 'opal'
        attr_accessor :socket

        def delay(ms = 1000, &block)
          `setTimeout(#{block.to_n}, ms)`
        end

        def init
          @requests_in_progress = { requests: {}, agent_ids: {} }
          @socket = nil
          promise_connect if Isomorfeus.on_browser?
          true
        end

        def promise_connect
          promise = Promise.new
          if @socket && @socket.ready_state < 2
            promise.resolve(true)
            return promise
          end
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
          @socket.on_open do |event|
            init_promises = []
            Isomorfeus.transport_init_class_names.each do |constant|
              result = constant.constantize.send(:init)
              init_promises << result if result.class == Promise
            end
            if init_promises.size > 0
              Promise.when(*init_promises).then { promise.resolve(true) }
            else
              promise.resolve(true)
            end
          end
          promise
        end

        def disconnect
          @socket.close if @socket
          @socket = nil
        end

        def promise_send_path(*path, &block)
          request = {}
          inject_path = path[0...-1]
          last_inject_path_el = inject_path.last
          last_path_el = path.last
          inject_path.inject(request) do |memo, key|
            if key == last_inject_path_el
              memo[key] = last_path_el
            else
              memo[key] = {}
            end
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
            raise 'No socket!' unless @socket
            @socket.send(`JSON.stringify(#{{request: { agent_ids: { agent.id => request }}}.to_n})`)
            delay(Isomorfeus.on_ssr? ? 8000 : 20000) do
              unless agent.promise.realized?
                agent.promise.reject({agent_response: { error: 'Request timeout!' }, full_response: {}})
              end
            end
          end
          agent.promise
        end

        def send_notification(channel_class, channel, message)
          raise 'No socket!' unless @socket
          @socket.send(`JSON.stringify(#{{notification: { class: channel_class.name, channel: channel, message: message}}.to_n})`)
          true
        end

        def subscribe(channel_class, channel, &block)
          request = { subscribe: true, class: channel_class.name, channel: channel }
          if request_in_progress?(request)
            agent = get_agent_for_request_in_progress(request)
          else
            agent = Isomorfeus::Transport::RequestAgent.new(request)
            register_request_in_progress(request, agent.id)
            raise 'No socket!' unless @socket
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

        def unsubscribe(channel_class, channel, &block)
          request = { unsubscribe: true, class: channel_class.name, channel: channel }
          if request_in_progress?(request)
            agent = get_agent_for_request_in_progress(request)
          else
            agent = Isomorfeus::Transport::RequestAgent.new(request)
            register_request_in_progress(request, agent.id)
            raise 'No socket!' unless @socket
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
          @requests_in_progress[:requests].size != 0
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
      else # RUBY_ENGINE
        def send_notification(channel_class, channel, message)
          Thread.current[:isomorfeus_pub_sub_client].publish(Oj.dump({notification: { class: channel_class.name, channel: channel, message: message}}, mode: :strict))
          true
        end

        def subscribe(channel_class, channel, &block)
          Thread.current[:isomorfeus_pub_sub_client].subscribe(channel)
          result_promise = Promise.new
          result_promise.resolve({ success: channel })
          result_promise
        end

        def unsubscribe(channel_class, channel, &block)
          Thread.current[:isomorfeus_pub_sub_client].unsubscribe(channel)
          result_promise = Promise.new
          result_promise.resolve({ success: channel })
          result_promise
        end
      end # RUBY_ENGINE
    end
  end
end