module Isomorfeus
  module Transport
    class << self
      if RUBY_ENGINE == 'opal'
        attr_accessor :socket

        def init
          @socket = nil
          promise_connect if Isomorfeus.on_browser? || Isomorfeus.on_mobile?
          true
        end

        def promise_connect(session_id = nil)
          promise = Promise.new
          if @socket && @socket.ready_state < 2
            promise.resolve(true)
            return promise
          end
          if Isomorfeus.on_browser?
            window_protocol = `window.location.protocol`
            ws_protocol = window_protocol == 'https:' ? 'wss:' : 'ws:'
            ws_url = "#{ws_protocol}//#{`window.location.host`}#{Isomorfeus.api_websocket_path}"
          else
            ws_url = "#{Isomorfeus::TopLevel.transport_ws_url}"
          end
          headers = (session_id.nil? || session_id.empty?) ? nil : { 'Cookie': "session=#{session_id}" }
          @socket = Isomorfeus::Transport::WebsocketClient.new(ws_url, nil, headers)
          @socket.on_error do |error|
            if Isomorfeus.on_browser?
              `console.warn('Isomorfeus::Transport: Will try again, but so far error connecting:', error)`
              @socket.close
              after 1000 do
                Isomorfeus::Transport.promise_connect
              end
            else
              Isomorfeus.raise_error(message: error.JS[:message], stack: error.JS[:stack])
            end
          end
          @socket.on_message do |event|
            json_hash = `Opal.Hash.$new(JSON.parse(event.data))`
            Isomorfeus::Transport::ClientProcessor.process(json_hash)
          end
          @socket.on_open do |event|
            open_promise = Promise.new.resolve(true)
            Isomorfeus.transport_init_class_names.each do |constant|
              result_promise = constant.constantize.send(:init)
              open_promise.then { result_promise } if result_promise.class == Promise
            end
            requests_in_progress[:requests].each_key do |request|
              agent = get_agent_for_request_in_progress(request)
              open_promise.then { promise_send_request(request) } if agent && !agent.sent
            end
            open_promise.then { promise.resolve(true) }
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
          agent = if request_in_progress?(request)
                    get_agent_for_request_in_progress(request)
                  else
                    Isomorfeus::Transport::RequestAgent.new(request)
                  end
          unless agent.sent
            if block_given?
              agent.promise.then do |response|
                block.call(response)
              end
            end
            register_request_in_progress(request, agent.id)
            Isomorfeus.raise_error(message: 'No socket!') unless @socket
            begin
              @socket.send(`JSON.stringify(#{{request: { agent_ids: { agent.id => request }}}.to_n})`)
              agent.sent = true
              after(Isomorfeus.on_ssr? ? 5000 : 20000) do
                unless agent.promise.realized?
                  agent.promise.reject({agent_response: { error: 'Request timeout!' }, full_response: {}})
                end
              end
            rescue
              @socket.close
              after (Isomorfeus.on_ssr? ? 10 : 3000) do
                @reconnect = true
                Isomorfeus::Transport.promise_connect
              end
            end
          end
          agent.promise
        end

        def send_message(channel_class, channel, message)
          Isomorfeus.raise_error(message: 'No socket!') unless @socket
          @socket.send(`JSON.stringify(#{{ notification: { class: channel_class.name, channel: channel, message: message }}.to_n})`)
          true
        end

        def promise_subscribe(channel_class_name, channel)
          request = { subscribe: true, class: channel_class_name, channel: channel }
          if request_in_progress?(request)
            agent = get_agent_for_request_in_progress(request)
          else
            agent = Isomorfeus::Transport::RequestAgent.new(request)
            register_request_in_progress(request, agent.id)
            Isomorfeus.raise_error(message: 'No socket!') unless @socket
            @socket.send(`JSON.stringify(#{{ subscribe: { agent_ids: { agent.id => request }}}.to_n})`)
          end
          result_promise = agent.promise.then do |agent|
            agent.response
          end
          result_promise
        end

        def promise_unsubscribe(channel_class_name, channel)
          request = { unsubscribe: true, class: channel_class_name, channel: channel }
          if request_in_progress?(request)
            agent = get_agent_for_request_in_progress(request)
          else
            agent = Isomorfeus::Transport::RequestAgent.new(request)
            register_request_in_progress(request, agent.id)
            Isomorfeus.raise_error(message: 'No socket!') unless @socket
            @socket.send(`JSON.stringify(#{{ unsubscribe: { agent_ids: { agent.id => request }}}.to_n})`)
          end
          result_promise = agent.promise.then do |agent|
            agent.response
          end
          result_promise
        end

        def busy?
          requests_in_progress[:requests].size != 0
        end

        def requests_in_progress
          @requests_in_progress ||= { requests: {}, agent_ids: {} }
        end

        def request_in_progress?(request)
          requests_in_progress[:requests].key?(request)
        end

        def get_agent_for_request_in_progress(request)
          agent_id = requests_in_progress[:requests][request]
          Isomorfeus::Transport::RequestAgent.get(agent_id)
        end

        def register_request_in_progress(request, agent_id)
          requests_in_progress[:requests][request] = agent_id
          requests_in_progress[:agent_ids][agent_id] = request
        end

        def unregister_request_in_progress(agent_id)
          request = requests_in_progress[:agent_ids].delete(agent_id)
          requests_in_progress[:requests].delete(request)
        end
      else # RUBY_ENGINE
        def send_message(channel_class, channel, message)
          channel_class_name = channel_class.name
          Isomorfeus.pub_sub_client.publish("#{channel_class_name}_#{channel}", Oj.dump({notification: { class: channel_class_name, channel: channel, message: message}}, mode: :strict))
          true
        end

        def promise_subscribe(channel_class, channel, &block)
          Isomorfeus.pub_sub_client.subscribe(channel)
          Promise.new.resolve({ success: channel })
        end

        def promise_unsubscribe(channel_class, channel, &block)
          Isomorfeus.pub_sub_client.unsubscribe(channel)
          Promise.new.resolve({ success: channel })
        end
      end # RUBY_ENGINE
    end
  end
end
