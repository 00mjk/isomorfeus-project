module LucidChannel
  class Base
    def self.inherited(base)
      Isomorfeus.add_valid_channel_class(base)
    end

    include LucidChannel::Mixin
  end
end
