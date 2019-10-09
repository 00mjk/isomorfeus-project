# frozen_string_literal: true

module Isomorfeus
  module Transport
    class RackMiddleware
      WS_RESPONSE = [0, {}, []]

      def initialize(app)
        @app = app
      end

      def call(env)
        if env['PATH_INFO'] == Isomorfeus.api_websocket_path
          if env['rack.upgrade?'] == :websocket
            # TODO get session cookie
            env['rack.upgrade'] = Isomorfeus::Transport::ServerSocketProcessor.new
          end
          WS_RESPONSE
        else
          @app.call(env)
        end
      end
    end
  end
end
