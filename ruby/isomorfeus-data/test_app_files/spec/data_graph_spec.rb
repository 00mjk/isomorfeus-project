require 'spec_helper'

RSpec.describe 'LucidGraph' do
  context 'on server' do
    it 'can instantiate by inheritance' do
      result = on_server do
        class TestGraph < LucidData::Graph::Base
        end
        graph = TestGraph.new(key: 1)
        graph.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestGraph')
    end

    it 'can instantiate by mixin' do
      result = on_server do
        class TestGraph
          include LucidData::Graph::Mixin
        end
        graph = TestGraph.new(key: 2)
        graph.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestGraph')
    end

    it 'the graph load handler is a valid handler'  do
      result = on_server do
        Isomorfeus.valid_handler_class_name?('Isomorfeus::Data::Handler::Generic')
      end
      expect(result).to be true
    end

    it 'the simple graph is a valid graph class' do
      result = on_server do
        Isomorfeus.valid_data_class_name?('SimpleGraph')
      end
      expect(result).to be true
    end

    it 'can load a simple graph on the server' do
      result = on_server do
        graph = SimpleGraph.load(key: 3)
        n_nodes = graph.nodes.size
        n_edges = graph.edges.size
        [n_nodes, n_edges]
      end
      expect(result).to eq([5,5])
    end

    it 'can converts a simple graph on the server to transport' do
      result = on_server do
        graph = SimpleGraph.load(key: 4)
        graph.to_transport
      end
      expect(result).to eq("SimpleGraph" => {"4"=>{"attributes"=>{"one"=>4},
                                                   "edges"=>{"edges"=>["SimpleEdgeCollection", "1"]},
                                                   "nodes"=>{"nodes"=>["SimpleCollection", "1"]}}})
    end

    it 'can converts a simple graphs included items on the server to transport' do
      result = on_server do
        graph = SimpleGraph.load(key: 5)
        graph.included_items_to_transport
      end
      expect(result).to eq("SimpleCollection" => {"1"=>{"attributes"=>{}, "nodes"=>[["SimpleNode", "1"],
                                                                                    ["SimpleNode", "2"],
                                                                                    ["SimpleNode", "3"],
                                                                                    ["SimpleNode", "4"],
                                                                                    ["SimpleNode", "5"]]}},
                           "SimpleEdge" => {"1"=>{"attributes"=>{"one"=>1}, "from"=>["SimpleNode", "1"], "to"=>["SimpleNode", "2"]},
                                             "2"=>{"attributes"=>{"one"=>2}, "from"=>["SimpleNode", "2"], "to"=>["SimpleNode", "3"]},
                                             "3"=>{"attributes"=>{"one"=>3}, "from"=>["SimpleNode", "3"], "to"=>["SimpleNode", "4"]},
                                             "4"=>{"attributes"=>{"one"=>4}, "from"=>["SimpleNode", "4"], "to"=>["SimpleNode", "5"]},
                                             "5"=>{"attributes"=>{"one"=>5}, "from"=>["SimpleNode", "5"], "to"=>["SimpleNode", "5"]}},
                           "SimpleEdgeCollection" => {"1"=>{"attributes"=>{}, "edges"=>[["SimpleEdge", "1"],
                                                                                         ["SimpleEdge", "2"],
                                                                                         ["SimpleEdge", "3"],
                                                                                         ["SimpleEdge", "4"],
                                                                                         ["SimpleEdge", "5"]]}},
                           "SimpleNode" => {"1"=>{"one"=>1},
                                             "2"=>{"one"=>2},
                                             "3"=>{"one"=>3},
                                             "4"=>{"one"=>4},
                                             "5"=>{"one"=>5}})
    end
  end

  context 'on client' do
    before :each do
      @doc = visit('/')
    end

    it 'can instantiate by inheritance' do
      result = @doc.evaluate_ruby do
        class TestGraph < LucidData::Graph::Base
        end
        graph = TestGraph.new(key: 6)
        graph.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestGraph')
    end

    it 'can instantiate by mixin' do
      result = @doc.evaluate_ruby do
        class TestGraphM
          include LucidData::Graph::Mixin
        end
        graph = TestGraphM.new(key: 7)
        graph.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestGraphM')
    end

    it 'can load a simple graph on the client' do
      result = @doc.await_ruby do
        SimpleGraph.promise_load(key: 8).then do |graph|
          n_nodes = graph.nodes.size
          n_edges = graph.edges.size
          [n_nodes, n_edges]
        end
      end
      expect(result).to eq([5,5])
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
      state_json = @doc.evaluate_script('JSON.stringify(ServerSideRenderingStateJSON)')
      state = Oj.load(state_json, mode: :strict)
      expect(state).to have_key('data_state')
      expect(state['data_state']).to have_key('SimpleGraph')
    end

    it 'save the application state for the client, also on subsequent renders' do
      # the same as above, a second time, just to see if the store is initialized correctly
      state_json = @doc.evaluate_script('JSON.stringify(ServerSideRenderingStateJSON)')
      state = Oj.load(state_json, mode: :strict)
      expect(state).to have_key('data_state')
      expect(state['data_state']).to have_key('SimpleGraph')
    end

    it 'it renders the simple graph provided data properly' do
      html = @doc.body.all_text
      expect(html).to include('nodes: 5')
      expect(html).to include('edges: 5')
    end
  end
end
