module LucidGraph
  class Base
    include LucidGraph::Mixin

    if RUBY_ENGINE != 'opal'
      def self.inherited(base)
        Isomorfeus.add_valid_graph_class(base)

        base.prop :pub_sub_client, default: nil
        base.prop :current_user, default: nil
      end
    end
  end
end