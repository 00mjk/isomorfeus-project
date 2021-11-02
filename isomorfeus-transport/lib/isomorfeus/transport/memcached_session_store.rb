module Isomorfeus
  module Professional
    class MemcachedSessionStore
      def initialize(*args)
        @dalli_client = Dalli::Client.new(*args)
      end

      def add(session_id:, cookie:, user:, accessor:)
        @dalli_client.multi do
          @dalli_client.set(session_id, Oj.dump(user.sid, mode: :strict))
          @dalli_client.set(accessor, cookie)
        end
      end

      def take_cookie(accessor:)
        cookie = @dalli_client.get(accessor)
        if cookie
          session_info = cookie.split('; ').first
          session_id = session_info.split('=').last.strip
          @dalli_client.multi do
            @dalli_client.set("eaten_#{accessor}", session_id)
            @dalli_client.delete(accessor)
          end
          return cookie
        else
          # asked for the same cookie a second time
          # can probably only be due to session hijacking
          # so delete all sessions associated with that accessor
          session_id = @dalli_client.get("eaten_#{accessor}")
          @dalli_client.delete(session_id) if session_id
          return nil
        end
      end

      def get_user(session_id:)
        json = @dalli_client.get(session_id)
        if json
          user_sid = Oj.load(json, mode: :strict)
          return user_sid[0].constantize.load(key: user_sid[1]) if user_sid
        end
      end

      def remove(session_id:)
        @dalli_client.delete(session_id)
      end
    end
  end
end
