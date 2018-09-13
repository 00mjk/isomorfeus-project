module Isomorfeus
  module Transport
    class ClientDrivers
      # @private
      def self.init
        return if @initialized
        if Isomorfeus.options.has_key?(:client_transport_driver_class_name)
          Isomorfeus.define_singleton_method(:client_transport_driver) do
            @client_transport_driver
          end
          Isomorfeus.define_singleton_method(:client_transport_driver=) do |driver|
            @client_transport_driver = driver
          end
          Isomorfeus.client_transport_driver = Isomorfeus.client_transport_driver_class_name.constantize
        end
        @initialized = true
      end
    end
  end
end
