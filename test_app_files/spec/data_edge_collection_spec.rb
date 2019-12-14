require 'spec_helper'

RSpec.describe 'LucidData::EdgeCollection' do
  context 'on server' do
    it 'can instantiate by inheritance' do
      result = on_server do
        class TestEdgeCollection < LucidData::EdgeCollection::Base
        end
        coll = TestEdgeCollection.new(key: 1)
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestEdgeCollection')
    end

    it 'can instantiate by mixin' do
      result = on_server do
        class TestEdgeCollection
          include LucidData::EdgeCollection::Mixin
        end
        coll = TestEdgeCollection.new(key: 2)
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestEdgeCollection')
    end

    it 'the collection load handler is a valid handler'  do
      result = on_server do
        Isomorfeus.valid_handler_class_name?('Isomorfeus::Data::Handler::Generic')
      end
      expect(result).to be true
    end

    it 'the simple collection is a valid collection class' do
      result = on_server do
        Isomorfeus.valid_data_class_name?('SimpleEdgeCollection')
      end
      expect(result).to be true
    end

    it 'can load a simple collection on the server' do
      result = on_server do
        collection = SimpleEdgeCollection.load(key: 1)
        collection.size
      end
      expect(result).to eq(5)
    end

    it 'can convert a simple collection on the server to transport' do
      result = on_server do
        collection = SimpleEdgeCollection.load(key: 2)
        collection.to_transport
      end
      expect(result).to eq({"SimpleEdgeCollection"=>{"2"=>{"attributes"=>{}, "edges"=>[["SimpleEdge", "1"],
                                                                                   ["SimpleEdge", "2"],
                                                                                   ["SimpleEdge", "3"],
                                                                                   ["SimpleEdge", "4"], 
                                                                                   ["SimpleEdge", "5"]]}}})
    end

    it 'can convert the simple collection included items on the server to transport' do
      result = on_server do
        collection = SimpleEdgeCollection.load(key: 3)
        collection.included_items_to_transport
      end
      expect(result).to eq({"SimpleEdge"=>{"1"=>{"one"=>1},
                                           "2"=>{"one"=>2},
                                           "3"=>{"one"=>3},
                                           "4"=>{"one"=>4},
                                           "5"=>{"one"=>5}}})
    end
  end

  context 'on client' do
    before :each do
      @doc = visit('/')
    end

    it 'can instantiate by inheritance' do
      result = @doc.evaluate_ruby do
        class TestEdgeCollection < LucidData::EdgeCollection::Base
        end
        coll = TestEdgeCollection.new(key: 4)
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestEdgeCollection')
    end

    it 'can instantiate by mixin' do
      result = @doc.evaluate_ruby do
        class TestEdgeCollectionM
          include LucidData::EdgeCollection::Mixin
        end
        coll = TestEdgeCollectionM.new(key: 5)
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestEdgeCollectionM')
    end

    it 'can load a simple collection on the client' do
      result = @doc.await_ruby do
        SimpleEdgeCollection.promise_load(key: 6).then do |collection|
          collection.size
        end
      end
      expect(result).to eq(5)
    end
  end

  #context 'Server Side Rendering' do
  #  before do
  #    @doc = visit('/ssr')
  #  end
  #
  #  it 'renders on the server' do
  #    expect(@doc.html).to include('Rendered!')
  #  end
  #
  #  it 'save the data state for the client' do
  #    node = @doc.find('[data-iso-state]')
  #    expect(node).to be_truthy
  #    state_json = node.get_attribute('data-iso-state')
  #    state = Oj.load(state_json, mode: :strict)
  #    expect(state).to have_key('data_state')
  #    expect(state['data_state']).to have_key('SimpleCollection')
  #  end
  #
  #  it 'save the data state for the client, also on subsequent renders' do
  #    # the same as above, a second time, just to see if the store is initialized correctly
  #    node = @doc.find('[data-iso-state]')
  #    expect(node).to be_truthy
  #    state_json = node.get_attribute('data-iso-state')
  #    state = Oj.load(state_json, mode: :strict)
  #    expect(state).to have_key('data_state')
  #    expect(state['data_state']).to have_key('SimpleCollection')
  #  end
  #
  #  it 'it renders the simple collection provided data properly' do
  #    html = @doc.body.all_text
  #    expect(html).to include('collection: 5')
  #  end
  #end
end

