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
      Isomorfeus.api_path
    end
    expect(result).to eq '/isomorfeus/api/endpoint'

    result = @doc.evaluate_ruby do
      Isomorfeus.transport_notification_channel_prefix
    end
    expect(result).to eq 'isomorfeus-transport-notifications-'
  end

  it 'configuration is accessible on the server' do
    expect(Isomorfeus.api_path).to eq '/isomorfeus/api/endpoint'
    expect(Isomorfeus.authorization_driver).to be_nil
    expect(Isomorfeus.server_pub_sub_driver).to be_nil
    expect(Isomorfeus.transport_middleware_requires_user).to be true
    expect(Isomorfeus.middlewares).to include(Isomorfeus::Transport::RackMiddleware)
  end
end