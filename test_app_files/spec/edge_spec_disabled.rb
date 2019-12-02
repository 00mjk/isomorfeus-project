require 'spec_helper'

RSpec.describe 'LucidEdge' do
  context 'on the server' do
    it 'can instantiate a edge by inheritance' do
      result = on_server do
        class TestEdgeBase < LucidData::Edge::Base
          attribute :test_attribute
        end
        edge = TestEdgeBase.new(test_attribute: 'test_value')
        edge.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'can instantiate a edge by mixin' do
      result = on_server do
        class TestEdgeMixin
          include LucidData::Edge::Mixin
          attribute :test_attribute
        end
        edge = TestEdgeMixin.new(test_attribute: 'test_value')
        edge.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'verifies attribute class' do
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        edge = TestEdgeMixinC.new(test_attribute: 'test_value')
        edge.test_attribute.class.name
      end
      expect(result).to eq('String')
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        begin
          TestEdgeMixinC.new(test_attribute: 10)
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        begin
          edge = TestEdgeMixinC.new
          edge.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if attribute is_a' do
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, is_a: Enumerable
        end
        edge = TestEdgeMixinC.new(test_attribute: ['test_value'])
        edge.test_attribute.class.name
      end
      expect(result).to eq('Array')
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          TestEdgeMixinC.new(test_attribute: 10)
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          edge = TestEdgeMixinC.new
          edge.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'uses a default value' do
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, default: 10
        end
        edge = TestEdgeMixinC.new
        edge.test_attribute
      end
      expect(result).to eq(10)
    end

    it 'reports a change' do
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute
        end
        edge = TestEdgeMixinC.new(test_attribute: 10)
        edge.changed?
      end
      expect(result).to be(false)
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute
        end
        edge = TestEdgeMixinC.new(test_attribute: 10)
        edge.test_attribute = 20
        edge.changed?
      end
      expect(result).to be(true)
    end

    it 'converts to cid' do
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute
        end
        edge = TestEdgeMixinC.new(id: 10)
        edge.to_cid
      end
      expect(result).to eq(['TestEdgeMixinC', '10'])
    end

    it 'can validate a attribute' do
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        edge = TestEdgeMixinC.new
        edge.valid_attribute?(:test_attribute, 10)
      end
      expect(result).to eq(false)
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        edge = TestEdgeMixinC.new
        edge.valid_attribute?(:test, '10')
      end
      expect(result).to eq(false)
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        edge = TestEdgeMixinC.new
        edge.valid_attribute?(:test_attribute, '10')
      end
      expect(result).to eq(true)
    end

    it 'converts to transport' do
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute
        end
        class TestNode < LucidData::Document::Base
        end
        node1 = TestNode.new(id: 11)
        node2 = TestNode.new(id: 12)
        edge = TestEdgeMixinC.new(id: 10, from: node1, to: node2, test_attribute: 'test')
        edge.to_transport
      end
      expect(result).to eq("generic_edges"=>{"TestEdgeMixinC"=>{"10"=>{"from"=>["TestNode","11"],"to"=>["TestNode","12"],
                                                               "attributes"=>{"test_attribute"=>"test"}}}})
    end

    it 'keeps server_only attribute on server' do
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, server_only: true
        end
        node = TestEdgeMixinC.new(id: 10, test_attribute: 'test')
        node.to_transport
      end
      expect(result).to eq("generic_edges"=>{"TestEdgeMixinC"=>{"10"=>{"from"=>nil,"to"=>nil,"attributes"=>{}}}})
    end
  end

  context 'on the client' do
    before :each do
      @doc = visit('/')
    end

    it 'can instantiate a edge by inheritance' do
      result = @doc.evaluate_ruby do
        class TestEdgeBase < LucidData::Edge::Base
          attribute :test_attribute
        end
        edge = TestEdgeBase.new(test_attribute: 'test_value')
        edge.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'can instantiate a edge by mixin' do
      result = @doc.evaluate_ruby do
        class TestEdgeMixin
          include LucidData::Edge::Mixin
          attribute :test_attribute
        end
        edge = TestEdgeMixin.new(test_attribute: 'test_value')
        edge.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'verifies attribute class' do
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        edge = TestEdgeMixinC.new(test_attribute: 'test_value')
        edge.test_attribute.class.name
      end
      expect(result).to eq('String')
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        begin
          TestEdgeMixinC.new(test_attribute: 10)
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        begin
          edge = TestEdgeMixinC.new
          edge.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if attribute is_a' do
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, is_a: Enumerable
        end
        edge = TestEdgeMixinC.new(test_attribute: ['test_value'])
        edge.test_attribute.class.name
      end
      expect(result).to eq('Array')
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          TestEdgeMixinC.new(test_attribute: 10)
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          edge = TestEdgeMixinC.new
          edge.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'uses a default value' do
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, default: 10
        end
        edge = TestEdgeMixinC.new
        edge.test_attribute
      end
      expect(result).to eq(10)
    end

    it 'reports a change' do
      # usually edge data is taken from the store, thus instantiating a edge with attributes declares them as changed
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute
        end
        edge = TestEdgeMixinC.new(test_attribute: 10)
        edge.changed?
      end
      expect(result).to be(true)
    end

    it 'converts to cid' do
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute
        end
        edge = TestEdgeMixinC.new(id: 10)
        edge.to_cid
      end
      expect(result).to eq(['TestEdgeMixinC', '10'])
    end

    it 'can validate a attribute' do
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        edge = TestEdgeMixinC.new
        edge.valid_attribute?(:test_attribute, 10)
      end
      expect(result).to eq(false)
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        edge = TestEdgeMixinC.new
        edge.valid_attribute?(:test, '10')
      end
      expect(result).to eq(false)
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        edge = TestEdgeMixinC.new
        edge.valid_attribute?(:test_attribute, '10')
      end
      expect(result).to eq(true)
    end

    it 'converts to transport' do
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute
        end
        class TestNode < LucidData::Document::Base
        end
        node1 = TestNode.new(id: 11)
        node2 = TestNode.new(id: 12)
        edge = TestEdgeMixinC.new(id: 10, from: node1, to: node2, test_attribute: 'test')
        edge.to_transport.to_n
      end
      expect(result).to eq("generic_edges" => { "TestEdgeMixinC" => {"10"=>{"from" => ["TestNode", "11"], "to" => ["TestNode", "12"],
                                                                 "attributes"=>{"test_attribute" => "test"}}}})
    end
  end
end
