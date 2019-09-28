require 'spec_helper'

RSpec.describe 'Arango' do
  it 'can connect to arango' do
    result = on_server do
      Arango.current_server
    end
    STDERR.puts result
    expect(result).to be truthy
    result = on_server do
      Arango.current_database
    end
    STDERR.puts result
    expect(result).to be truthy
  end
end
