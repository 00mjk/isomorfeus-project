module Isomorfeus
  module Data
    class HamsterStorageExpander
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

      def initialize(&block)
        if block_given?
          res = block.call(self)
          self.class.environment = res unless self.class.environment
        else
          open_environment
        end
        @db = self.class.environment.database('objects', create: true)
        @index_db = self.class.environment.database('index', create: true, dupsort: true)
        ObjectSpace.define_finalizer(self, self.class.finalize(self.class))
      end

      def create_object(sid_s, obj)
        Isomorfeus::Hamster::Marshal.dump(@db, sid_s, obj)
      end

      def destroy_object(sid_s)
        @db.delete(sid_s)
        true
      end

      def load_object(sid_s)
        Isomorfeus::Hamster::Marshal.load(@db, sid_s)
      end

      def save_object(sid_s, obj)
        Isomorfeus::Hamster::Marshal.dump(@db, sid_s, obj)
      end

      def index_delete(key, val)
        @index_db.delete(key, val)
      end

      def index_get(key)
        @index_db.get(key)
      end

      def index_put(key, val)
        @index_db.put(key, val)
      end

      def search(val_key, &block)
        @index_db.each_value(val_key, &block)
      end

      private

      def open_environment
        return self.class.refa if self.class.environment
        FileUtils.mkdir_p(Isomorfeus.data_object_env_path) unless Dir.exist?(Isomorfeus.data_object_env_path)
        self.class.environment = Isomorfeus::Hamster.new(Isomorfeus.data_object_env_path)
        self.class.refa
      end

      def ats_key(oc, ky)
        "#{oc}|#{ky}|attributes"
      end

      def at_key(oc, ky, at)
        "#{oc}|#{ky}|:|#{at}"
      end
    end
  end
end