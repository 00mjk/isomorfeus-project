if RUBY_ENGINE == 'opal'
  require 'json'
  require 'isomorfeus/config'
  require 'isomorfeus/transport/config'
  require 'isomorfeus/transport/request_agent'
  require 'isomorfeus/transport/processor'
  require 'isomorfeus/transport'
  Isomorfeus::Transport.init!
else
  require 'oj'
  require 'socket'
  require 'websocket/driver'
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

  require 'isomorfeus/transport/middlewares'

  Isomorfeus.add_middleware(Isomorfeus::Transport::RackMiddleware)

  if Dir.exist?(File.join('app', 'isomorfeus'))
    $LOAD_PATH.unshift(File.expand_path(File.join('app', 'isomorfeus', 'handlers')))
  elsif Dir.exist?(File.join('isomorfeus'))
    $LOAD_PATH.unshift(File.expand_path(File.join('isomorfeus', 'handlers')))
  end
end
