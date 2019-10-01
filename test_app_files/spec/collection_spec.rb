require 'spec_helper'

RSpec.describe 'LucidCollection' do
  context 'on server' do
    it 'can instantiate by inheritance' do
      result = on_server do
        class TestCollection < LucidGenericCollection::Base
        end
        coll = TestCollection.new
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestCollection')
    end

    it 'can instantiate by mixin' do
      result = on_server do
        class TestCollection
          include LucidGenericCollection::Mixin
        end
        coll = TestCollection.new
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestCollection')
    end

    it 'the collection load handler is a valid handler'  do
      result = on_server do
        Isomorfeus.valid_handler_class_name?('Isomorfeus::Data::Handler::Generic')
      end
      expect(result).to be true
    end

    it 'the simple collection is a valid collection class' do
      result = on_server do
        Isomorfeus.valid_generic_collection_class_name?('SimpleCollection')
      end
      expect(result).to be true
    end

    it 'can load a simple collection on the server' do
      result = on_server do
        collection = SimpleCollection.load
        collection.nodes.size
      end
      expect(result).to eq(2)
    end

    it 'can convert a simple collection on the server to transport' do
      result = on_server do
        collection = SimpleCollection.load
        collection.to_transport
      end
      expect(result).to eq("generic_collections"=>{"SimpleCollection"=>{"{}"=>[["SimpleNode", "1"], ["SimpleNode", "2"]]}})
    end

    it 'can convert the simple collection included items on the server to transport' do
      result = on_server do
        collection = SimpleCollection.load
        collection.included_items_to_transport
      end
      expect(result).to eq("generic_nodes" => {"SimpleNode"=>{"1"=>{"attributes"=>{"simple_attribute"=>"simple"}},
                                                      "2"=>{"attributes"=>{"simple_attribute"=>"simple"}}}})
    end
  end

  context 'on client' do
    before :each do
      @doc = visit('/')
    end

    it 'can instantiate by inheritance' do
      result = @doc.evaluate_ruby do
        class TestCollection < LucidGenericCollection::Base
        end
        coll = TestCollection.new
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestCollection')
    end

    it 'can instantiate by mixin' do
      result = @doc.evaluate_ruby do
        class TestCollectionM
          include LucidGenericCollection::Mixin
        end
        coll = TestCollectionM.new
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestCollectionM')
    end

    it 'can load a simple collection on the client' do
      result = @doc.await_ruby do
        SimpleCollection.promise_load.then do |collection|
          collection.nodes.size
        end
      end
      expect(result).to eq(2)
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
      expect(state['data_state']).to have_key('generic_collections')
      expect(state['data_state']['generic_collections']).to have_key('SimpleCollection')
      expect(state['application_state']).to have_key('a_value')
    end

    it 'save the application state for the client, also on subsequent renders' do
      # the same as above, a second time, just to see if the store is initialized correctly
      node = @doc.find('[data-iso-state]')
      expect(node).to be_truthy
      state_json = node.get_attribute('data-iso-state')
      state = Oj.load(state_json, mode: :strict)
      expect(state).to have_key('data_state')
      expect(state['data_state']).to have_key('generic_collections')
      expect(state['data_state']['generic_collections']).to have_key('SimpleCollection')
      expect(state['application_state']).to have_key('a_value')
    end

    it 'it renders the simple collection provided data properly' do
      html = @doc.body.all_text
      expect(html).to include('collection: 2')
    end
  end
end

