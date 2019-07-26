class TestHandler < LucidHandler::Base
  on_request do |client, session_id, current_user, request|
    { received_request: request }
  end
end