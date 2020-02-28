class SimpleChannel < LucidChannel::Base
  on_message do |message, error|
    $simple_message = message
  end
end
