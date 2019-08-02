module LucidLocalOperation
  class Base
    include LucidLocalOperation::Mixin

    if RUBY_ENGINE != 'opal'
      def self.inherited(base)
        Isomorfeus.add_valid_operation_class(base)
      end
    end
  end
end