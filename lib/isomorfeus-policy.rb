require 'opal-activesupport'
require 'isomorfeus-transport'

if RUBY_ENGINE == 'opal'
  require 'isomorfeus_policy_processor'
  # nothing else
else
  require 'active_support'
  require 'oj'
  require 'isomorfeus/promise'
  require 'isomorfeus/policy/class_methods'
  require 'isomorfeus/policy/instance_methods'
  require 'isomorfeus/policy/definition'
  require 'isomorfeus/policy'
  require 'isomorfeus/policy/driver'
  require 'isomorfeus/policy/config'
  require 'isomorfeus/handler/policy_handler'

  Opal.append_path(__dir__.untaint) unless Opal.paths.include?(__dir__.untaint)

  if Dir.exist?(File.join('app', 'isomorfeus', 'policies'))
    Opal.append_path(File.expand_path(File.join('app', 'isomorfeus', 'policies')))
    Opal.append_path(File.expand_path(File.join('app', 'isomorfeus'))) unless Opal.paths.include?(File.expand_path(File.join('app', 'isomorfeus')))
  elsif Dir.exist?(File.join('isomorfeus', 'models'))
    Opal.append_path(File.expand_path(File.join('isomorfeus', 'policies')))
    Opal.append_path(File.expand_path(File.join('isomorfeus'))) unless Opal.paths.include?(File.expand_path(File.join('isomorfeus')))
  end

  if defined?(Rails)
    module Isomorfeus
      module Policy
        class Railtie < Rails::Railtie
          def delete_first(a, e)
            a.delete_at(a.index(e) || a.length)
          end

          config.before_configuration do |_|
            Rails.configuration.tap do |config|
              config.eager_load_paths += %W(#{config.root}/app/isomorfeus/policies)
              delete_first config.eager_load_paths, "#{config.root}/app/isomorfeus"

              unless Rails.env.production?
                config.autoload_paths += %W(#{config.root}/app/isomorfeus/policies)
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
    $LOAD_PATH.unshift(File.expand_path(File.join('app', 'isomorfeus', 'policies')))
  elsif Dir.exist?(File.join('isomorfeus'))
    $LOAD_PATH.unshift(File.expand_path(File.join('isomorfeus', 'policies')))
  end
end