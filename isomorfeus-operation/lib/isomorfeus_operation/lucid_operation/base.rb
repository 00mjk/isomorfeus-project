module LucidOperation
  class Base
    def self.inherited(base)
      base.include LucidOperation::Mixin
      if RUBY_ENGINE != 'opal'
        Isomorfeus.add_valid_operation_class(base)
      end
    end
  end
end
