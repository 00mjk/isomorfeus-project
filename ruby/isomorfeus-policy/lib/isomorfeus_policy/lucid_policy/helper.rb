module LucidPolicy
  class Helper < BasicObject
    attr_reader :result

    def initialize
      @result= nil
    end

    def allow
      @result = :allow if @result.nil?
      nil
    end

    def deny
      @result = :deny if @result.nil?
      nil
    end
  end
end
