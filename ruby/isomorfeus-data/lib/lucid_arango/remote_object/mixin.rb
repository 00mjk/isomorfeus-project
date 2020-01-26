module LucidRemoteObject
  module Mixin
    # TODO on revision conflict
    def self.included(base)
      if RUBY_ENGINE != 'opal'
        unless base == LucidRemoteObject::Base
          Isomorfeus.add_valid_data_class(base)
        end
      end

      base.include(Enumerable)
      base.extend(LucidPropDeclaration::Mixin)
      base.extend(Isomorfeus::Data::GenericClassApi)
      base.include(Isomorfeus::Data::GenericInstanceApi)
    end
  end
end
