module LucidData
  module File
    module Mixin
      def self.included(base)
        base.include(Isomorfeus::Data::AttributeSupport)
        base.extend(LucidData::File::ClassApi)
        base.include(LucidData::File::InstanceApi)

        unless base == LucidData::File::Base
          if RUBY_ENGINE != 'opal'
            Isomorfeus.add_valid_file_class(base)

            uploader = base.const_set("Uploader", Class.new(::Shrine))

            uploader.plugin :add_metadata
            uploader.plugin :data_uri
            uploader.plugin :default_storage
            uploader.plugin :derivatives

            base.default_cache :cache
            base.default_store :store
          end

          base.attribute :meta
        end
      end
    end
  end
end
