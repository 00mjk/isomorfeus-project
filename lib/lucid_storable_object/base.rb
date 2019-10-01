module LucidStorableObject
  class Base
    include LucidStorableObject::Mixin

    if RUBY_ENGINE != 'opal'
      def self.inherited(base)
        Isomorfeus.add_valid_storable_object_class(base)

        base.prop :pub_sub_client, default: nil
        base.prop :current_user, default: nil
      end
    end
  end
end
