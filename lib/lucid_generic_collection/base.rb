module LucidGenericCollection
  class Base
    include LucidGenericCollection::Mixin

    if RUBY_ENGINE != 'opal'
      def self.inherited(base)
        Isomorfeus.add_valid_generic_collection_class(base)

        base.prop :pub_sub_client, default: nil
        base.prop :current_user, default: nil
      end
    end
  end
end
