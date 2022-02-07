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

      def destroy_doc(key)
        id = get_doc_id(key)
        @index.delete(id) if id
        true
      end

      def load_doc(key)
        id = get_doc_id(key)
        @index.doc(id)&.load&.to_h if id
      end

      def save_doc(key, document)
        id = get_doc_id(key)
        if id
          @index.update(id, document)
          true
        end
      end

      def search_each(query, options, &block)
        @index.search_each(query, options, &block)
      end

      private

      def get_doc_id(key)
        # special characters must be escaped, characters taken from the ferret query parser documentation
        escaped_key = key.gsub(/([\\\&\:\(\)\[\]\{\}\!\"\~\^\|\<\>\=\*\?\+\-\s])/, '\\\\\1')
        top_docs = @index.search("key:\"#{escaped_key}\"", limit: 1)
        id = top_docs.hits[0].doc if top_docs.total_hits == 1
      end

      def index_path
        File.expand_path(File.join(Isomorfeus.data_documents_path, @doc_class_name_u))
      end

      def open_index
        FileUtils.mkdir_p(Isomorfeus.data_documents_path) unless Dir.exist?(Isomorfeus.data_documents_path)
        field_infos = Isomorfeus::Ferret::Index::FieldInfos.new(store: :yes, index: :yes, term_vector: :with_positions_offsets)
        @index = Isomorfeus::Ferret::Index::Index.new(path: index_path, key: :key, auto_flush: true, lock_retry_time: 5, field_infos: field_infos)
        @index.field_infos.add_field(:key, store: :yes, index: :yes, term_vector: :no) unless @index.field_infos[:key]
        @doc_class.field_options.each do |field, options|
          @index.field_infos.add_field(field, options) unless @index.field_infos[field]
        end
      end
    end
  end
end
