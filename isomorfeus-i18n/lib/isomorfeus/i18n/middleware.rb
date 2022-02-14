# frozen_string_literal: true

module Isomorfeus
  module I18n
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        locale = env.http_accept_language.preferred_language_from(Isomorfeus.available_locales) ||
                   env.http_accept_language.compatible_language_from(Isomorfeus.available_locales) ||
                   Isomorfeus.default_locale
        Isomorfeus.current_locale = locale if Isomorfeus.current_locale != locale
        @app.call(env)
      end
    end
  end
end
