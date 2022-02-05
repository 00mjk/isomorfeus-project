module LucidTranslation
  module Mixin
    CONTEXT_SEPARATOR = "\004"
    NAMESPACE_SEPARATOR = '|'
    NIL_BLOCK = -> { nil }
    TRANSLATION_METHODS = [:_, :n_, :np_, :ns_, :p_, :s_]

    if RUBY_ENGINE == 'opal'
      def _(*keys, &block)
        domain = Isomorfeus.i18n_domain
        locale = Isomorfeus.locale
        Isomorfeus.raise_error(message: "I18n _(): no key given!") if keys.empty?
        result = Redux.fetch_by_path(:i18n_state, domain, locale, '_', keys)
        return result if result
        _promise_send_i18n_method(domain, locale, '_', keys)
        block_given? ? block.call : ''
      end

      def n_(*keys, count, &block)
        domain = Isomorfeus.i18n_domain
        locale = Isomorfeus.locale
        Isomorfeus.raise_error(message: "I18n n_(): no key given!") if keys.empty?
        result = Redux.fetch_by_path(:i18n_state, domain, locale, 'n_', keys + [count])
        return result if result
        _promise_send_i18n_method(domain, locale, 'n_', keys + [count])
        block_given? ? block.call : ''
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
        Isomorfeus.raise_error(message: "I18n ns_(): no args given!") if args.empty?
        result = Redux.fetch_by_path(:i18n_state, domain, locale, 'ns_', args)
        return result if result
        _promise_send_i18n_method(domain, locale, 'ns_', args)
        block_given? ? block.call : n_(*args).split(NAMESPACE_SEPARATOR).last
      end

      def p_(namespace, key, separator = nil, &block)
        domain = Isomorfeus.i18n_domain
        locale = Isomorfeus.locale
        args = separator ? [namespace, key, separator] : [namespace, key]
        result = Redux.fetch_by_path(:i18n_state, domain, locale, 'p_', args)
        return result if result
        _promise_send_i18n_method(domain, locale, 'p_', args)
        block_given? ? block.call : ''
      end

      def s_(key, separator = nil, &block)
        domain = Isomorfeus.i18n_domain
        locale = Isomorfeus.locale
        args = separator ? [key, separator] : [key]
        result = Redux.fetch_by_path(:i18n_state, domain, locale, 's_', args)
        return result if result
        _promise_send_i18n_method(domain, locale, 's_', args)
        block_given? ? block.call : ''
      end

      def N_(translate)
        translate
      end

      def Nn_(*keys)
        keys
      end

      TRANSLATION_METHODS.each do |method|
        define_method("d#{method}") do |domain, *args, &block|
          old_domain = Isomorfeus.i18n_domain
          begin
            Isomorfeus.i18n_domain = domain
            send(method, *args, &block)
          ensure
            Isomorfeus.i18n_domain = old_domain
          end
        end

        define_method("D#{method}") do |*args, &block|
          domain = Isomorfeus.i18n_domain
          locale = Isomorfeus.locale
          Isomorfeus.raise_error(message: "I18n D#{method}(): no args given!") if args.empty?
          result = Redux.fetch_by_path(:i18n_state, domain, locale, "D#{method}", args)
          return result if result
          _promise_send_i18n_method(domain, locale, "D#{method}", args)
          block_given? ? block.call : send(method, *args, &block)
        end
      end

      private

      def _promise_send_i18n_method(domain, locale, method, args)
        if Isomorfeus::I18n::Init.initialized?
          _promise_send_i18n_request(domain, locale, method, args)
        else
          Isomorfeus::I18n::Init.init_promise.then do
            _promise_send_i18n_request(domain, locale, method, args)
          end
        end
      end

      def _promise_send_i18n_request(domain, locale, method, args)
        Isomorfeus::Transport.promise_send_path('Isomorfeus::I18n::Handler::LocaleHandler', domain, locale, method, args).then do |agent|
          _handle_i18n_response(agent, domain)
        end
      end

      def _handle_i18n_response(agent, domain)
        agent.process do
          if on_browser?
            Isomorfeus.store.collect_and_defer_dispatch(type: 'I18N_LOAD', data: { domain => agent.response[domain] })
          else
            Isomorfeus.store.dispatch(type: 'I18N_LOAD', data: { domain => agent.response[domain] })
          end
        end
      end
    else
      class InternalTranslationProxy
        extend FastGettext::Translation
        extend FastGettext::TranslationMultidomain
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
