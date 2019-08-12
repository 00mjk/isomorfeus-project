module LucidTranslation
  module Mixin
    CONTEXT_SEPARATOR = "\004"
    NAMESPACE_SEPARATOR = '|'
    NIL_BLOCK = -> { nil }
    TRANSLATION_METHODS = [:_, :n_, :np_, :ns_, :p_, :s_]

    if RUBY_ENGINE != 'opal'
      class InternalTranslationProxy
        extend FastGettext::Translation
        extend FastGettext::TranslationMultidomain
      end
    end

    def self.included(base)
      if RUBY_ENGINE == 'opal'
        base.instance_exec do
          def _(*keys, &block)
            domain = Isomorfeus.i18n_domain
            locale = Isomorfeus.locale
            result = Redux.register_and_fetch_by_path(:i18n_state, domain, locale, '_', keys)
            return result if result
            if Isomorfeus::I18n::Init.initialized?
              Isomorfeus::Transport.promise_send_path('Isomorfeus::I18n::Handler::LocaleHandler', domain, locale, '_', keys).then do |response|
                if response[:agent_response].key?(:error)
                  `console.error(#{response[:agent_response][:error].to_n})`
                  raise response[:agent_response][:error]
                end
                Isomorfeus.store.dispatch(type: 'I18N_LOAD', data: { domain => response[:agent_response][domain] })
              end
            end
            block_given? ? block.call : keys.first
          end

          def n_(*keys, count, &block)
            domain = Isomorfeus.i18n_domain
            locale = Isomorfeus.locale
            result = Redux.register_and_fetch_by_path(:i18n_state, domain, locale, 'n_', keys + [count])
            return result if result
            if Isomorfeus::I18n::Init.initialized?
              Isomorfeus::Transport.promise_send_path('Isomorfeus::I18n::Handler::LocaleHandler', domain, locale, 'n_', keys + [count]).then do |response|
                if response[:agent_response].key?(:error)
                  `console.error(#{response[:agent_response][:error].to_n})`
                  raise response[:agent_response][:error]
                end
                Isomorfeus.store.dispatch(type: 'I18N_LOAD', data: { domain => response[:agent_response][domain] })
              end
            end
            block_given? ? block.call : keys.last
          end

          def np_(context, plural_one, *args, separator: nil, &block)
            nargs = ["#{context}#{separator || CONTEXT_SEPARATOR}#{plural_one}"] + args
            translation = n_(*nargs, &NIL_BLOCK)
            return translation if translation

            block_given? ? block.call : n_(plural_one, *args)
          end

          def ns_(*args, &block)
            domain = Isomorfeus.i18n_domain
            locale = Isomorfeus.locale
            result = Redux.register_and_fetch_by_path(:i18n_state, domain, locale, 'ns_', args)
            return result if result
            if Isomorfeus::I18n::Init.initialized?
              Isomorfeus::Transport.promise_send_path('Isomorfeus::I18n::Handler::LocaleHandler', domain, locale, 'ns_', args).then do |response|
                if response[:agent_response].key?(:error)
                  `console.error(#{response[:agent_response][:error].to_n})`
                  raise response[:agent_response][:error]
                end
                Isomorfeus.store.dispatch(type: 'I18N_LOAD', data: { domain => response[:agent_response][domain] })
              end
            end
            block_given? ? block.call : n_(*args).split(NAMESPACE_SEPARATOR).last
          end

          def p_(namespace, key, separator = nil, &block)
            domain = Isomorfeus.i18n_domain
            locale = Isomorfeus.locale
            args = separator ? [namespace, key, separator] : [namespace, key]
            result = Redux.register_and_fetch_by_path(:i18n_state, domain, locale, 'p_', args)
            return result if result
            if Isomorfeus::I18n::Init.initialized?
              Isomorfeus::Transport.promise_send_path('Isomorfeus::I18n::Handler::LocaleHandler', domain, locale, 'p_', args).then do |response|
                if response[:agent_response].key?(:error)
                  `console.error(#{response[:agent_response][:error].to_n})`
                  raise response[:agent_response][:error]
                end
                Isomorfeus.store.dispatch(type: 'I18N_LOAD', data: { domain => response[:agent_response][domain] })
              end
            end
            block_given? ? block.call : key
          end

          def s_(key, separator = nil, &block)
            domain = Isomorfeus.i18n_domain
            locale = Isomorfeus.locale
            args = separator ? [key, separator] : [key]
            result = Redux.register_and_fetch_by_path(:i18n_state, domain, locale, 's_', args)
            return result if result
            if Isomorfeus::I18n::Init.initialized?
              Isomorfeus::Transport.promise_send_path('Isomorfeus::I18n::Handler::LocaleHandler', domain, locale, 's_', args).then do |response|
                if response[:agent_response].key?(:error)
                  `console.error(#{response[:agent_response][:error].to_n})`
                  raise response[:agent_response][:error]
                end
                Isomorfeus.store.dispatch(type: 'I18N_LOAD', data: { domain => response[:agent_response][domain] })
              end
            end
            block_given? ? block.call : key.split(separator || NAMESPACE_SEPARATOR).last
          end

          def N_(translate)
            translate
          end

          def Nn_(*keys)
            keys
          end

          TRANSLATION_METHODS.each do |method|
            define_singleton_method("d#{method}") do |domain, *args, &block|
              old_domain = Isomorfeus.i18n_domain
              begin
                Isomorfeus.i18n_domain = domain
                send(method, *args, &block)
              ensure
                Isomorfeus.i18n_domain = old_domain
              end
            end

            define_singleton_method("D#{method}") do |*args, &block|
              domain = Isomorfeus.i18n_domain
              locale = Isomorfeus.locale
              result = Redux.register_and_fetch_by_path(:i18n_state, domain, locale, "D#{method}", args)
              return result if result
              if Isomorfeus::I18n::Init.initialized?
                Isomorfeus::Transport.promise_send_path('Isomorfeus::I18n::Handler::LocaleHandler', domain, locale, "D#{method}", args).then do |response|
                  if response[:agent_response].key?(:error)
                    `console.error(#{response[:agent_response][:error].to_n})`
                    raise response[:agent_response][:error]
                  end
                  Isomorfeus.store.dispatch(type: 'I18N_LOAD', data: { domain => response[:agent_response][domain] })
                end
              end
              block_given? ? block.call : send(method, *args, &block)
            end
          end
        end

        def _(*args, &block)
          self.class._(*args, &block)
        end

        def n_(*args, &block)
          self.class.n_(*args, &block)
        end

        def np_(*args, &block)
          self.class.np_(*args, &block)
        end

        def ns_(*args, &block)
          self.class.n_(*args, &block)
        end

        def p_(*args, &block)
          self.class.p_(*args, &block)
        end

        def s(*args, &block)
          self.class.s_(*args, &block)
        end

        def N_(translate)
          translate
        end

        def Nn_(*keys)
          keys
        end

        TRANSLATION_METHODS.each do |method|
          # translate in given domain
          define_method("d#{method}") do |domain, *args, &block|
            self.class.send("d#{method}", domain, *args, &block)
          end

          define_method("D#{method}") do |*args, &block|
            self.class.send("D#{method}", *args, &block)
          end
        end
      else
        base.instance_exec do
          TRANSLATION_METHODS.each do |method|
            define_singleton_method(method) do |*args, &block|
              Isomorfeus::I18n::Init.init unless Thread.current[:isomorfeus_i18n_initialized] == true
              InternalTranslationProxy.send(method, *args, &block)
            end

            define_singleton_method("d#{method}") do |domain, *args, &block|
              Isomorfeus::I18n::Init.init unless Thread.current[:isomorfeus_i18n_initialized] == true
              InternalTranslationProxy.send("d#{method}", domain, *args, &block)
            end

            define_singleton_method("D#{method}") do |*args, &block|
              Isomorfeus::I18n::Init.init unless Thread.current[:isomorfeus_i18n_initialized] == true
              InternalTranslationProxy.send.send("D#{method}", *args, &block)
            end
          end
        end

        TRANSLATION_METHODS.each do |method|
          define_method(method) do |domain, *args, &block|
            Isomorfeus::I18n::Init.init unless Thread.current[:isomorfeus_i18n_initialized] == true
            InternalTranslationProxy.send(method, domain, *args, &block)
          end

          define_method("d#{method}") do |domain, *args, &block|
            Isomorfeus::I18n::Init.init unless Thread.current[:isomorfeus_i18n_initialized] == true
            InternalTranslationProxy.send("d#{method}", domain, *args, &block)
          end

          define_method("D#{method}") do |*args, &block|
            Isomorfeus::I18n::Init.init unless Thread.current[:isomorfeus_i18n_initialized] == true
            InternalTranslationProxy.send("D#{method}", *args, &block)
          end
        end
      end
    end
  end
end
