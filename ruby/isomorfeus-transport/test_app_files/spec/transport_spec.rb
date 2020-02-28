require 'spec_helper'

RSpec.describe 'isomorfeus-transport' do
  before :all do
    @doc = visit('/')
  end

  it 'is loaded' do
    result = @doc.evaluate_ruby do
      defined? Isomorfeus::Transport
    end
    expect(result).to eq 'constant'
  end

  it 'configuration is accessible on the client' do
    result = @doc.evaluate_ruby do
      Isomorfeus.api_websocket_path
    end
    expect(result).to eq '/isomorfeus/api/websocket'
  end

  it 'configuration is accessible on the server' do
    expect(Isomorfeus.api_websocket_path).to eq '/isomorfeus/api/websocket'
    expect(Isomorfeus.middlewares).to include(Isomorfeus::Transport::RackMiddleware)
  end

  it 'connected during client app boot' do
    CONNECTING  = 0
    OPEN        = 1
    CLOSING     = 2
    CLOSED      = 3
    socket_state = nil
    start = Time.now
    while socket_state != OPEN do
      socket_state = @doc.evaluate_ruby do
        Isomorfeus::Transport.socket.ready_state
      end
      if socket_state != OPEN
        break if Time.now - start > 60
        sleep 1
      end
    end
    expect(socket_state).to eq(1)
  end

  it 'registers a handler class as valid handler class name when inherited' do
    result = on_server do
      class TestChannelClassBlaWhateverSuperDuper < LucidHandler::Base
      end
      Isomorfeus.valid_handler_class_names
    end
    expect(result).to include('TestChannelClassBlaWhateverSuperDuper')
  end

  it 'registers a handler class as valid handler class name when included' do
    result = on_server do
      class WhateverClassAnyThingReallyAnythingBla
        include LucidHandler::Mixin
      end
      Isomorfeus.valid_handler_class_names
    end
    expect(result).to include('WhateverClassAnyThingReallyAnythingBla')
  end

  context 'handler' do
    it 'the sample handler is defined' do
      result = on_server do
        !!defined? TestHandler
      end
      expect(result).to be true
    end

    it 'the sample handler is a valid handler class' do
      result = on_server do
        Isomorfeus.valid_handler_class_name?('TestHandler')
      end
      expect(result).to be true
    end

    it 'the sample handler responds to process_request' do
      result = on_server do
        TestHandler.instance_methods.sort
      end
      expect(result).to include(:process_request)
    end

    it 'the sample handler processes a request from the client' do
      doc = visit('/')
      result = doc.await_ruby do
        Isomorfeus::Transport.promise_send_request('TestHandler' => {test: true}).then do |agent|
          { 'agent_response' => agent.response }
        end
      end
      expect(result['agent_response']).to eq({ "received_request" => { "test"=>true }})
    end
  end
end
