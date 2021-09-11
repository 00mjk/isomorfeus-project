module Isomorfeus
  module Transport
    class RedisSessionStore
      def initialize(*args)
        @redis_client = Redis.new(@args)
      end

      def add(session_id:, cookie:, user:, accessor:)
        @redis_client.pipelined do
          @redis_client.set(session_id, Oj.dump(user.to_sid, mode: :strict))
          @redis_client.set(accessor, cookie)
        end
      end

      def take_cookie(accessor:)
        cookie = @redis_client.get(accessor)
        if cookie
          session_info = cookie.split('; ').first
          session_id = session_info.split('=').last.strip
          @redis_client.pipelined do
            @redis_client.set("eaten_#{accessor}", session_id)
            @redis_client.del(accessor)
          end
          return cookie
        else
          # asked for the same cookie a second time
          # can probably only be due to session hijacking
          # so delete all sessions associated with that accessor
          session_id = @redis_client.get("eaten_#{accessor}")
          @redis_client.del(session_id) if session_id
          return nil
        end
      end

      def get_user(session_id:)
        json = @redis_client.get(session_id)
        if json
          user_sid = Oj.load(json, mode: :strict)
          return user_sid[0].constantize.load(key: user_sid[1]) if user_sid
        end
      end

      def remove(session_id:)
        @redis_client.del(session_id)
      end
    end
  end
end
