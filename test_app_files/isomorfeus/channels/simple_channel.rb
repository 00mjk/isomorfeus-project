class SimpleChannel < LucidChannel::Base
  on_message do |channel, message|
    if channel && message
      $channel = channel
      $message = message
    else
      $message = channel
    end
  end
end
