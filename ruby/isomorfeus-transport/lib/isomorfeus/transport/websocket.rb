module Isomorfeus
  module Transport
    class Websocket
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
                                `new Opal.global.WebSocket(url, protocols)`
                              else
                                `new Opal.global.WebSocket(url)`
                              end
        end

        def close
          @native_websocket.JS.close
          nil
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

        def on_open(&block)
          @native_websocket.JS[:onopen] = `function(event) { block.$call(event); }`
        end

        def protocol
          @native_websocket.JS[:protocol]
        end

        def send(data)
          case ready_state
          when OPEN then @native_websocket.JS.send(data)
          when CONNECTING then Isomorfeus::Transport.delay(50) { send(data) }
          when CLOSING then raise SendError.new('Cant send, connection is closing!')
          when CLOSED then raise SendError.new('Cant send, connection is closed!')
          end
        end

        private

        def ready_state
          @native_websocket.JS[:readyState]
        end
      else
        def initialize(url, protocols = nil)
          @url = url
          parsed_url = URI.parse(url)
          host = parsed_url.host
          port = parsed_url.port
          @socket = TCPSocket.new(host, port)
          @driver = ::WebSocket::Driver.client(self)
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
          @socket.write(data)
        end

        private

        def internal_on_close(event)
          @on_close_block.call(event)
          @thread.kill
        end
      end

      alias_method :write,  :send
    end
  end
end