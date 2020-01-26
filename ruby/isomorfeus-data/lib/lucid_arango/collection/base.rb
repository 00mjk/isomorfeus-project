module LucidArango
  module DocumentCollection
    class Base
      include LucidArango::DocumentCollection::Mixin

      if RUBY_ENGINE != 'opal'
        def self.inherited(base)
          Isomorfeus.add_valid_data_class(base)
        end
      end
    end
  end
end
