require 'opal'
require 'isomorfeus-store'
require 'isomorfeus-component'
require 'isomorfeus-transport'

if RUBY_ENGINE == 'opal'
  require 'promise'
  require 'native'
  require 'isomorfeus/props_wrapper'
  require 'isomorfeus/params/instance_methods'
  require 'isomorfeus/params/class_methods'
  require 'isomorfeus/validator'
  require 'isomorfeus/operation/class_methods'
  require 'isomorfeus/operation'
  require 'lucid_operation/mixin'
  require 'lucid_operation/base'
else
  require 'oj'
  require 'isomorfeus/promise'
  require 'isomorfeus/props_wrapper'
  require 'isomorfeus/params/instance_methods'
  require 'isomorfeus/params/class_methods'
  require 'isomorfeus/validator'
  require 'isomorfeus/operation/class_methods'
  require 'isomorfeus/operation'
  require 'isomorfeus/operation/security_guards'
  require 'isomorfeus/handler/operation_handler'
  require 'lucid_operation/mixin'
  require 'lucid_operation/base'

  Opal.append_path(__dir__.untaint) unless Opal.paths.include?(__dir__.untaint)
  if Dir.exist?(File.join('app', 'isomorfeus', 'operations'))
    # Opal.append_path(File.expand_path(File.join('app', 'isomorfeus', 'operations'))) <- opal-autoloader will handle this
    Opal.append_path(File.expand_path(File.join('app', 'isomorfeus'))) unless Opal.paths.include?(File.expand_path(File.join('app', 'isomorfeus')))
  elsif Dir.exist?(File.join('isomorfeus', 'operations'))
    # Opal.append_path(File.expand_path(File.join('isomorfeus', 'models', 'operations'))) <- opal-autoloader will handle this
    Opal.append_path(File.expand_path(File.join('isomorfeus'))) unless Opal.paths.include?(File.expand_path(File.join('isomorfeus')))
  end

  # special treatment for rails
  if defined?(Rails)
    module Isomorfeus
      class Operation
        class Railtie < Rails::Railtie
          def delete_first(a, e)
            a.delete_at(a.index(e) || a.length)
          end

          config.before_configuration do |_|
            Rails.configuration.tap do |config|
              config.eager_load_paths += %W(#{config.root}/app/isomorfeus/handlers)
              config.eager_load_paths += %W(#{config.root}/app/isomorfeus/operations)
              # rails will add everything immediately below app to eager and auto load, so we need to remove it
              delete_first config.eager_load_paths, "#{config.root}/app/isomorfeus"

              unless Rails.env.production?
                config.autoload_paths += %W(#{config.root}/app/isomorfeus/handlers)
                config.autoload_paths += %W(#{config.root}/app/isomorfeus/operations)
                # rails will add everything immediately below app to eager and auto load, so we need to remove it
                delete_first config.autoload_paths, "#{config.root}/app/isomorfeus"
              end
            end
          end
        end
      end
    end
  elsif Dir.exist?(File.join('app', 'isomorfeus'))
    # TODO unless
    $LOAD_PATH.unshift(File.expand_path(File.join('app', 'isomorfeus', 'handlers')))
    $LOAD_PATH.unshift(File.expand_path(File.join('app', 'isomorfeus', 'operations')))
  elsif Dir.exist?(File.join('isomorfeus'))
    $LOAD_PATH.unshift(File.expand_path(File.join('isomorfeus', 'handlers')))
    $LOAD_PATH.unshift(File.expand_path(File.join('isomorfeus', 'operations')))
  end
end
