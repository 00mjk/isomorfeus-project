module LucidData
  module ComposableGraph
    class Base
      include LucidData::ComposableGraph::Mixin

      if RUBY_ENGINE != 'opal'
        def self.inherited(base)
          Isomorfeus.add_valid_data_class(base)
          base.prop :pub_sub_client, default: nil
          base.prop :current_user, default: Anonymous.new
        end
      end
    end
  end
end
