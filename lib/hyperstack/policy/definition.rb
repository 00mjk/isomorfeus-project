module Isomorfeus
  module Policy
    module Definition
      def self.included(base)
        base.include(Isomorfeus::Policy::InstanceMethods)
        base.extend(Isomorfeus::Policy::ClassMethods)
      end
    end
  end
end