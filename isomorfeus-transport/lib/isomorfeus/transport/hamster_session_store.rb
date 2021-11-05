module Isomorfeus
  module Transport
    class HamsterSessionStore
      class << self
        def environment
          @environment
        end

        def environment=(env)
          @environment = env
        end

        def ref
          @ref ||= 0
        end

        def ref=(val)
          @ref = val
        end

        def refa
          self.ref += 1
        end

        def refs
          self.ref -= 1 if self.ref > 0
        end

        def finalize(cls)
          proc do
            cls.refs
            if cls.ref == 0
              cls.environment.close rescue nil
            end
          end
        end
      end

      def initialize(cookie_hamster_path)
        @cookie_hamster_path = cookie_hamster_path
        open_environment
        @db = self.class.environment.database('cookies', create: true)
        ObjectSpace.define_finalizer(self, self.class.finalize(self.class))
      end

      def add(session_id:, cookie:, user:, accessor:)
        @db.env.transaction do
          @db.put(session_id, Oj.dump([user.class.to_s, user.key], mode: :strict))
          @db.put(accessor, cookie)
        end
      end

      def take_cookie(accessor:)
        @db.env.transaction do
          cookie = @db.get(accessor)
          if cookie
            session_info = cookie.split('; ').first
            session_id = session_info.split('=').last.strip
            @db.put("eaten_#{accessor}", session_id)
            @db.delete(accessor)
          else
            # asked for the same cookie a second time
            # can probably only be due to session hijacking
            # so delete all sessions associated with that accessor
            session_id = @db.get("eaten_#{accessor}")
            @db.delete(session_id) if session_id
          end
          cookie
        end
      end

      def get_user(session_id:)
        json = @db.get(session_id)
        if json
          user_info = Oj.load(json, mode: :strict)
          user_info[0].constantize.load(key: user_info[1]) if user_info
        end
      end

      def remove(session_id:)
        @db.env.transaction do
          @db.delete(session_id)
        end
      end

      private

      def open_environment
        return self.class.refa if self.class.environment
        FileUtils.mkdir_p(@cookie_hamster_path) unless Dir.exist?(@cookie_hamster_path)
        self.class.environment = Isomorfeus::Hamster.new(@cookie_hamster_path)
        self.class.refa
      end
    end
  end
end