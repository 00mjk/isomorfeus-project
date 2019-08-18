module LucidQuickOp
  class Base
    include LucidQuickOp::Mixin

    if RUBY_ENGINE != 'opal'
      def self.inherited(base)
        Isomorfeus.add_valid_operation_class(base)

        base.prop :pub_sub_client, default: nil
        base.prop :current_user, default: nil
      end
    end
  end
end