class CustomChannel < LucidChannel::Base
  channel :one
  channel :two

  on_message do |message, error|
    $custom_message = message
  end

  on_message :one do |message, error|
    $custom_message_one = message
  end

  on_message :two do |message, error|
    $custom_message_two = message
  end

  server_on_message :two do |message|
    if RUBY_ENGINE != 'opal'
      SimpleChannel.send_message('hello from server')
      true
    end
  end
end
