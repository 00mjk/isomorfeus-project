module Isomorfeus
  module Transport
    module Middlewares
      def use_isomorfeus_middlewares
        Isomorfeus.middlewares.each do |isomorfeus_middleware|
          use isomorfeus_middleware
        end
      end
    end
  end
end
