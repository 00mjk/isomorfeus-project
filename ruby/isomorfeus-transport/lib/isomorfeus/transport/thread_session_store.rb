module Isomorfeus
  module Transport
    class ThreadSessionStore

      def add(cookie:, user:)
        store[cookie] = user
      end

      def remove(cookie:)
        store.delete(cookie)
      end

      private

      def store
        Thread.current[:isomorfeus_session_store] ||= {}
      end
    end
  end
end
