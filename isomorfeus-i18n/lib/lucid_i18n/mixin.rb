module LucidI18n
  module Mixin
    CONTEXT_SEPARATOR = "\004"
    NAMESPACE_SEPARATOR = '|'
    NIL_BLOCK = -> { nil }
    TRANSLATION_METHODS = [:_, :n_, :np_, :ns_, :p_, :s_]

    def current_locale
      Isomorfeus.current_locale
    end

    if RUBY_ENGINE == 'opal'
      def _(*keys, &block)
        domain = Isomorfeus.i18n_domain
        locale = Isomorfeus.current_locale
        Isomorfeus.raise_error(message: "I18n _(): no key given!") if keys.empty?
        result = Redux.fetch_by_path(:i18n_state, domain, locale, '_', keys)
        return result if result
        _promise_send_i18n_method(domain, locale, '_', keys)
        block_given? ? block.call : ''
      end

      def n_(*keys, count, &block)
        domain = Isomorfeus.i18n_domain
        locale = Isomorfeus.current_locale
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
        locale = Isomorfeus.current_locale
        Isomorfeus.raise_error(message: "I18n ns_(): no args given!") if args.empty?
        result = Redux.fetch_by_path(:i18n_state, domain, locale, 'ns_', args)
        return result if result
        _promise_send_i18n_method(domain, locale, 'ns_', args)
        block_given? ? block.call : n_(*args).split(NAMESPACE_SEPARATOR).last
      end

      def p_(namespace, key, separator = nil, &block)
        domain = Isomorfeus.i18n_domain
        locale = Isomorfeus.current_locale
        args = separator ? [namespace, key, separator] : [namespace, key]
        result = Redux.fetch_by_path(:i18n_state, domain, locale, 'p_', args)
        return result if result
        _promise_send_i18n_method(domain, locale, 'p_', args)
        block_given? ? block.call : ''
      end

      def s_(key, separator = nil, &block)
        domain = Isomorfeus.i18n_domain
        locale = Isomorfeus.current_locale
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
          locale = Isomorfeus.current_locale
          Isomorfeus.raise_error(message: "I18n D#{method}(): no args given!") if args.empty?
          result = Redux.fetch_by_path(:i18n_state, domain, locale, "D#{method}", args)
          return result if result
          _promise_send_i18n_method(domain, locale, "D#{method}", args)
          block_given? ? block.call : send(method, *args, &block)
        end
      end

      def l(object, format = :standard, options = {})
        c_name = object.class.to_s
        locale = options.delete(:locale) { Isomorfeus.current_locale }
        options = options.transform_keys { |k| `Opal.Preact.lower_camelize(k)` }
        if object.is_a?(Numeric)
          # options for number formatting:
          # locale: locale string like 'de'
          # currency: any currency code (like "EUR", "USD", "INR", etc.)
          # currency_display or currencyDisplay: "symbol"(default) "code" "name"
          # locale_matcher or localeMatcher: "best-fit"(default) "lookup"
          # maximum_fraction_digits or maximumFractionDigits: A number from 0 to 20 (default is 3)
          # maximum_significant_digits or maximumSignificantDigits: A number from 1 to 21 (default is 21)
          # minimum_fraction_digits or minimumFractionDigits: A number from 0 to 20 (default is 3)
          # minimum_integer_digits or minimumIntegerDigits:	A number from 1 to 21 (default is 1)
          # minimum_significant_digits or minimumSignificantDigits:	A number from 1 to 21 (default is 21)
          # style: "decimal"(default) "currency" "percent"
          # use_grouping or useGrouping: true(default) false
          `(object).toLocaleString(locale, #{options.to_n})`
        elsif c_name == 'Date' || c_name == 'DateTime'
          # options for date/time formating:
          # format: "standard" "full"
          # locale: locale string like 'de'
          # time_zone or timeZone: timezone string like 'CET'
          # time_zone_name or timeZoneName: "long" "short"
          # date_style or dateStyle: "full" "long" "medium" "short"
          # time_style or timeStyle: "full" "long" "medium" "short"
          # format_matcher or formatMatcher: "best-fit"(default) "basic"
          # locale_matcher or localeMatcher: "best-fit"(default) "lookup"
          # hour12: false true
          # hour_cycle hourCycle: "h11" "h12" "h23" "h24"
          # hour:	   "2-digit" "numeric"
          # minute:	 "2-digit" "numeric"
          # second:	 "2-digit" "numeric"
          # day	     "2-digit" "numeric"
          # month:   "2-digit" "numeric" "long" "short" "narrow"
          # weekday:                     "long" "short" "narrow"
          # year:	   "2-digit" "numeric"
          native_object = object.to_n
          case format
          when :standard
            `native_object.toLocaleDateString(locale, #{options.to_n})`
          when :full
            options[:dateStyle] = 'long'
            `native_object.toLocaleDateString(locale, #{options.to_n})`
          when :custom
            `native_object.toLocaleString(locale, #{options.to_n})`
          else
            `native_object.toLocaleDateString(locale, #{options.to_n})`
          end
        elsif c_name == 'Time'
          native_object = object.to_n
          case format
          when :standard
            `native_object.toLocaleString(locale, #{options.to_n})`
          when :full
            options[:dateStyle] = 'long'
            options[:timeStyle] = 'short'
            `native_object.toLocaleString(locale, #{options.to_n})`
          when :custom
            `native_object.toLocaleString(locale, #{options.to_n})`
          else
            `native_object.toLocaleString(locale, #{options.to_n})`
          end
        else
          raise "Unknown object type #{object.class} given to #l!"
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
    else # RUBY_ENGINE
      class InternalTranslationProxy
        extend FastGettext::Translation
        extend FastGettext::TranslationMultidomain
      end

      def l(object, format = :standard, _options = {})
        Isomorfeus::I18n::Init.init unless Thread.current[:isomorfeus_i18n_initialized] == true
        R18n.l(object, format)
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
    end # RUBY_ENGINE
  end
end
