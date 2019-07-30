require 'spec_helper'

RSpec.describe 'LucidHash' do
  context 'on server' do
    it 'can instantiate by inheritance' do
      result = on_server do
        class TestHash < LucidHash::Base
        end
        coll = TestHash.new
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestHash')
    end

    it 'can instantiate by mixin' do
      result = on_server do
        class TestHash
          include LucidHash::Mixin
        end
        coll = TestHash.new
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestHash')
    end

    it 'the hash load handler is a valid handler'  do
      result = on_server do
        Isomorfeus.valid_handler_class_name?('Isomorfeus::Data::Handler::HashLoadHandler')
      end
      expect(result).to be true
    end

    it 'the simple hash is a valid hash class' do
      result = on_server do
        Isomorfeus.valid_hash_class_name?('SimpleHash')
      end
      expect(result).to be true
    end

    it 'can load a simple hash on the server' do
      result = on_server do
        hash = SimpleHash.load
        hash.to_h
      end
      expect(result).to eq({"simple_key"=>"simple_value"})
    end

    it 'can converts a simple hash on the server to transport' do
      result = on_server do
        hash = SimpleHash.load
        hash.to_transport
      end
      expect(result).to eq("hashes"=>{"SimpleHash"=>{"{}"=>{"simple_key"=>"simple_value"}}})
    end
  end

  context 'on client' do
    before :each do
      @doc = visit('/')
    end

    it 'can instantiate by inheritance' do
      result = @doc.evaluate_ruby do
        class TestHash < LucidHash::Base
        end
        coll = TestHash.new
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestHash')
    end

    it 'can instantiate by mixin' do
      result = @doc.evaluate_ruby do
        class TestHashM
          include LucidHash::Mixin
        end
        coll = TestHashM.new
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestHashM')
    end

    it 'can load a simple hash on the client' do
      result = @doc.await_ruby do
        SimpleHash.promise_load.then do |hash|
          hash.to_h
        end
      end
      expect(result).to eq({"simple_key"=>"simple_value"})
    end
  end

  context 'Server Side Rendering' do
    before do
      @doc = visit('/ssr')
    end

    it 'renders on the server' do
      expect(@doc.html).to include('Rendered!')
    end

    it 'save the application state for the client' do
      node = @doc.find('[data-iso-state]')
      expect(node).to be_truthy
      state_json = node.get_attribute('data-iso-state')
      state = Oj.load(state_json, mode: :strict)
      expect(state).to have_key('data_state')

      expect(state['application_state']).to have_key('a_value')
    end

    it 'save the application state for the client, also on subsequent renders' do
      # the same as above, a second time, just to see if the store is initialized correctly
      node = @doc.find('[data-iso-state]')
      expect(node).to be_truthy
      state_json = node.get_attribute('data-iso-state')
      state = Oj.load(state_json, mode: :strict)
      expect(state).to have_key('application_state')

      expect(state['application_state']).to have_key('a_value')
    end

    it 'it renders the simple hash provided data properly' do
      html = @doc.body.all_text
      expect(html).to include('hash: {"simple_key"=>"simple_value"}')
    end
  end
end

