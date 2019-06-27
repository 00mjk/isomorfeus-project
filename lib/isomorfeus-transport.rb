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
  require 'isomorfeus/handler'
  require 'isomorfeus/transport/rack_middleware'
  Opal.append_path(__dir__.untaint) unless Opal.paths.include?(__dir__.untaint)

  require 'isomorfeus/transport/middlewares'

  Isomorfeus.add_middleware(Isomorfeus::Transport::RackMiddleware)

  if Dir.exist?(File.join('app', 'isomorfeus'))
    $LOAD_PATH.unshift(File.expand_path(File.join('app', 'isomorfeus', 'handlers')))
  elsif Dir.exist?(File.join('isomorfeus'))
    $LOAD_PATH.unshift(File.expand_path(File.join('isomorfeus', 'handlers')))
  end
end
