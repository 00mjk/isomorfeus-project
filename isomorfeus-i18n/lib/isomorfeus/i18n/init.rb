module Isomorfeus
  module I18n
    class Init
      class << self
        if RUBY_ENGINE == 'opal'
          attr_accessor :init_promise

          def init
            return if @initializing || initialized?
            @initializing = true
            @initialized = false
            if Isomorfeus.on_browser?
              root_element = `document.querySelector('div[data-iso-root]')`
              Isomorfeus.negotiated_locale = root_element.JS.getAttribute('data-iso-nloc') if root_element
            end
            self.init_promise = init_from_server
          end

          def init_from_server
            Isomorfeus::Transport.promise_send_path('Isomorfeus::I18n::Handler::LocaleHandler', :init, Isomorfeus.negotiated_locale).then do |agent|
              if agent.processed
                agent.result
              else
                agent.processed = true
                if agent.response.key?(:error)
                  Isomorfeus.raise_error(message: agent.response[:error])
                end
                @initializing = false
                Isomorfeus.store.dispatch(type: 'I18N_LOAD', data: agent.response[:data])
                @initialized = true
              end
            end
          end

          def reload_from_server
            Isomorfeus::Transport.promise_send_path('Isomorfeus::I18n::Handler::LocaleHandler', :init, Isomorfeus.negotiated_locale).then do |agent|
              if agent.processed
                agent.result
              else
                agent.processed = true
                if agent.response.key?(:error)
                  Isomorfeus.raise_error(message: agent.response[:error])
                end
                Isomorfeus.store.dispatch(type: 'I18N_STATE', set_state: agent.response[:data])
              end
            end
          end

          def initialized?
            @initialized
          end
        else
          def init
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
end
