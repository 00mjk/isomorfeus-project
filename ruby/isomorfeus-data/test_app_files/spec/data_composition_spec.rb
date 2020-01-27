require 'spec_helper'

CG_NODES_EDGES = [5,10,1]
CG_TRANSPORT = { "SimpleComposition" => {"6"=>{"attributes"=>{},
                                             "parts"=>{"a_array"=>["SimpleArray", "6"],
                                                       "a_collection"=>["SimpleCollection", "6"],
                                                       "a_graph"=>["SimpleGraph", "6"],
                                                       "a_hash"=>["SimpleHash", "6"],
                                                       "a_node"=>["SimpleNode", "6"]}}}}
CG_ITEMS     = { "SimpleArray"=>{"7"=>{"elements"=>[1, 2, 3]}},
                 "SimpleCollection" => {"1"=>{"attributes"=>{}, "nodes"=>[["SimpleNode", "1"],
                                                                          ["SimpleNode", "2"],
                                                                          ["SimpleNode", "3"],
                                                                          ["SimpleNode", "4"],
                                                                          ["SimpleNode", "5"]]},
                                        "7"=>{"attributes"=>{}, "nodes"=>[["SimpleNode", "1"],
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
                 "SimpleGraph" => {"7"=>{"attributes"=>{"one"=>7},
                                         "edges"=>{"edges"=>["SimpleEdgeCollection", "1"]},
                                         "nodes"=>{"nodes"=>["SimpleCollection", "1"]}}},
                 "SimpleHash" => {"7"=>{"attributes"=>{"one"=>1, "three"=>3, "two"=>2}}},
                 "SimpleNode" => {"1"=>{"one"=>1},
                                  "2"=>{"one"=>2},
                                  "3"=>{"one"=>3},
                                  "4"=>{"one"=>4},
                                  "5"=>{"one"=>5},
                                  "7"=>{"one"=>7}} }

RSpec.describe 'LucidData::Composition' do
  context 'on server' do
    it 'can load a simple composition' do
      result = on_server do
        graph = SimpleComposition.load(key: 1)
        n_nodes = graph.a_collection.nodes.size
        n_edges = graph.a_graph.nodes.size + graph.a_graph.edges.size
        n_node = graph.a_node ? 1 : 0
        [n_nodes, n_edges, n_node]
      end
      expect(result).to eq(CG_NODES_EDGES)
    end

    it 'can destroy a simple composition' do
      result = on_server do
        SimpleComposition.destroy(key: '123')
      end
      expect(result).to eq(true)
    end

    it 'can access the included simple array' do
      result = on_server do
        composition = SimpleComposition.load(key: 2)
        composition.a_array.to_a
      end
      expect(result).to eq([1,2,3])
    end

    it 'can access the included simple collection' do
      result = on_server do
        composition = SimpleComposition.load(key: 1)
        composition.a_collection.nodes.map(&:key)
      end
      expect(result).to eq(["1", "2", "3", "4", "5"])
    end

    it 'can access the included simple graph' do
      result = on_server do
        composition = SimpleComposition.load(key: 3)
        nodes = composition.a_graph.nodes.map(&:key)
        edges = composition.a_graph.edges.map(&:key)
        [nodes, edges]
      end
      expect(result).to eq([["1", "2", "3", "4", "5"], ["1", "2", "3", "4", "5"]])
    end

    it 'can access the included simple hash' do
      result = on_server do
        composition = SimpleComposition.load(key: 4)
        composition.a_hash.to_h
      end
      expect(result).to eq({"one"=>1, "three"=>3, "two"=>2})
    end

    it 'can access the included node' do
      result = on_server do
        composition = SimpleComposition.load(key: 5)
        composition.a_node.one
      end
      expect(result).to eq(5)
    end

    it 'can convert the graph to transport' do
      result = on_server do
        composition = SimpleComposition.load(key: 6)
        composition.to_transport
      end
      expect(result).to eq(CG_TRANSPORT)
    end

    it 'can convert the graphs included items to transport' do
      result = on_server do
        composition = SimpleComposition.load(key: 7)
        composition.included_items_to_transport
      end
      expect(result).to eq(CG_ITEMS)
    end
  end

  context 'on client' do
    before :all do
      @doc = visit('/')
    end

    it 'can load a composition' do
      result = @doc.await_ruby do
         SimpleComposition.promise_load(key: 1).then do |graph|
          n_nodes = graph.a_collection.nodes.size
          n_edges = graph.a_graph.nodes.size + graph.a_graph.edges.size
          n_node = graph.a_node ? 1 : 0
          [n_nodes, n_edges, n_node]
        end
      end
      expect(result).to eq(CG_NODES_EDGES)
    end

    it 'can destroy a simple composition' do
      result = @doc.await_ruby do
        SimpleComposition.promise_destroy(key: '123').then { |result| result }
      end
      expect(result).to eq(true)
    end

    it 'can access the included simple array' do
      result = @doc.await_ruby do
         SimpleComposition.promise_load(key: 2).then do |graph|
          graph.a_array.to_a
        end
      end
      expect(result).to eq([1,2,3])
    end

    it 'can access the included simple collection' do
      result = @doc.await_ruby do
         SimpleComposition.promise_load(key: 3).then do |graph|
          graph.a_collection.nodes.map(&:key)
        end
      end
      expect(result).to eq(["1", "2", "3", "4", "5"])
    end

    it 'can access the included simple graph' do
      result = @doc.await_ruby do
         SimpleComposition.promise_load(key: 4).then do |graph|
          nodes = graph.a_graph.nodes.map(&:key)
          edges = graph.a_graph.edges.map(&:key)
          [nodes, edges]
        end
      end
      expect(result).to eq([["1", "2", "3", "4", "5"], ["1", "2", "3", "4", "5"]])
    end

    it 'can access the included simple hash' do
      result = @doc.await_ruby do
         SimpleComposition.promise_load(key: 5).then do |graph|
          graph.a_hash.to_h
        end
      end
      expect(result).to eq({"one"=>1, "three"=>3, "two"=>2})
    end

    it 'can access the included node' do
      result = @doc.await_ruby do
         SimpleComposition.promise_load(key: 8).then do |graph|
          graph.a_node.one
        end
      end
      expect(result).to eq(8)
    end

    it 'can convert the graph to transport' do
      result = @doc.await_ruby do
         SimpleComposition.promise_load(key: 6).then do |graph|
          graph.to_transport
        end
      end
      expect(result).to eq(CG_TRANSPORT)
    end

    it 'can convert the graphs included items to transport' do
      result = @doc.await_ruby do
         SimpleComposition.promise_load(key: 7).then do |graph|
          graph.included_items_to_transport
        end
      end
      expect(result).to eq(CG_ITEMS)
    end
  end
end
