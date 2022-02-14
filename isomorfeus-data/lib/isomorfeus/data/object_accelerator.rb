module Isomorfeus
  module Data
    class ObjectAccelerator
      def self.finalize(ham_acc)
        proc { ham_acc.close_index }
      end

      attr_accessor :index

      def initialize(object_class_name, &block)
        if block_given?
          res = block.call(self)
          @index = res unless @index
        else
          @index_path = File.expand_path(File.join(Isomorfeus.data_object_idxs_path, object_class_name.underscore))
          open_index
        end
        ObjectSpace.define_finalizer(self, self.class.finalize(self))
      end

      def destroy_index
        close_index
        FileUtils.rm_rf(@index_path)
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
        top_docs = @index.search("sid_s_attr:\"#{escaped_key}\"", limit: 1)
        id = top_docs.hits[0].doc if top_docs.total_hits == 1
      end

      def open_index
        FileUtils.mkdir_p(@index_path) unless Dir.exist?(@index_path)
        @index = Isomorfeus::Ferret::Index::Index.new(path: @index_path, key: :sid_s_attr, auto_flush: true, lock_retry_time: 5)
        @index.field_infos.add_field(:attribute, store: :no, term_vector: :no) unless @index.field_infos[:attribute]
        @index.field_infos.add_field(:class_name, store: :no, term_vector: :no) unless @index.field_infos[:class_name]
        @index.field_infos.add_field(:value, store: :no) unless @index.field_infos[:value]
        @index.field_infos.add_field(:sid_s_attr, store: :yes, term_vector: :no) unless @index.field_infos[:sid_s_attr]
      end
    end
  end
end
