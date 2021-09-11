module LucidPolicy
  class Base
    def self.inherited(base)
      base.include LucidPolicy::Mixin
      if RUBY_ENGINE != 'opal'
        Isomorfeus.add_valid_policy_class(base)
      end
    end
  end
end
