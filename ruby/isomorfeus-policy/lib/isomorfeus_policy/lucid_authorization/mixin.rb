module LucidAuthorization
  module Mixin
    def authorized?(target_class, target_method = nil, *props)
      begin
        class_name = self.class.name
        class_name = class_name.split('>::').last if class_name.start_with?('#<')
        policy_class = Isomorfeus.cached_policy_class("#{class_name}Policy")
      rescue ::NameError
        policy_class = nil
      end
      return false unless policy_class
      policy_class.new(self).authorized?(target_class, target_method, *props)
    end

    def authorized!(target_class, target_method = nil, *props)
      class_name = self.class.name
      class_name = class_name.split('>::').last if class_name.start_with?('#<')
      policy_class = Isomorfeus.cached_policy_class("#{class_name}Policy")
      Isomorfeus.raise_error(error_class: LucidPolicy::Exception, message: "#{self}: policy class #{class_name}Policy not found!") unless policy_class
      policy_class.new(self).authorized!(target_class, target_method, *props)
    end
  end
end
