module LucidData
  module File
    class Base
      include LucidData::File::Mixin

      def self.inherited(base)
        if RUBY_ENGINE != 'opal'
          Isomorfeus.add_valid_file_class(base)

          uploader = base.const_set("Uploader", Class.new(::Shrine))

          uploader.plugin :add_metadata
          uploader.plugin :data_uri

          base.default_cache :cache
          base.default_store :store
        end

        base.attribute :meta
      end
    end
  end
end
