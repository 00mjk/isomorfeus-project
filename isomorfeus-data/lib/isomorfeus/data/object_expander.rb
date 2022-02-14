module Isomorfeus
  module Data
    class ObjectExpander
      class << self
        def finalize(ins)
          proc { ins.environment.close rescue nil }
        end
      end

      attr_accessor :environment

      def initialize(object_class_name, &block)
        if block_given?
          res = block.call(self)
          self.environment = res unless self.environment
        else
          @env_path = File.expand_path(File.join(Isomorfeus.data_object_envs_path, object_class_name.underscore))
          open_environment
        end
        @db = self.environment.database('objects', create: true)
        @index_db = self.environment.database('index', create: true, dupsort: true)
        @use_class_cache = !Isomorfeus.development?
        ObjectSpace.define_finalizer(self, self.class.finalize(self))
      end

      def create_object(sid_s, obj)
        Isomorfeus::Hamster::Marshal.dump(@db, sid_s, obj, class_cache: @use_class_cache)
      end

      def destroy_object(sid_s)
        @db.delete(sid_s) rescue nil
        true
      end

      def load_object(sid_s)
        Isomorfeus::Hamster::Marshal.load(@db, sid_s, class_cache: @use_class_cache)
      end

      def save_object(sid_s, obj)
        Isomorfeus::Hamster::Marshal.dump(@db, sid_s, obj, class_cache: @use_class_cache)
      end

      def index_delete(key, val)
        @index_db.delete(key, val) rescue nil
      end

      def index_get(key)
        @index_db.get(key)
      end

      def index_put(key, val)
        @index_db.put(key, val)
      end

      def each(&block)
        @db.each do |key, obj|
          block.call(Isomorfeus::Hamster::Marshal.unserialize(obj, class_cache: @use_class_cache))
        end
      end

      def search(val_key, &block)
        @index_db.each_value(val_key, &block)
      end

      private

      def open_environment
        FileUtils.mkdir_p(@env_path) unless Dir.exist?(@env_path)
        self.environment = Isomorfeus::Hamster.new(@env_path, mapsize: Isomorfeus.hamster_mapsize)
      end
    end
  end
end
