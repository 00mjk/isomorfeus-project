require 'spec_helper'

RSpec.describe 'LucidArray' do
  context 'on server' do
    it 'can instantiate by inheritance' do
      result = on_server do
        class TestArray < LucidArray::Base
        end
        coll = TestArray.new
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestArray')
    end

    it 'can instantiate by mixin' do
      result = on_server do
        class TestArray
          include LucidArray::Mixin
        end
        coll = TestArray.new
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestArray')
    end

    it 'the array load handler is a valid handler'  do
      result = on_server do
        Isomorfeus.valid_handler_class_name?('Isomorfeus::Data::Handler::ArrayLoadHandler')
      end
      expect(result).to be true
    end

    it 'the simple array is a valid array class' do
      result = on_server do
        Isomorfeus.valid_array_class_name?('SimpleArray')
      end
      expect(result).to be true
    end

    it 'can load a simple array on the server' do
      result = on_server do
        array = SimpleArray.load
        array.items
      end
      expect(result).to eq([1,2,3])
    end

    it 'can converts a simple array on the server to transport' do
      result = on_server do
        array = SimpleArray.load
        array.to_transport
      end
      expect(result).to eq("arrays"=> {"SimpleArray"=>{"{}"=>[1,2,3]}})
    end
  end

  context 'on client' do
    before :each do
      @doc = visit('/')
    end

    it 'can instantiate by inheritance' do
      result = @doc.evaluate_ruby do
        class TestArray < LucidArray::Base
        end
        coll = TestArray.new
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestArray')
    end

    it 'can instantiate by mixin' do
      result = @doc.evaluate_ruby do
        class TestArrayM
          include LucidArray::Mixin
        end
        coll = TestArrayM.new
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestArrayM')
    end

    it 'can load a simple array on the client' do
      result = @doc.await_ruby do
        SimpleArray.promise_load.then do |array|
          array.items
        end
      end
      expect(result).to eq([1,2,3])
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

    it 'it renders the simple array provided data properly' do
      html = @doc.body.all_text
      expect(html).to include('array: 1,2,3')
    end
  end
end
