module LucidPolicy
  class Base
    include LucidPolicy::Mixin

    if RUBY_ENGINE != 'opal'
      def self.inherited(base)
        Isomorfeus.add_valid_policy_class(base)
      end
    end
  end
end
