# frozen_string_literal: true

module Isomorfeus
  module Transport
    class RackMiddleware
      WS_RESPONSE = [0, {}, []]

      def initialize(app)
        @app = app
      end

      def user_from_env(env)
        cookies = env['HTTP_COOKIE']
        if cookies
          cookies = cookies.split('; ')
          cookie = cookies.detect { |c| c.start_with?('session=') }
          if cookie
            session_id = cookie[8..-1]
            user = Isomorfeus.session_store.get_user(session_id: session_id)
            [user, session_id]
          end
        end
      end

      def call(env)
        if env['PATH_INFO'] == Isomorfeus.api_websocket_path
          if env['rack.upgrade?'] == :websocket
            user, _session_id = user_from_env(env)
            env['rack.upgrade'] = Isomorfeus::Transport::ServerSocketProcessor.new(user)
          end
          WS_RESPONSE
        elsif env['PATH_INFO'] == Isomorfeus.cookie_eater_path
          cookie_accessor, new_path = env['QUERY_STRING'].split('=')
          cookie = Isomorfeus.session_store.take_cookie(accessor: cookie_accessor)
          if new_path.start_with?('/')
            if cookie
              [302, { 'Location' => new_path, 'Set-Cookie' => cookie }, ["Cookie eaten!"]]
            else
              [302, { 'Location' => new_path }, ["No Cookie!"]]
            end
          else
            [404, {}, ["Must specify relative path!"]]
          end
        elsif env['PATH_INFO'] == Isomorfeus.api_logout_path
          user, session_id = user_from_env(env)
          if user
            begin
              Isomorfeus.session_store.remove(session_id: session_id)
              cookie = "session=#{session_id}; SameSite=Strict; HttpOnly; Path=/; expires=Thu, 01 Jan 1970 00:00:00 UTC#{'; Secure' if Isomorfeus.production?}"
              return [302, { 'Location' => '/', 'Set-Cookie' => cookie }, ["Logged out!"]]
            ensure
              Thread.current[:isomorfeus_user] = nil
              Thread.current[:isomorfeus_session_id] = nil
            end
          end
          return [302, { 'Location' => '/', 'Set-Cookie' => cookie }, ["Tried to log out!"]]
        else
          user, session_id = user_from_env(env)
          if user
            Thread.current[:isomorfeus_user] = user
            Thread.current[:isomorfeus_session_id] = session_id
          end
          begin
            result = @app.call(env)
          ensure
            Thread.current[:isomorfeus_user] = nil
            Thread.current[:isomorfeus_session_id] = nil
          end
          result
        end
      rescue Exception => e
        # TODO
        Isomorfeus.raise_error(error: e)
        return [500, {}, '']
      end
    end
  end
end
