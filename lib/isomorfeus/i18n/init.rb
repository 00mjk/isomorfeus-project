module Isomorfeus
  module I18n
    class Init
      if RUBY_ENGINE == 'opal'
        def self.init
          return if @initializing || initialized?
          @initializing = true
          if Isomorfeus.on_browser?
            root_element = `document.querySelector('div[data-iso-root]')`
            Isomorfeus.negotiated_locale = root_element.JS.getAttribute('data-iso-nloc')
          end
          Isomorfeus::Transport.promise_send_path('Isomorfeus::I18n::Handler::LocaleHandler', :init, Isomorfeus.negotiated_locale).then do |response|
            if response[:agent_response].key?(:error)
              `console.error(#{response[:agent_response][:error].to_n})`
              raise response[:agent_response][:error]
            end
            @initializing = false
            Isomorfeus.store.dispatch(type: 'I18N_LOAD', data: response[:agent_response][:data])
          end
        end

        def self.initialized?
          result = Redux.register_and_fetch_by_path(:i18n_state, :available_locales)
          result ? true : false
        end
      else
        def self.init
          FastGettext.add_text_domain(Isomorfeus.i18n_domain, path: Isomorfeus.locale_path, type: Isomorfeus.i18n_type)
          FastGettext.available_locales = Isomorfeus.available_locales
          FastGettext.text_domain = Isomorfeus.i18n_domain
          FastGettext.locale = Isomorfeus.locale
          Thread.current[:isomorfeus_i18n_initialized] = true
        end
      end
    end
  end
end
