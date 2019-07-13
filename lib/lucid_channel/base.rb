module LucidChannel
  class Base
    if RUBY_ENGINE != 'opal'
      def self.inherited(base)
        Isomorfeus.add_valid_channel_class(base)
      end
    end

    include LucidChannel::Mixin
  end
end