require 'spec_helper'

RSpec.describe 'Arango' do
  it 'is configured' do
    result = on_server do
      Isomorfeus.arango_configured?
    end
    expect(result).to be true
  end

  it 'configuration is correct' do
    result = on_server do
      Isomorfeus.arango_test
    end
    expect(result).to eq({:host=>"localhost", :password=>"root", :port=>"8529", :username=>"root", database: 'TestAppAppTest'})
  end

  it 'is connected' do
    result = on_server do
      Arango.current_server
    end
    expect(result).to be_a Arango::Server
    result = on_server do
      Arango.current_database
    end
    expect(result).to be_a Arango::Database
  end

  it 'can connect' do
    result = on_server do
      Isomorfeus.connect_to_arango
    end
    expect(result).to be_a Arango::Database
  end
end
