module Isomorfeus
  module Transport
    module Imports
      def self.add
        Isomorfeus.add_ssr_js_import('ws', 'WebSocket')
      end
    end
  end
end
