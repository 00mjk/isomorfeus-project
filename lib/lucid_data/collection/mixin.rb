module LucidData
  module Collection
    module Mixin
      # TODO nodes -> documents
      # TODO inline store path
      def self.included(base)
        base.include(Enumerable)
        base.extend(LucidPropDeclaration::Mixin)
        base.extend(Isomorfeus::Data::GenericClassApi)
        base.include(Isomorfeus::Data::GenericInstanceApi)
        base.include(LucidData::Collection::Finders)

        base.instance_exec do
          def _handler_type
            'collection'
          end

          def documents(validate_hash = {})
            @document_conditions = validate_hash
          end
          alias document documents
          alias edges documents
          alias edge document
          alias nodes documents
          alias node document

          def document_conditions
            @document_conditions
          end

          def valid_document?(document)
            return true unless @document_conditions
            Isomorfeus::Data::ElementValidator.new(self.name, document, @document_conditions).validate!
          rescue
            false
          end
          alias valid_edge? valid_document?
          alias valid_node? valid_document?
        end

        def _validate_document(doc)
          Isomorfeus::Data::ElementValidator.new(@class_name, doc, @doc_con).validate!
        end

        def _validate_documents(docs)
          docs.each { |doc| Isomorfeus::Data::ElementValidator.new(@class_name, doc, @doc_con).validate! }
        end

        def _collection_to_sids(collection)
          collection.map do |document|
            document.respond_to?(:to_sid) ? document.to_sid : document
          end
        end

        def _document_sid_from_arg(arg)
          if arg.respond_to?(:to_sid)
            sid = arg.to_sid
            document = arg
          else
            sid = arg
            document = LucidGenericDocument.instance_from_sid(sid)
          end
          [document, sid]
        end

        def to_transport
          { @class_name => { @key => nodes_as_sids }}
        end

        def included_items_to_transport
          documents_hash = {}
          documents.each do |node|
            documents_hash.deep_merge!(node.to_transport)
          end
          documents_hash
        end

        if RUBY_ENGINE == 'opal'
          def initialize(key:, revision: nil, documents: nil, elements: nil, edges: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @store_path = [:data_state, @class_name, @key]
            @_changed_collection = nil
            @_revision_store_path = [:data_state, :revision, @class_name, @key]
            @_revision = revision ? revision : Redux.fetch_by_path(*@_revision_store_path)
            @doc_con = self.class.document_conditions
            @_validate_documents = @el_con ? true : false
            documents = documents || elements ||edges
            documents = [] unless documents
            if @_validate_documents
              documents.each { |e| _validate_document(e) }
            end
            raw_documents = _collection_to_sids(documents)
            raw_array = Redux.fetch_by_path(*@_store_path)
            if `raw_collection === null` || raw_array != raw_documents
              @_changed_collection = raw_documents
            end
          end

          def _get_collection
            return @_changed_collection if @_changed_collection
            collection = Redux.fetch_by_path(*@_store_path)
            return collection if collection
            []
          end

          def changed?
            !!@_changed_collection
          end

          def revision
            @_revision
          end

          def documents
            documents_as_sids.map { |node_sid| LucidGenericDocument::Base.document_from_sid(node_sid) }
          end
          alias edges documents
          alias nodes documents

          def documents_as_sids
            _get_collection
          end

          def each(&block)
            _get_collection.each(&block)
          end

          def method_missing(method_name, *args, &block)
            if method_name.JS.startsWith('find_document_by_') || method_name.JS.startsWith('find_edge_by_') || method_name.JS.startsWith('find_node_by_')
              attribute = method_name[13..-1] # remove 'find_node_by_'
              value = args[0]
              attribute_hash = { attribute => value }
              attribute_hash.merge!(args[1]) if args[1]
              find_node(attribute_hash)
            else
              collection = _get_collection
              collection.send(method_name, *args, &block)
            end
          end

          def <<(document)
            document, sid = _document_sid_from_arg(document)
            _validate_document(document) if @_validate_documents
            raw_collection = _get_collection
            @_changed_collection = raw_collection << sid
            self
          end

          def [](idx)
            _get_collection[idx]
          end

          def []=(idx, document)
            document, sid = _document_sid_from_arg(document)
            _validate_document(document) if @_validate_documents
            raw_collection = _get_collection
            raw_collection[idx] = sid
            @_changed_collection = raw_collection
            document
          end

          def clear
            @_changed_collection = []
            self
          end

          def collect!(&block)
            collection = documents
            collection.collect!(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def compact!
            raw_collection = _get_collection
            result = raw_collection.compact!
            return nil if result.nil?
            @_changed_collection = raw_collection
            self
          end

          def concat(*args)
            sids = args.map do |doc|
              document, sid = _document_sid_from_arg(doc)
              _validate_document(document)
              sid
            end
            raw_collection = _get_collection
            raw_collection.concat(*sids)
            @_changed_collection = raw_collection
            self
          end

          def delete(document, &block)
            document, sid = _document_sid_from_arg(document)
            raw_collection = _get_collection
            result = raw_collection.delete(sid, &block)
            return nil unless result
            @_changed_collection = raw_collection
            document
          end

          def delete_at(idx)
            raw_collection = _get_collection
            result = raw_collection.delete_at(idx)
            return nil if result.nil?
            @_changed_collection = raw_collection
            LucidGenericDocument.instance_from_sid(result)
          end

          def delete_if(&block)
            collection = documents
            collection.delete_if(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def filter!(&block)
            collection = documents
            result = collection.filter!(&block)
            return nil if result.nil?
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def insert(index, *docs)
            sids = docs.map do |doc|
              document, sid = _document_sid_from_arg(doc)
              _validate_document(document)
              sid
            end
            raw_collection = _get_collection
            raw_collection.insert(index, sids)
            @_changed_collection = raw_collection
            self
          end

          def keep_if(&block)
            collection = documents
            collection.keep_if(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def map!(&block)
            collection = documents
            collection.map!(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def pop(n = nil)
            raw_collection = _get_collection
            result = raw_collection.pop(n)
            @_changed_collection = raw_collection
            LucidGenericDocument.instance_from_sid(result)
          end

          def push(*documents)
            sids = docs.map do |doc|
              document, sid = _document_sid_from_arg(doc)
              _validate_document(document)
              sid
            end
            raw_collection = _get_collection
            raw_collection.push(*sids)
            @_changed_collection = raw_collection
            self
          end
          alias append push

          def reject!(&block)
            collection = documents
            result = collection.reject!(&block)
            return nil if result.nil?
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def reverse!
            raw_collection = _get_collection
            raw_collection.reverse!
            @_changed_collection = raw_collection
            self
          end

          def rotate!(count = 1)
            raw_collection = _get_collection
            raw_collection.rotate!(count)
            @_changed_collection = raw_collection
            self
          end

          def select!(&block)
            collection = documents
            result = collection.select!(&block)
            return nil if result.nil?
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def shift(n = nil)
            raw_collection = _get_collection
            result = raw_collection.shift(n)
            @_changed_collection = raw_collection
            LucidGenericDocument.instance_from_sid(result)
          end

          def shuffle!(*args)
            raw_collection = _get_collection
            raw_collection.shuffle!(*args)
            @_changed_collection = raw_collection
            self
          end

          def slice!(*args)
            raw_collection = _get_collection
            result = raw_collection.slice!(*args)
            @_changed_collection = raw_collection
            return nil if result.nil?
            # TODO
            result
          end

          def sort!(&block)
            collection = documents
            collection.sort!(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def sort_by!(&block)
            collection = documents
            collection.sort_by!(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def uniq!(&block)
            collection = documents
            collection.uniq!(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def unshift(*docs)
            sids = docs.map do |doc|
              document, sid = _document_sid_from_arg(doc)
              _validate_document(document)
              sid
            end
            raw_collection = _get_collection
            raw_collection.unshift(*sids)
            @_changed_collection = raw_collection
            self
          end
          alias prepend unshift
        else # RUBY_ENGINE
          unless base == LucidGenericCollection::Base
            Isomorfeus.add_valid_generic_collection_class(base) unless base == LucidGenericCollection::Base
            base.prop :pub_sub_client, default: nil
            base.prop :current_user, default: Anonymous.new
          end

          def initialize(key:, revision: nil, documents: nil, elements: nil, edges: nil)
            @key = key.to_s
            @_revision = revision
            @_changed = false
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @doc_con = self.class.document_conditions
            @_validate_documents = @doc_con ? true : false
            documents = documents || elements ||edges
            documents = [] unless documents
            if @_validate_documents
              documents.each { |e| _validate_document(e) }
            end
            @_raw_collection = _collection_to_sids(documents)
          end

          def changed?
            @_changed
          end

          def revision
            @_revision
          end

          def documents
            @_raw_collection.map do |sid|
              LucidGenericDocument.instance_from_sid(sid)
            end
          end

          def documents_as_sids
            @_raw_collection
          end

          def each(&block)
            documents.each(&block)
          end

          def method_missing(method_name, *args, &block)
            if method_name.start_with?('find_document_by_') || method_name.start_with?('find_edge_by_') || method_name.start_with?('find_node_by_')
              attribute = method_name[13..-1] # remove 'find_node_by_'
              value = args[0]
              attribute_hash = { attribute => value }
              attribute_hash.merge!(args[1]) if args[1]
              find_node(attribute_hash)
            else
              documents.send(method_name, *args, &block)
            end
          end

          def <<(document)
            document, sid = _document_sid_from_arg(document)
            _validate_document(document) if @_validate_documents
            @_changed = true
            @_raw_collection << sid
            document
          end

          def []=(idx, document)
            document.respond_to?(:to_sid) ? document.to_sid : document
            _validate_document(document) if @_validate_documents
            @_changed = true
            @_raw_collection[idx] = document
          end

          def clear
            @_raw_collection = []
            self
          end

          def collect!(&block)
            @_changed = true
            result = documents.collect!(&block)
            @_raw_collection = _collection_to_sids(result)
            self
          end

          def compact!
            result = @_raw_collection.compact!
            return nil if result.nil?
            @_changed = true
            self
          end

          def concat(*docs)
            sids = docs.map do |doc|
              document, sid = _document_sid_from_arg(doc)
              _validate_document(document)
              sid
            end
            @_changed = true
            @_raw_collection.concat(*sids)
            self
          end

          def delete(document, &block)
            result = @_raw_collection.delete(document, &block)
            @_changed = true
            result
          end

          def delete_at(idx)
            result = @_raw_collection.delete_at(idx)
            return nil if result.nil?
            @_changed = true
            result
          end

          def delete_if(&block)
            documents.delete_if(&block)
            @_raw_collection = _collection_to_sids(result)
            @_changed = true
            self
          end

          def filter!(&block)
            result = documents.filter!(&block)
            return nil if result.nil?
            @_raw_collection = _collection_to_sids(result)
            @_changed = true
            self
          end

          def insert(*args)
            sids = docs.map do |doc|
              document, sid = _document_sid_from_arg(doc)
              _validate_document(document)
              sid
            end
            @_raw_collection.insert(*sids)
            @_changed = true
            self
          end

          def keep_if(&block)
            result = documents.keep_if(&block)
            @_raw_collection = _collection_to_sids(result)
            @_changed = true
            self
          end

          def map!(&block)
            result = documents.map!(&block)
            @_raw_collection = _collection_to_sids(result)
            @_changed = true
            self
          end

          def pop(n = nil)
            result = @_raw_collection.pop(n)
            @_changed = true
            if n > 0
              result.map do |sid|
                LucidGenericDocument.instance_from_sid(sid)
              end
            else
              LucidGenericDocument.instance_from_sid(result)
            end
          end

          def push(*documents)
            sids = docs.map do |doc|
              document, sid = _document_sid_from_arg(doc)
              _validate_document(document)
              sid
            end
            @_raw_collection.push(*sids)
            @_changed = true
            self
          end
          alias append push

          def reject!(&block)
            result = documents.reject!(&block)
            return nil if result.nil?
            @_raw_collection = _collection_to_sids(result)
            @_changed = true
            self
          end

          def reverse!
            @_raw_collection.reverse!
            @_changed = true
            self
          end

          def rotate!(count = 1)
            @_raw_collection.rotate!(count)
            @_changed = true
            self
          end

          def select!(&block)
            result = documents.select!(&block)
            return nil if result.nil?
            @_raw_collection = _collection_to_sids(result)
            @_changed = true
            self
          end

          def shift(n = nil)
            result = @_raw_collection.shift(n)
            @_changed = true
            LucidGenericDocument.instance_from_sid(result)
          end

          def shuffle!(*args)
            @_raw_collection.shuffle!(*args)
            @_changed = true
            self
          end

          def slice!(*args)
            result = @_raw_collection.slice!(*args)
            @_changed = true
            # TODO
            result
          end

          def sort!(&block)
            docs = documents.sort!(&block)
            @_raw_collection = _collection_to_sids(docs)
            @_changed = true
            self
          end

          def sort_by!(&block)
            docs = documents.sort_by!(&block)
            @_raw_collection = _collection_to_sids(docs)
            @_changed = true
            self
          end

          def uniq!(&block)
            docs = documents.uniq!(&block)
            @_raw_collection = _collection_to_sids(docs)
            @_changed = true
            self
          end

          def unshift(*args)
            sids = docs.map do |doc|
              document, sid = _document_sid_from_arg(doc)
              _validate_document(document)
              sid
            end
            @_raw_collection.unshift(*sids)
            @_changed = true
            self
          end
          alias prepend unshift
        end  # RUBY_ENGINE
      end
    end
  end
end
