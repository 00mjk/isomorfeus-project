module Isomorfeus
  module Data
    class FerretAccelerator
      def self.finalize(fer_acc)
        proc { fer_acc.close_index }
      end

      attr_reader :doc_class, :doc_class_name, :doc_class_name_u
      attr_accessor :index

      def initialize(doc_class, &block)
        @doc_class = doc_class
        @doc_class_name = doc_class.name
        @doc_class_name_u = @doc_class_name.underscore
        if block_given?
          res = block.call(self)
          @index = res unless @index
        else
          open_index
        end
        ObjectSpace.define_finalizer(self, self.class.finalize(self))
      end

      def destroy_index
        close_index
        FileUtils.rm_rf(index_path(doc_class_name))
      end

      def close_index
        @index.close
      end

      def create_doc(document)
        @index.add_document(document)
      end

      def destroy_doc(id)
        @index.delete(id)
        true
      end

      def load_doc(id)
        @index.doc(id)
      end

      def save_doc(id, document)
        document[:id] = id unless document.key?(:id)
        @index.update(id, document)
      end

      def search_each(query, options, &block)
        @index.search_each(query, optons, &block)
      end

      private

      def index_path
        File.expand_path(File.join(Isomorfeus.data_documents_path, @doc_class_name_u))
      end

      def open_index
        FileUtils.mkdir_p(Isomorfeus.data_documents_path) unless Dir.exist?(Isomorfeus.data_documents_path)
        @index = Isomorfeus::Ferret::Index::Index.new(path: index_path)
      end
    end
  end
end
