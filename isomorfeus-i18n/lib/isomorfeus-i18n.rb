require 'isomorfeus-transport'

if RUBY_ENGINE == 'opal'
  require 'isomorfeus/i18n/config'
  require 'isomorfeus/i18n/reducer'
  Isomorfeus::I18n::Reducer.add_reducer_to_store
  require 'lucid_translation/mixin'
  require 'isomorfeus/i18n/init'
  if Isomorfeus.on_browser?
    Isomorfeus.add_client_init_after_store_class_name('Isomorfeus::I18n::Init')
  else
    Isomorfeus.add_transport_init_class_name('Isomorfeus::I18n::Init')
  end
else
  require 'active_support'
  require 'oj'
  require 'fast_gettext'
  require 'http_accept_language/parser'
  require 'http_accept_language/middleware'
  require 'isomorfeus-data'
  require 'isomorfeus/i18n/config'
  require 'isomorfeus/i18n/init'
  require 'lucid_translation/mixin'
  require 'isomorfeus/i18n/handler/locale_handler'

  Isomorfeus.add_middleware(HttpAcceptLanguage::Middleware)

  require 'iso_opal'
  Opal.append_path(__dir__.untaint) unless IsoOpal.paths.include?(__dir__.untaint)

  Isomorfeus.locale_path = File.expand_path(File.join('app', 'locales'))

  # identify available locales
  locales = []

  Dir.glob("#{Isomorfeus.locale_path}/**/*.mo").each do |file|
    locales << File.basename(file, '.mo')
  end
  Isomorfeus.i18n_type = :mo unless locales.empty?

  unless Isomorfeus.i18n_type
    locales = []
    Dir.glob("#{Isomorfeus.locale_path}/**/*.po").each do |file|
      locales << File.basename(file, '.po')
    end
    Isomorfeus.i18n_type = :po unless locales.empty?
  end

  unless Isomorfeus.i18n_type
    locales = []
    Dir.glob("#{Isomorfeus.locale_path}/**/*.yaml").each do |file|
      locales << File.basename(file, '.yaml')
    end
    Dir.glob("#{Isomorfeus.locale_path}/**/*.yml").each do |file|
      locales << File.basename(file, '.yml')
    end
    Isomorfeus.i18n_type = :yaml unless locales.empty?
  end

  Isomorfeus.available_locales = locales
  Isomorfeus.available_locales = ['en'] if Isomorfeus.available_locales.empty?

  if Isomorfeus.available_locales.include?('en')
    Isomorfeus.locale = 'en'
  else
    Isomorfeus.locale = Isomorfeus.available_locales.first
  end

  Isomorfeus.i18n_domain = 'app'

  Isomorfeus::I18n::Init.init
end
