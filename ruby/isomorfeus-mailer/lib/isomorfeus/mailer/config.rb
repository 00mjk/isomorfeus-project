module Isomorfeus
  # available settings
  class << self
    if RUBY_ENGINE != 'opal'
      def email_sender_config
        @email_sender_config ||= { type: :smtp }
      end

      def email_sender_config=(new_config)
        Isomorfeus.raise_error "email_sender_config must at least include a :type!" unless new_config.key?(:type)
        @email_sender_config = new_config
      end

      def email_sender
        @email_sender ||= MailHandler.sender(Isomorfeus.email_sender_config[:type]) do |dispatcher|
          Isomorfeus.email_sender_config.each do |key, value|
            dispatcher.__send__("#{key}=".to_sym, value) unless key == :type
          end
        end
      end
    end
  end
end
