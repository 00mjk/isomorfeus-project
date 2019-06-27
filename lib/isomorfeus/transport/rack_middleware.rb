# frozen_string_literal: true

module Isomorfeus
  module Transport
    class RackMiddleware
      include Isomorfeus::Transport::ServerProcessor

      WS_RESPONSE = [0, {}, []]

      def initialize(app)
        @app = app
      end

      def call(env)
        if env['PATH_INFO'] == Isomorfeus.api_websocket_path
          user = defined?(Warden::Manager) ? env['warden'].user : nil
          if env['rack.upgrade?'] == :websocket
            env['rack.upgrade'] = Isomorfeus::Transport::ServerSocketProcessor.new(env['rack.session'], user)
          end
          WS_RESPONSE
        else
          @app.call(env)
        end
      end
    end
  end
end
