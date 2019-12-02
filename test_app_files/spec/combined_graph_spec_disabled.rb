require 'spec_helper'

CG_NODES_EDGES = [5,2]
CG_TRANSPORT = { "generic_graphs" => { "CombinedGraph" => { "{}" => { "generic_edges"        => [["SimpleEdge", "2"]],
                                                                      "included_collections" => { "simple_collection" => ["SimpleCollection", "{}"] },
                                                                      "included_graphs"      => { "simple_graph" => ["SimpleGraph", "{}"] },
                                                                      "included_nodes"       => { "simple_node" => ["SimpleNode", "8"] },
                                                                      "generic_nodes"        => [["SimpleNode", "3"], ["SimpleNode", "4"]] } } } }
CG_ITEMS     = { "generic_collections" => { "SimpleCollection" => { "{}" => [["SimpleNode", "1"], ["SimpleNode", "2"]] } },
                 "generic_edges"       => { "SimpleEdge" => { "1" => { "attributes" => { "simple_attribute" => "simple" }, "from" => ["SimpleNode", "1"], "to" => ["SimpleNode", "2"] },
                                                              "2" => { "attributes" => { "simple_attribute" => "simple" }, "from" => ["SimpleNode", "3"], "to" => ["SimpleNode", "4"] } } },
                 "generic_graphs"      => { "SimpleGraph" => { "{}" => { "generic_edges" => [["SimpleEdge", "1"]],
                                                                         "generic_nodes" => [["SimpleNode", "1"], ["SimpleNode", "2"]] } } },
                 "generic_nodes"       => { "SimpleNode" => { "1" => { "attributes" => { "simple_attribute" => "simple" } },
                                                              "2" => { "attributes" => { "simple_attribute" => "simple" } },
                                                              "3" => { "attributes" => { "simple_attribute" => "simple" } },
                                                              "4" => { "attributes" => { "simple_attribute" => "simple" } },
                                                              "8" => { "attributes" => { "simple_attribute" => "yeah, a test" } } } } }

MCG_NODES_EDGES = [8,3]
MCG_TRANSPORT = { "generic_graphs" => { "MultiCombinedGraph" => { "{}" => { "generic_edges"        => [["SimpleEdge", "3"]],
                                                                            "included_collections" => { "simple_collection" => ["SimpleCollection", "{}"] },
                                                                            "included_graphs"      => { "combined_graph" => ["CombinedGraph", "{}"],
                                                                                                        "simple_graph"   => ["SimpleGraph", "{}"] },
                                                                            "included_nodes"       => { "simple_node" => ["SimpleNode", "9"] },
                                                                            "generic_nodes"        => [["SimpleNode", "5"], ["SimpleNode", "6"]] } } } }
MCG_ITEMS     = { "generic_collections" => { "SimpleCollection" => { "{}" => [["SimpleNode", "1"], ["SimpleNode", "2"]] } },
                  "generic_edges"       => { "SimpleEdge" => { "1" => { "attributes" => { "simple_attribute" => "simple" }, "from" => ["SimpleNode", "1"], "to" => ["SimpleNode", "2"] },
                                                               "2" => { "attributes" => { "simple_attribute" => "simple" }, "from" => ["SimpleNode", "3"], "to" => ["SimpleNode", "4"] },
                                                               "3" => { "attributes" => { "simple_attribute" => "simple" }, "from" => ["SimpleNode", "5"], "to" => ["SimpleNode", "6"] } } },
                  "generic_graphs"      => { "CombinedGraph" => { "{}" => { "generic_edges"                => [["SimpleEdge", "2"]],
                                                                    "included_collections" => { "simple_collection" => ["SimpleCollection", "{}"] },
                                                                    "included_graphs"      => { "simple_graph" => ["SimpleGraph", "{}"] },
                                                                    "included_nodes"       => { "simple_node" => ["SimpleNode", "8"] },
                                                                    "generic_nodes"                => [["SimpleNode", "3"], ["SimpleNode", "4"]] } },
                                             "SimpleGraph"   => { "{}" => { "generic_edges" => [["SimpleEdge", "1"]],
                                                                            "generic_nodes" => [["SimpleNode", "1"], ["SimpleNode", "2"]] } } },
                  "generic_nodes"       => { "SimpleNode" => { "1" => { "attributes" => { "simple_attribute" => "simple" } },
                                                               "2" => { "attributes" => { "simple_attribute" => "simple" } },
                                                               "3" => { "attributes" => { "simple_attribute" => "simple" } },
                                                               "4" => { "attributes" => { "simple_attribute" => "simple" } },
                                                               "5" => { "attributes" => { "simple_attribute" => "simple" } },
                                                               "6" => { "attributes" => { "simple_attribute" => "simple" } },
                                                               "8" => { "attributes" => { "simple_attribute" => "yeah, a test" } },
                                                               "9" => { "attributes" => { "simple_attribute" => "yeah, yeah, yeah, a test" } } } } }

RSpec.describe 'Combined LucidGraph' do
  context 'on server' do
    it 'can load a combined graph' do
      result = on_server do
        graph = CombinedGraph.load(key: 1)
        n_nodes = graph.nodes.size
        n_edges = graph.edges.size
        [n_nodes, n_edges]
      end
      expect(result).to eq(CG_NODES_EDGES)
    end

    it 'can access the included simple array' do
      result = on_server do
        graph = CombinedGraph.load(key: 1)
        graph.simple_array.items
      end
      expect(result).to eq([1,2,3])
    end

    it 'can access the included simple collection' do
      result = on_server do
        graph = CombinedGraph.load(key: 1)
        graph.simple_collection.nodes.map(&:id)
      end
      expect(result).to eq(["1","2"])
    end

    it 'can access the included simple graph' do
      result = on_server do
        graph = CombinedGraph.load(key: 1)
        nodes = graph.simple_graph.nodes.map(&:id)
        edges = graph.simple_graph.edges.map(&:id)
        [nodes, edges]
      end
      expect(result).to eq([["1","2"], ["1"]])
    end

    it 'can access the included simple hash' do
      result = on_server do
        graph = CombinedGraph.load(key: 1)
        graph.simple_hash.to_h
      end
      expect(result).to eq({"simple_key"=>"simple_value"})
    end

    it 'can access the included node' do
      result = on_server do
        graph = CombinedGraph.load(key: 1)
        graph.simple_node.simple_attribute
      end
      expect(result).to eq('yeah, a test')
    end

    it 'can convert the graph to transport' do
      result = on_server do
        graph = CombinedGraph.load(key: 1)
        graph.to_transport
      end
      expect(result).to eq(CG_TRANSPORT)
    end

    it 'can convert the graphs included items to transport' do
      result = on_server do
        graph = CombinedGraph.load(key: 1)
        graph.included_items_to_transport
      end
      expect(result).to eq(CG_ITEMS)
    end

    context 'multi combined graph' do
      it 'can load a multi combined graph on the server' do
        result = on_server do
          graph = MultiCombinedGraph.load(key: 1)
          n_nodes = graph.nodes.size
          n_edges = graph.edges.size
          [n_nodes, n_edges]
        end
        expect(result).to eq(MCG_NODES_EDGES)
      end

      it 'can access the included simple array' do
        result = on_server do
          graph = MultiCombinedGraph.load(key: 1)
          graph.simple_array.items
        end
        expect(result).to eq([1,2,3])
      end

      it 'can access the included simple collection' do
        result = on_server do
          graph = MultiCombinedGraph.load(key: 1)
          graph.simple_collection.nodes.map(&:id)
        end
        expect(result).to eq(["1","2"])
      end

      it 'can access the included simple graph' do
        result = on_server do
          graph = MultiCombinedGraph.load(key: 1)
          nodes = graph.simple_graph.nodes.map(&:id)
          edges = graph.simple_graph.edges.map(&:id)
          [nodes, edges]
        end
        expect(result).to eq([["1","2"], ["1"]])
      end

      it 'can access the included simple hash' do
        result = on_server do
          graph = MultiCombinedGraph.load(key: 1)
          graph.simple_hash.to_h
        end
        expect(result).to eq({"simple_key"=>"simple_value"})
      end

      it 'can access the included node' do
        result = on_server do
          graph = MultiCombinedGraph.load(key: 1)
          graph.simple_node.simple_attribute
        end
        expect(result).to eq('yeah, yeah, yeah, a test' )
      end

      it 'can access the combined graph included simple array' do
        result = on_server do
          graph = MultiCombinedGraph.load(key: 1)
          graph.combined_graph.simple_array.items
        end
        expect(result).to eq([1,2,3])
      end

      it 'can access the combined graph included simple collection' do
        result = on_server do
          graph = MultiCombinedGraph.load(key: 1)
          graph.combined_graph.simple_collection.nodes.map(&:id)
        end
        expect(result).to eq(["1","2"])
      end

      it 'can access the combined graph included simple graph' do
        result = on_server do
          graph = MultiCombinedGraph.load(key: 1)
          nodes = graph.combined_graph.simple_graph.nodes.map(&:id)
          edges = graph.combined_graph.simple_graph.edges.map(&:id)
          [nodes, edges]
        end
        expect(result).to eq([["1","2"], ["1"]])
      end

      it 'can access the combined graph included simple hash' do
        result = on_server do
          graph = MultiCombinedGraph.load(key: 1)
          graph.combined_graph.simple_hash.to_h
        end
        expect(result).to eq({"simple_key"=>"simple_value"})
      end

      it 'can access the included node' do
        result = on_server do
          graph = MultiCombinedGraph.load(key: 1)
          graph.combined_graph.simple_node.simple_attribute
        end
        expect(result).to eq('yeah, a test')
      end

      it 'can convert the graph to transport' do
        result = on_server do
          graph = MultiCombinedGraph.load(key: 1)
          graph.to_transport
        end
        expect(result).to eq(MCG_TRANSPORT)
      end

      it 'can convert the graphs included items to transport' do
        result = on_server do
          graph = MultiCombinedGraph.load(key: 1)
          graph.included_items_to_transport
        end
        expect(result).to eq(MCG_ITEMS)
      end
    end
  end

  context 'on client' do
    before :all do
      @doc = visit('/')
    end

    it 'can load a combined graph' do
      result = @doc.await_ruby do
        CombinedGraph.promise_load.then do |graph|
          n_nodes = graph.nodes.size
          n_edges = graph.edges.size
          [n_nodes, n_edges]
        end
      end
      expect(result).to eq(CG_NODES_EDGES)
    end

    it 'can access the included simple array' do
      result = @doc.await_ruby do
        CombinedGraph.promise_load.then do |graph|
          graph.simple_array.items
        end
      end
      expect(result).to eq([1,2,3])
    end

    it 'can access the included simple collection' do
      result = @doc.await_ruby do
        CombinedGraph.promise_load.then do |graph|
          graph.simple_collection.nodes.map(&:id)
        end
      end
      expect(result).to eq(["1","2"])
    end

    it 'can access the included simple graph' do
      result = @doc.await_ruby do
        CombinedGraph.promise_load.then do |graph|
          nodes = graph.simple_graph.nodes.map(&:id)
          edges = graph.simple_graph.edges.map(&:id)
          [nodes, edges]
        end
      end
      expect(result).to eq([["1","2"], ["1"]])
    end

    it 'can access the included simple hash' do
      result = @doc.await_ruby do
        CombinedGraph.promise_load.then do |graph|
          graph.simple_hash.to_h
        end
      end
      expect(result).to eq({"simple_key"=>"simple_value"})
    end

    it 'can access the included node' do
      result = @doc.await_ruby do
        CombinedGraph.promise_load.then do |graph|
          graph.simple_node.simple_attribute
        end
      end
      expect(result).to eq('yeah, a test')
    end

    it 'can convert the graph to transport' do
      result = @doc.await_ruby do
        CombinedGraph.promise_load.then do |graph|
          graph.to_transport
        end
      end
      expect(result).to eq(CG_TRANSPORT)
    end

    it 'can convert the graphs included items to transport' do
      result = @doc.await_ruby do
        CombinedGraph.promise_load.then do |graph|
          graph.included_items_to_transport
        end
      end
      expect(result).to eq(CG_ITEMS)
    end

    context 'multi combined graph' do
      it 'can load a multi combined graph' do
        result = @doc.await_ruby do
          MultiCombinedGraph.promise_load.then do |graph|
            n_nodes = graph.nodes.size
            n_edges = graph.edges.size
            [n_nodes, n_edges]
          end
        end
        expect(result).to eq(MCG_NODES_EDGES)
      end

      it 'can access the included simple array' do
        result = @doc.await_ruby do
          MultiCombinedGraph.promise_load.then do |graph|
            graph.simple_array.items
          end
        end
        expect(result).to eq([1,2,3])
      end

      it 'can access the included simple collection' do
        result = @doc.await_ruby do
          MultiCombinedGraph.promise_load.then do |graph|
            graph.simple_collection.nodes.map(&:id)
          end
        end
        expect(result).to eq(["1","2"])
      end

      it 'can access the included simple graph' do
        result = @doc.await_ruby do
          MultiCombinedGraph.promise_load.then do |graph|
            nodes = graph.simple_graph.nodes.map(&:id)
            edges = graph.simple_graph.edges.map(&:id)
            [nodes, edges]
          end
        end
        expect(result).to eq([["1","2"], ["1"]])
      end

      it 'can access the included simple hash' do
        result = @doc.await_ruby do
          MultiCombinedGraph.promise_load.then do |graph|
            graph.simple_hash.to_h
          end
        end
        expect(result).to eq({"simple_key"=>"simple_value"})
      end

      it 'can access the included node' do
        result = @doc.await_ruby do
          MultiCombinedGraph.promise_load.then do |graph|
            graph.simple_node.simple_attribute
          end
        end
        expect(result).to eq('yeah, yeah, yeah, a test' )
      end

      it 'can access the combined graph included simple array' do
        result = @doc.await_ruby do
          MultiCombinedGraph.promise_load.then do |graph|
            graph.combined_graph.simple_array.items
          end
        end
        expect(result).to eq([1,2,3])
      end

      it 'can access the combined graph included simple collection' do
        result = @doc.await_ruby do
          MultiCombinedGraph.promise_load.then do |graph|
            graph.combined_graph.simple_collection.nodes.map(&:id)
          end
        end
        expect(result).to eq(["1","2"])
      end

      it 'can access the combined graph included simple graph' do
        result = @doc.await_ruby do
          MultiCombinedGraph.promise_load.then do |graph|
            nodes = graph.combined_graph.simple_graph.nodes.map(&:id)
            edges = graph.combined_graph.simple_graph.edges.map(&:id)
            [nodes, edges]
          end
        end
        expect(result).to eq([["1","2"], ["1"]])
      end

      it 'can access the combined graph included simple hash' do
        result = @doc.await_ruby do
          MultiCombinedGraph.promise_load.then do |graph|
            graph.combined_graph.simple_hash.to_h
          end
        end
        expect(result).to eq({"simple_key"=>"simple_value"})
      end

      it 'can access the included node' do
        result = @doc.await_ruby do
          MultiCombinedGraph.promise_load.then do |graph|
            graph.combined_graph.simple_node.simple_attribute
          end
        end
        expect(result).to eq('yeah, a test')
      end

      it 'can convert the graph to transport' do
        result = @doc.await_ruby do
          MultiCombinedGraph.promise_load.then do |graph|
            graph.to_transport
          end
        end
        expect(result).to eq(MCG_TRANSPORT)
      end

      it 'can convert the graphs included items to transport' do
        result = @doc.await_ruby do
          MultiCombinedGraph.promise_load.then do |graph|
            graph.included_items_to_transport
          end
        end
        expect(result).to eq(MCG_ITEMS)
      end
    end
  end
end
