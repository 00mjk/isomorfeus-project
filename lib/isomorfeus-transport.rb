if RUBY_ENGINE == 'opal'
  require 'isomorfeus/config'
  require 'isomorfeus/transport/request_agent'
  require 'isomorfeus/transport/client_drivers'
  require 'isomorfeus/transport/redux_middleware'

  Isomorfeus::Transport::ReduxMiddleware.add_middleware_to_store

  require 'isomorfeus/transport/reducers'

  Isomorfeus::Transport::Reducers.add_reducers_to_store

  require 'isomorfeus/transport'
  require 'isomorfeus/data_access'
else
  require 'oj'
  require 'active_support'
  require 'isomorfeus/config'
  require 'isomorfeus/promise'
  require 'isomorfeus/transport/config'
  require 'isomorfeus/transport/request_agent'
  require 'isomorfeus/transport/server_pub_sub'
  require 'isomorfeus/transport/request_processor'
  require 'isomorfeus/handler'
  require 'isomorfeus/transport/rack_middleware'
  Opal.append_path(__dir__.untaint) unless Opal.paths.include?(__dir__.untaint)

  # special treatment for rails
  if defined?(Rails)
    # TODO
    # insert Rack middleware before Rails.app_class.to_s.routes
    module Isomorfeus
      module Model
        class Railtie < Rails::Railtie
          def delete_first(a, e)
            a.delete_at(a.index(e) || a.length)
          end

          config.before_configuration do |_|
            Rails.configuration.tap do |config|
              if defined?(Warden::Manager)
                config.middleware.insert_after Warden::Manager, Isomorfeus::Transport::RackMiddleware
              else
                config.middleware.use Isomorfeus::Transport::RackMiddleware
              end
              config.eager_load_paths += %W(#{config.root}/app/isomorfeus/handlers)
              # rails will add everything immediately below app to eager and auto load, so we need to remove it
              delete_first config.eager_load_paths, "#{config.root}/app/isomorfeus"

              unless Rails.env.production?
                config.autoload_paths += %W(#{config.root}/app/isomorfeus/handlers)
                # rails will add everything immediately below app to eager and auto load, so we need to remove it
                delete_first config.autoload_paths, "#{config.root}/app/isomorfeus"
              end
            end
          end
        end
      end
    end
  else
    if Dir.exist?(File.join('app', 'isomorfeus'))
      $LOAD_PATH.unshift(File.expand_path(File.join('app', 'isomorfeus', 'handlers')))
    elsif Dir.exist?(File.join('isomorfeus'))
      $LOAD_PATH.unshift(File.expand_path(File.join('isomorfeus', 'handlers')))
    end
  end
end
