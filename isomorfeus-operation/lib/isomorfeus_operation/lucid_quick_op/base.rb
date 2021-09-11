module LucidQuickOp
  class Base
    def self.inherited(base)
      base.include LucidQuickOp::Mixin
      if RUBY_ENGINE != 'opal'
        Isomorfeus.add_valid_operation_class(base)
      end
    end
  end
end
