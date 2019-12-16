module Isomorfeus
  module Policy
    class AnonymousPolicy < LucidPolicy::Base
      policy_for Anonymous
      deny all
    end
  end
end
