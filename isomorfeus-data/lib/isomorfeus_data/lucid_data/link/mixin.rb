module LucidData
  module Link
    module Mixin
      def self.included(base)
        base.include(LucidData::Edge::Mixin)
      end
    end
  end
end
