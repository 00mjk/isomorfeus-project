module LucidAuthorization
  module Mixin
    def record_authorization_reason
      @_isomorfeus_record_authorization_reason = true
    end

    def stop_to_record_authorization_reason
      @_isomorfeus_record_authorization_reason = false
      @_isomorfeus_authorization_reason = nil
    end

    def authorization_reason
      @_isomorfeus_authorization_reason
    end

    def authorized?(target_class, target_method = nil, props = nil)
      begin
        class_name = self.class.name
        class_name = class_name.split('>::').last if class_name.start_with?('#<')
        policy_class = Isomorfeus.cached_policy_class("#{class_name}Policy")
      rescue ::NameError
        policy_class = nil
      end
      return false unless policy_class
      policy_instance = policy_class.new(self, @_isomorfeus_record_authorization_reason)
      result = policy_instance.authorized?(target_class, target_method, props)
      @_isomorfeus_authorization_reason = policy_instance.reason
      result
    end

    def authorized!(target_class, target_method = nil, props = nil)
      class_name = self.class.name
      class_name = class_name.split('>::').last if class_name.start_with?('#<')
      policy_class = Isomorfeus.cached_policy_class("#{class_name}Policy")
      Isomorfeus.raise_error(error_class: LucidPolicy::Exception, message: "#{self}: policy class #{class_name}Policy not found!") unless policy_class
      policy_class.new(self, @_isomorfeus_record_authorization_reason).authorized!(target_class, target_method, props)
    end
  end
end
