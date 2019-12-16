require 'spec_helper'

RSpec.describe 'LucidEdge' do
  context 'on the server' do
    it 'can instantiate a edge by inheritance' do
      result = on_server do
        class TestEdgeBase < LucidData::Edge::Base
          attribute :test_attribute
        end
        edge = TestEdgeBase.new(key: 1, attributes: { test_attribute: 'test_value' })
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
        edge = TestEdgeMixin.new(key: 2, attributes: { test_attribute: 'test_value' })
        edge.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'verifies attribute class' do
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        edge = TestEdgeMixinC.new(key: 3, attributes: { test_attribute: 'test_value' })
        edge.test_attribute.class.name
      end
      expect(result).to eq('String')
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        begin
          TestEdgeMixinC.new(key: 4, attributes: { test_attribute: 10 })
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
        edge = TestEdgeMixinC.new(key: 5, attributes: { test_attribute: ['test_value']})
        edge.test_attribute.class.name
      end
      expect(result).to eq('Array')
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          TestEdgeMixinC.new(key: 6, attributes: { test_attribute: 10 })
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
        edge = TestEdgeMixinC.new(key: 7)
        edge.test_attribute
      end
      expect(result).to eq(10)
    end

    it 'reports a change' do
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute
        end
        edge = TestEdgeMixinC.new(key: 8, attributes: { test_attribute: 10 })
        edge.changed?
      end
      expect(result).to be(false)
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute
        end
        edge = TestEdgeMixinC.new(key: 9, attributes: { test_attribute: 10 })
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
        edge = TestEdgeMixinC.new(key: 10)
        edge.to_cid
      end
      expect(result).to eq(['TestEdgeMixinC', '10'])
    end

    it 'can validate a attribute' do
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        edge = TestEdgeMixinC.new(key: 11)
        edge.valid_attribute?(:test_attribute, 10)
      end
      expect(result).to eq(false)
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        edge = TestEdgeMixinC.new(key: 12)
        edge.valid_attribute?(:test, '10')
      end
      expect(result).to eq(false)
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        edge = TestEdgeMixinC.new(key: 13)
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
        node1 = TestNode.new(key: 14)
        node2 = TestNode.new(key: 15)
        edge = TestEdgeMixinC.new(key: 16, from: node1, to: node2, attributes: { test_attribute: 'test' })
        edge.to_transport
      end
      expect(result).to eq("TestEdgeMixinC"=>{"16"=>{"from"=>["TestNode","14"],"to"=>["TestNode","15"],
                                                               "attributes"=>{"test_attribute"=>"test"}}})
    end

    it 'keeps server_only attribute on server' do
      result = on_server do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, server_only: true
        end
        node = TestEdgeMixinC.new(key: 17, id: 10, test_attribute: 'test')
        node.to_transport
      end
      expect(result).to eq("TestEdgeMixinC"=>{"17"=>{"from"=>nil,"to"=>nil,"attributes"=>{}}})
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
        edge = TestEdgeBase.new(key: 18, attributes: { test_attribute: 'test_value' })
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
        edge = TestEdgeMixin.new(key: 19, attributes: { test_attribute: 'test_value' })
        edge.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'verifies attribute class' do
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        edge = TestEdgeMixinC.new(key: 20, attributes: { test_attribute: 'test_value' })
        edge.test_attribute.class.name
      end
      expect(result).to eq('String')
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        begin
          TestEdgeMixinC.new(key: 21, attributes: { test_attribute: 10 })
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
          edge = TestEdgeMixinC.new(key: 22)
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
        edge = TestEdgeMixinC.new(key: 23, attributes: { test_attribute: ['test_value'] })
        edge.test_attribute.class.name
      end
      expect(result).to eq('Array')
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          TestEdgeMixinC.new(key: 24, attributes: { test_attribute: 10 })
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
          edge = TestEdgeMixinC.new(key: 25)
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
        edge = TestEdgeMixinC.new(key: 26)
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
        edge = TestEdgeMixinC.new(key: 27, attributes: { test_attribute: 10 })
        edge.changed?
      end
      expect(result).to be(true)
    end

    it 'converts to cid' do
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute
        end
        edge = TestEdgeMixinC.new(key: 28)
        edge.to_cid
      end
      expect(result).to eq(['TestEdgeMixinC', '28'])
    end

    it 'can validate a attribute' do
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        edge = TestEdgeMixinC.new(key: 29)
        edge.valid_attribute?(:test_attribute, 10)
      end
      expect(result).to eq(false)
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        edge = TestEdgeMixinC.new(key: 30)
        edge.valid_attribute?(:test, '10')
      end
      expect(result).to eq(false)
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        edge = TestEdgeMixinC.new(key: 31)
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
        node1 = TestNode.new(key: 32, id: 11)
        node2 = TestNode.new(key: 33, id: 12)
        edge = TestEdgeMixinC.new(key: 34, id: 10, from: node1, to: node2, test_attribute: 'test')
        edge.to_transport.to_n
      end
      expect(result).to eq("TestEdgeMixinC" => {"34"=>{"from" => ["TestNode", "32"], "to" => ["TestNode", "33"],
                                                                 "attributes"=>{"test_attribute" => "test"}}})
    end
  end
end
