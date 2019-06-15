module Isomorfeus
  module Transport
    class WebsocketClient
      attr_reader :url

      if RUBY_ENGINE == 'opal'
        CONNECTING  = 0
        OPEN        = 1
        CLOSING     = 2
        CLOSED      = 3

        class SendError < StandardError; end

        def initialize(url, protocols = nil)
          @url = url
          @native_websocket = if protocols
                                `new WebSocket(url, protocols)`
                              else
                                `new WebSocket(url)`
                              end
        end

        def close
          @native_websocket.JS.close
        end

        def on_close(&block)
          @native_websocket.JS[:onclose] = `function(event) { block.$call(event); }`
        end

        def on_error(&block)
          @native_websocket.JS[:onerror] = `function(event) { block.$call(event); }`
        end

        def on_message(&block)
          @native_websocket.JS[:onmessage] = `function(event) { block.$call(event); }`
        end

        def send(data)
          case ready_state
          when OPEN then @native_websocket.JS.send(data)
          when CONNECTING then _delay { send(data) }
          when CLOSING then raise SendError.new('Cant send, connection is closing!')
          when CLOSED then raise SendError.new('Cant send, connection is closed!')
          end
        end

        alias send write

        private

        def ready_state
          @native_websocket.JS[:readyState]
        end

        def _delay(&block)
          `setTimeout(#{block.to_n}, 10)`
        end
      else
        def initialize(url, protocols = nil)
          @url = url
          parsed_url = URI.parse(url)
          host = parsed_url.host
          port = parsed_url.port
          @socket = TCPSocket.new(host, port)
          @driver = ::WebSocket::Driver.client(self)
          @driver.on(:message, &method(:internal_on_message))
          @driver.on(:close, &method(:internal_on_close))

          @thread = Thread.new do
            begin
              while data = @sock.readpartial(512)
                @driver.parse(data)
              end
            end
          end

          @driver.start
        end

        def close
          @driver.close
          @thread.kill
        end

        def on_close(&block)
          @on_close_block = block
        end

        def on_error(&block)
          @driver.on(:error, block)
        end

        def on_message(&block)
          @on_message_block = block
        end

        def on_open(&block)
          @driver.on(:open, block)
        end

        def protocol
          @driver.protocol
        end

        def send(data)
          json = Oj.dump(data, mode: :strict)
          @driver.text(json)
        end

        def write(data)
          @socket.write(data)
        end

        private

        def internal_on_close(event)
          @on_close_block.call(event)
          @thread.kill
        end

        def internal_on_message(event)
          data = Oj.load(event.data, mode: :strict)
          @on_message_block.call(data)
        end
      end
    end
  end
end