module LucidArango
  module DocumentCollection
    module Mixin
      def self.included(base)
        if RUBY_ENGINE != 'opal'
          unless base == LucidArango::DocumentCollection::Base
            Isomorfeus.add_valid_data_class(base)
            base.prop :pub_sub_client, default: nil
            base.prop :current_user, default: Anonymous.new
          end
        end

        base.include(Enumerable)
        base.extend(LucidPropDeclaration::Mixin)

        # TODO implement, depends on arango-driver
      end
    end
  end
end
