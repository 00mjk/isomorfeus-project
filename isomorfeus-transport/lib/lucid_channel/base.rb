module LucidChannel
  class Base
    def self.inherited(base)
      base.include LucidChannel::Mixin
      Isomorfeus.add_valid_channel_class(base)
    end
  end
end
