require 'spec_helper'

RSpec.describe 'LucidData::Collection' do
  context 'on server' do
    it 'can instantiate by inheritance' do
      result = on_server do
        class TestCollection < LucidData::Collection::Base
        end
        coll = TestCollection.new(key: 1)
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestCollection')
    end

    it 'can instantiate by mixin' do
      result = on_server do
        class TestCollection
          include LucidData::Collection::Mixin
        end
        coll = TestCollection.new(key: 2)
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
        Isomorfeus.valid_data_class_name?('SimpleCollection')
      end
      expect(result).to be true
    end

    it 'can load a simple collection' do
      result = on_server do
        collection = SimpleCollection.load(key: 1)
        collection.size
      end
      expect(result).to eq(5)
    end

    it 'can destroy a simple collection' do
      result = on_server do
        SimpleCollection.destroy(key: '123')
      end
      expect(result).to eq(true)
    end

    it 'can save a simple collection' do
      result = on_server do
        collection = SimpleCollection.load(key: '123')
        collection.push(SimpleNode.new(key: '4', attributes: { one: 1}))
        before_changed = collection.changed?
        collection.save
        [collection.size, before_changed, collection.changed?]
      end
      expect(result).to eq([6, true, false])
    end

    it 'can convert a simple collection on the server to transport' do
      result = on_server do
        collection = SimpleCollection.load(key: 2)
        collection.to_transport
      end
      expect(result).to eq({"SimpleCollection"=>{"2"=>{"attributes"=>{}, "nodes"=>[["SimpleNode", "1"],
                                                                                   ["SimpleNode", "2"],
                                                                                   ["SimpleNode", "3"],
                                                                                   ["SimpleNode", "4"],
                                                                                   ["SimpleNode", "5"]]}}})
    end

    it 'can convert the simple collection included items on the server to transport' do
      result = on_server do
        collection = SimpleCollection.load(key: 3)
        collection.included_items_to_transport
      end
      expect(result).to eq({"SimpleNode"=>{"1"=>{"one"=>1},
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
        class TestCollection < LucidData::Collection::Base
        end
        coll = TestCollection.new(key: 4)
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestCollection')
    end

    it 'can instantiate by mixin' do
      result = @doc.evaluate_ruby do
        class TestCollectionM
          include LucidData::Collection::Mixin
        end
        coll = TestCollectionM.new(key: 5)
        coll.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestCollectionM')
    end

    it 'can load a simple collection' do
      result = @doc.await_ruby do
        SimpleCollection.promise_load(key: 6).then do |collection|
          collection.size
        end
      end
      expect(result).to eq(5)
    end

    it 'can destroy a simple collection' do
      result = @doc.await_ruby do
        SimpleCollection.promise_destroy(key: '123').then { |result| result }
      end
      expect(result).to eq(true)
    end

    it 'can save a simple collection' do
      result = @doc.await_ruby do
        SimpleCollection.promise_load(key: '123').then do |collection|
          collection.push(SimpleNode.new(key: 4, attributes: {one: 1}))
          before_changed = collection.changed?
          collection.promise_save.then do |collection|
            [collection.size, before_changed, collection.changed?]
          end
        end
      end
      expect(result).to eq([6, true, false])
    end
  end

  context 'Server Side Rendering' do
    before do
      @doc = visit('/ssr')
    end

    it 'renders on the server' do
      expect(@doc.html).to include('Rendered!')
    end

    it 'save the data state for the client' do
      state_json = @doc.evaluate_script('JSON.stringify(ServerSideRenderingStateJSON)')
      state = Oj.load(state_json, mode: :strict)
      expect(state).to have_key('data_state')
      expect(state['data_state']).to have_key('SimpleCollection')
    end

    it 'save the data state for the client, also on subsequent renders' do
      # the same as above, a second time, just to see if the store is initialized correctly
      state_json = @doc.evaluate_script('JSON.stringify(ServerSideRenderingStateJSON)')
      state = Oj.load(state_json, mode: :strict)
      expect(state).to have_key('data_state')
      expect(state['data_state']).to have_key('SimpleCollection')
    end

    it 'it renders the simple collection provided data properly' do
      html = @doc.body.all_text
      expect(html).to include('collection: 5')
    end
  end
end

