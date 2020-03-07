module Isomorfeus
  module Transport
    module Middlewares
      def use_isomorfeus_middlewares
        puts "Isomorfeus is using the following middlewares:"
        Isomorfeus.middlewares.each do |isomorfeus_middleware|
          puts "#{isomorfeus_middleware}"
          use isomorfeus_middleware
        end
      end
    end
  end
end
