require 'isomorfeus-policy'
require 'lucid_authentication/mixin'
if RUBY_ENGINE == 'opal'
  require 'json'
  require 'isomorfeus/transport/version'
  require 'isomorfeus/transport/config'
  require 'isomorfeus/transport/request_agent'
  require 'isomorfeus/transport/client_processor'
  require 'isomorfeus/transport/websocket_client'
  require 'isomorfeus/transport'
  require 'isomorfeus/transport/ssr_login'
  require 'lucid_channel/mixin'
  require 'lucid_channel/base'
  Isomorfeus.zeitwerk.push_dir('channels')
  Isomorfeus.add_client_init_class_name('Isomorfeus::Transport')
  Isomorfeus.add_transport_init_class_name('Isomorfeus::Transport::SsrLogin') if Isomorfeus.on_ssr?
else
  require 'base64'
  require 'digest'
  require 'bcrypt'
  require 'securerandom'
  require 'fileutils'
  require 'ostruct'
  require 'socket'
  require 'sorted_set'
  require 'oj'
  require 'active_support'
  require 'isomorfeus-asset-manager'
  require 'isomorfeus-hamster'
  require 'isomorfeus/transport/hamster_session_store'
  opal_path = Gem::Specification.find_by_name('opal').full_gem_path
  promise_path = File.join(opal_path, 'stdlib', 'promise.rb')
  require promise_path
  require 'isomorfeus/transport/version'
  require 'isomorfeus/transport/response_agent'
  require 'isomorfeus/transport/config'
  require 'isomorfeus/transport/middlewares'
  require 'isomorfeus/transport/request_agent'
  require 'isomorfeus/transport/server_processor'
  require 'isomorfeus/transport/server_socket_processor'
  require 'isomorfeus/transport/websocket_client'
  require 'isomorfeus/transport'
  require 'isomorfeus/transport/rack_middleware'
  require 'isomorfeus/transport/middlewares'

  Isomorfeus.add_middleware(Isomorfeus::Transport::RackMiddleware)
  Isomorfeus.add_middleware(Isomorfeus::AssetManager::RackMiddleware)

  require 'lucid_handler/mixin'
  require 'lucid_handler/base'
  require 'lucid_channel/mixin'
  require 'lucid_channel/base'

  require 'isomorfeus/transport/handler/authentication_handler'

  require 'iso_opal'
  Opal.append_path(__dir__.untaint) unless IsoOpal.paths_include?(__dir__.untaint)

  %w[channels handlers server].each do |dir|
    path =  File.expand_path(File.join('app', dir))
    if Dir.exist?(path)
      Isomorfeus.zeitwerk.push_dir(path)
    end
  end

  require 'isomorfeus-speednode'
  Isomorfeus.node_paths << File.expand_path(File.join(File.dirname(__FILE__), '..', 'node_modules'))

  require 'isomorfeus/transport/imports'
  Isomorfeus::Transport::Imports.add
end
