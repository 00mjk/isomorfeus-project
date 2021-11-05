module Isomorfeus
  module Data
    class HamsterAccelerator
      class << self
        def index
          @index
        end

        def index=(idx)
          @index = idx
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
            cls.index.close if cls.ref == 0
          end
        end
      end

      def initialize(&block)
        if block_given?
          res = block.call(self)
          self.class.index = res unless self.class.index
        else
          open_index
        end
        ObjectSpace.define_finalizer(self, self.class.finalize(self.class))
      end

      def destroy_index
        close_index
        FileUtils.rm_rf(Isomorfeus.data_object_idx_path)
      end

      def destroy_doc(id)
        self.class.index.delete(id)
        true
      end

      def load_doc(id)
        self.class.index.doc(id)&.load
      end

      def save_doc(id, document)
        self.class.index.update(id, document)
      end

      def search_each(query, options, &block)
        self.class.index.search_each(query, options, &block)
      end

      private

      def open_index
        return self.class.refa if self.class.index
        unless Dir.exist?(Isomorfeus.data_object_idx_path)
          FileUtils.mkdir_p(Isomorfeus.data_object_idx_path)
          fis = Isomorfeus::Ferret::Index::FieldInfos.new
          fis.add_field(:attribute, store: :no)
          fis.add_field(:class_name, store: :no)
          fis.add_field(:value, store: :no)
          fis.add_field(:sid_s_attr, store: :yes)
          fis.create_index(Isomorfeus.data_object_idx_path)
        end
        self.class.index = Isomorfeus::Ferret::Index::Index.new(path: Isomorfeus.data_object_idx_path, id_field: :sid_s_attr)
        self.class.refa
      end
    end
  end
end
