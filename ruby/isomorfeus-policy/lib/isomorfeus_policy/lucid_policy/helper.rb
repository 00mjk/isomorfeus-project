module LucidPolicy
  class Helper < BasicObject
    attr_reader :result

    def initialize
      @result = :deny
    end

    def allow
      @result = :allow
      nil
    end

    def deny
      nil
    end
  end
end
