module Isomorfeus
  # available settings
  class << self
    attr_accessor :i18n_type

    if RUBY_ENGINE == 'opal'
      def available_locales
        result = Redux.fetch_by_path(:i18n_state, :available_locales)
        result ? result : ['en']
      end

      def i18n_domain
        result = Redux.fetch_by_path(:i18n_state, :domain)
        result ? result : 'app'
      end

      def i18n_domain=(domain)
        Isomorfeus.store.dispatch(type: 'I18N_LOAD', data: { domain: domain })
        domain
      end

      def locale
        result = Redux.fetch_by_path(:i18n_state, :locale)
        result ? result : available_locales.first
      end

      def locale=(loc)
        Isomorfeus.raise_error(message: "Locale #{loc} not available!") unless available_locales.include?(loc)
        Isomorfeus.store.dispatch(type: 'I18N_LOAD', data: { locale: locale })
        loc
      end

      def negotiated_locale
        @negotiated_locale
      end

      def negotiated_locale=(l)
        @negotiated_locale = l
      end
    else
      def available_locales
        @available_locales
      end

      def available_locales=(locs_arr)
        FastGettext.available_locales = locs_arr
        @available_locales = locs_arr
      end

      def i18n_domain
        @i18n_domain
      end

      def i18n_domain=(domain)
        FastGettext.text_domain = domain
        @i18n_domain = domain
      end

      def locale
        @locale
      end

      def locale=(loc)
        Isomorfeus.raise_error(message: "Locale #{loc} not available!") unless available_locales.include?(loc)
        FastGettext.locale = loc
        @locale = loc
      end

      def locale_path
        @locale_path
      end

      def locale_path=(path)
        @locale_path = path
      end
    end
  end
end
