module LucidData
  module EdgeCollection
    class Base
      include LucidData::EdgeCollection::Mixin

      if RUBY_ENGINE != 'opal'
        def self.inherited(base)
          Isomorfeus.add_valid_data_class(base)
        end
      end
    end
  end
end
