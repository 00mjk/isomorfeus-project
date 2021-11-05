module LucidDocument
  class Base
    def self.inherited(base)
      base.include(LucidDocument::Mixin)
      if RUBY_ENGINE != 'opal'
        Isomorfeus.add_valid_data_class(base)
      end
    end
  end
end
