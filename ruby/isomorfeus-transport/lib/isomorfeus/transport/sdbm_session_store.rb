module Isomorfeus
  module Transport
    class SdbmSessionStore
      def initialize(cookie_sdbm_path)
        @cookie_sdbm_path = cookie_sdbm_path
        SDBM.open(@cookie_sdbm_path, 0640).close
      end

      def add(session_id:, cookie:, user:, accessor:)
        SDBM.open(@cookie_sdbm_path, 0640) do |sdbm|
          sdbm[session_id] = Oj.dump([user.class.to_s, user.key], mode: :strict)
          sdbm[accessor] = cookie
        end
      end

      def take_cookie(accessor:)
        SDBM.open(@cookie_sdbm_path, 0640) do |sdbm|
          cookie = sdbm[accessor]
          if cookie
            session_info = cookie.split('; ').first
            session_id = session_info.split('=').last.strip
            sdbm["eaten_#{accessor}"] = session_id
            sdbm.delete(accessor)
          else
            # asked for the same cookie a second time
            # can probably only be due to session hijacking
            # so delete all sessions associated with that accessor
            session_id = dbm["eaten_#{accessor}"]
            sdbm.delete(session_id) if session_id
          end
          cookie
        end
      end

      def get_user(session_id:)
        json = SDBM.open(@cookie_sdbm_path, 0640) do |sdbm|
          sdbm[session_id]
        end
        if json
          user_info = Oj.load(json, mode: :strict)
          user_info[0].constantize.load(key: user_info[1]) if user_info
        end
      end

      def remove(session_id:)
        SDBM.open(@cookie_sdbm_path, 0640, DBM::WRITER) do |sdbm|
          sdbm.delete(session_id)
        end
      end
    end
  end
end