require 'spec_helper'

RSpec.describe 'LucidGraph' do
  context 'on server' do
    it 'can instantiate by inheritance' do
      result = on_server do
        class TestGraph < LucidGenericGraph::Base
        end
        graph = TestGraph.new
        graph.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestGraph')
    end

    it 'can instantiate by mixin' do
      result = on_server do
        class TestGraph
          include LucidGenericGraph::Mixin
        end
        graph = TestGraph.new
        graph.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestGraph')
    end

    it 'the graph load handler is a valid handler'  do
      result = on_server do
        Isomorfeus.valid_handler_class_name?('Isomorfeus::Data::Handler::GraphLoadHandler')
      end
      expect(result).to be true
    end

    it 'the simple graph is a valid graph class' do
      result = on_server do
        Isomorfeus.valid_graph_class_name?('SimpleGraph')
      end
      expect(result).to be true
    end

    it 'can load a simple graph on the server' do
      result = on_server do
        graph = SimpleGraph.load
        n_nodes = graph.nodes.size
        n_edges = graph.edges.size
        [n_nodes, n_edges]
      end
      expect(result).to eq([2,1])
    end

    it 'can converts a simple graph on the server to transport' do
      result = on_server do
        graph = SimpleGraph.load
        graph.to_transport
      end
      expect(result).to eq("graphs"=>{"SimpleGraph"=>{"{}"=>{"edges"=>[["SimpleEdge", "1"]],
                                                             "nodes"=>[["SimpleNode", "1"], ["SimpleNode", "2"]]}}})
    end

    it 'can converts a simple graphs included items on the server to transport' do
      result = on_server do
        graph = SimpleGraph.load
        graph.included_items_to_transport
      end
      expect(result).to eq("edges" => {
                             "SimpleEdge"=>{"1"=>{"attributes"=>{"simple_attribute"=>"simple"},
                                                  "from"=>["SimpleNode", "1"],
                                                  "to"=>["SimpleNode", "2"]}}},
                           "nodes" => {"SimpleNode"=>{
                             "1"=>{"attributes"=>{"simple_attribute"=>"simple"}},
                             "2"=>{"attributes"=>{"simple_attribute"=>"simple"}}
                           }})
    end
  end

  context 'on client' do
    before :each do
      @doc = visit('/')
    end

    it 'can instantiate by inheritance' do
      result = @doc.evaluate_ruby do
        class TestGraph < LucidGenericGraph::Base
        end
        graph = TestGraph.new
        graph.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestGraph')
    end

    it 'can instantiate by mixin' do
      result = @doc.evaluate_ruby do
        class TestGraphM
          include LucidGenericGraph::Mixin
        end
        graph = TestGraphM.new
        graph.instance_variable_get(:@class_name)
      end
      expect(result).to eq('TestGraphM')
    end

    it 'can load a simple graph on the client' do
      result = @doc.await_ruby do
        SimpleGraph.promise_load.then do |graph|
          n_nodes = graph.nodes.size
          n_edges = graph.edges.size
          [n_nodes, n_edges]
        end
      end
      expect(result).to eq([2,1])
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

    it 'it renders the simple graph provided data properly' do
      html = @doc.body.all_text
      expect(html).to include('nodes: 2')
      expect(html).to include('edges: 1')
    end
  end
end
