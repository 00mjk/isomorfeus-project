module Isomorfeus
  # available settings
  class << self
    if RUBY_ENGINE == 'opal'
      # nothing
    else

      def email_sender_config
        @email_sender_config ||= { type: :smtp }
      end

      def email_sender_config=(new_config)
        Isomorfeus.raise_error "email_sender_config must at least include a :type!" unless new_config.key?(:type)
        @email_sender_config = new_config
      end

      def email_sender
        @email_sender ||= MailHandler.sender(Isomorfeus.email_sender_config[:type]) do |dispatcher|
          dispatcher.address  = Isomorfeus.email_sender_config[:address]  if Isomorfeus.email_sender_config.key?(:address)
          dispatcher.port     = Isomorfeus.email_sender_config[:port]     if Isomorfeus.email_sender_config.key?(:port)
          dispatcher.domain   = Isomorfeus.email_sender_config[:domain]   if Isomorfeus.email_sender_config.key?(:domain)
          dispatcher.username = Isomorfeus.email_sender_config[:username] if Isomorfeus.email_sender_config.key?(:username)
          dispatcher.password = Isomorfeus.email_sender_config[:password] if Isomorfeus.email_sender_config.key?(:password)
          dispatcher.use_ssl  = Isomorfeus.email_sender_config[:use_ssl]  if Isomorfeus.email_sender_config.key?(:use_ssl)
        end
      end
    end
  end
end
