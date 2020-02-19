module Isomorfeus
  module Transport
    module Middlewares
      def use_isomorfeus_middlewares
        STDOUT.puts "Isomorfeus is using the following middlewares:"
        Isomorfeus.middlewares.each do |isomorfeus_middleware|
          STDOUT.puts "#{isomorfeus_middleware}"
          use isomorfeus_middleware
        end
      end
    end
  end
end
