class TestHandler < LucidHandler::Base
  on_request do |client, current_user, request|
    { received_request: request }
  end
end