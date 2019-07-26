require 'opal'
require 'opal-autoloader'
require 'opal-activesupport'
if RUBY_ENGINE == 'opal'
  require 'json'
  require 'isomorfeus/config'
  require 'isomorfeus/execution_environment'
  require 'isomorfeus/transport/version'
  require 'isomorfeus/transport/config'
  require 'isomorfeus/transport/request_agent'
  require 'isomorfeus/transport/client_processor'
  require 'isomorfeus/transport/websocket'
  require 'isomorfeus/transport'
  require 'lucid_channel/mixin'
  require 'lucid_channel/base'
  Opal::Autoloader.add_load_path('channels')
  Isomorfeus::Transport.init!
else
  require 'base64'
  require 'digest'
  require 'socket'
  require 'oj'
  require 'websocket/driver'
  require 'active_support'
  require 'iodine'
  require 'isomorfeus/config'
  require 'isomorfeus/promise'
  require 'isomorfeus/transport/version'
  require 'isomorfeus/transport/config'
  require 'isomorfeus/transport/middlewares'
  require 'isomorfeus/transport/request_agent'
  require 'isomorfeus/transport/server_processor'
  require 'isomorfeus/transport/server_socket_processor'
  require 'isomorfeus/transport/websocket'
  require 'isomorfeus/transport/rack_middleware'
  require 'isomorfeus/transport/middlewares'

  Isomorfeus.add_middleware(Isomorfeus::Transport::RackMiddleware)
  Isomorfeus.valid_channel_class_names

  require 'lucid_handler/mixin'
  require 'lucid_handler/base'
  require 'lucid_channel/mixin'
  require 'lucid_channel/base'

  Opal.append_path(__dir__.untaint) unless Opal.paths.include?(__dir__.untaint)

  require 'active_support'
  require 'active_support/dependencies'

  %w[channels handlers].each do |dir|
    path = if Dir.exist?(File.join('app', 'isomorfeus'))
             File.expand_path(File.join('app', 'isomorfeus', dir))
           elsif Dir.exist?(File.join('isomorfeus'))
             File.expand_path(File.join('isomorfeus', dir))
           end
    ActiveSupport::Dependencies.autoload_paths << path if path
    # we also need to require them all, so classes are registered accordingly
    Dir.glob("#{path}/**/*.rb").each do |file|
      require file
    end
  end
end
