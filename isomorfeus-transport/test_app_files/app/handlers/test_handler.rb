class TestHandler < LucidHandler::Base
  on_request do |response_agent|
    response_agent.agent_result = { received_request: response_agent.request }
  end
end
