module Isomorfeus
  module Mailer
    module Imports
      def self.add
        Isomorfeus.assets['mail.js'].add_js_import('redux', 'Redux', '*')
        Isomorfeus.assets['mail.js'].add_js_import('preact', 'Preact', '*')
        Isomorfeus.assets['mail.js'].add_js_import('preact/hooks', 'PreactHooks', '*')
        Isomorfeus.assets['mail.js'].add_js_import('wouter-preact', nil, ['Router', 'Link', 'Redirect', 'Route', 'Switch'])

        Isomorfeus.assets['mail.js'].add_js_import('nano-css', 'NanoCSS', '*')
        %w[rule sheet nesting hydrate unitless global keyframes].each do |addon|
          Isomorfeus.assets['mail.js'].add_js_import("nano-css/addon/#{addon}", 'NanoCSSAddons', 'addon', addon)
        end
        Isomorfeus.assets['mail.js'].add_js_import("nano-css/addon/animate/fadeIn", 'NanoCSSAddons', 'addon', 'fadeIn')
        Isomorfeus.assets['mail.js'].add_js_import("nano-css/addon/animate/fadeOut", 'NanoCSSAddons', 'addon', 'fadeOut')

        Isomorfeus.assets['mail.js'].add_js_import('preact-render-to-string', 'Preact', ['render'], nil, 'renderToString')
        Isomorfeus.assets['mail.js'].add_js_import('wouter-preact/static-location', 'staticLocationHook')
        Isomorfeus.assets['mail.js'].add_js_import('ws', 'WebSocket')
        if Dir.exist?(Isomorfeus.app_root)
          Isomorfeus.assets['mail.js'].add_ruby_import('mail_loader') if File.exist?(File.join(Isomorfeus.app_root, 'mail_loader.rb'))
        end
      end
    end
  end
end