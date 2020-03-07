module Isomorfeus
  module Transport
    class DbmSessionStore
      def initialize(cookie_dbm_path)
        @cookie_dbm_path = cookie_dbm_path
        DBM.open(@cookie_dbm_path, 0640, DBM::NEWDB).close
      end

      def add(session_id:, cookie:, user:, accessor:)
        DBM.open(@cookie_dbm_path, 0640, DBM::WRITER) do |dbm|
          dbm[session_id] = Oj.dump([user.class.to_s, user.key], mode: :strict)
          dbm[accessor] = cookie
        end
      end

      def take_cookie(accessor:)
        DBM.open(@cookie_dbm_path, 0640, DBM::WRITER) do |dbm|
          cookie = dbm[accessor]
          if cookie
            session_info = cookie.split('; ').first
            session_id = session_info.split('=').last.strip
            dbm["eaten_#{accessor}"] = session_id
            dbm.delete(accessor)
          else
            # asked for the same cookie a second time
            # can probably only be due to session hijacking
            # so delete all sessions associated with that accessor
            session_id = dbm["eaten_#{accessor}"]
            dbm.delete(session_id) if session_id
          end
          cookie
        end
      end

      def get_user(session_id:)
        json = DBM.open(@cookie_dbm_path, 0640, DBM::READER) do |dbm|
          dbm[session_id]
        end
        if json
          user_info = Oj.load(json, mode: :strict)
          user_info[0].constantize.load(key: user_info[1]) if user_info
        end
      end

      def remove(session_id:)
        DBM.open(@cookie_dbm_path, 0640, DBM::WRITER) do |dbm|
          dbm.delete(session_id)
        end
      end
    end
  end
end
