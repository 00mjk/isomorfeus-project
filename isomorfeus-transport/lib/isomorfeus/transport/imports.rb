module Isomorfeus
  module Transport
    module Imports
      def self.add
        Isomorfeus.add_ssr_js_import('ws', 'WebSocket')
        Isomorfeus.add_ssr_ruby_import('isomorfeus/transport/ssr_login')
      end
    end
  end
end
