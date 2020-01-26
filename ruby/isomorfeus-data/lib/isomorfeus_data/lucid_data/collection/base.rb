module LucidData
  module Collection
    class Base
      include LucidData::Collection::Mixin

      if RUBY_ENGINE != 'opal'
        def self.inherited(base)
          Isomorfeus.add_valid_data_class(base)
        end
      end
    end
  end
end
