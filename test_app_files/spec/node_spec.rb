require 'spec_helper'

RSpec.describe 'LucidNode' do
  context 'on the server' do
    it 'can instantiate a node by inheritance' do
      result = on_server do
        class TestNodeBase < LucidGenericNode::Base
          attribute :test_attribute
        end
        node = TestNodeBase.new(test_attribute: 'test_value')
        node.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'can instantiate a node by mixin' do
      result = on_server do
        class TestNodeMixin
          include LucidGenericNode::Mixin
          attribute :test_attribute
        end
        node = TestNodeMixin.new(test_attribute: 'test_value')
        node.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'verifies attribute class' do
      result = on_server do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, class: String
        end
        node = TestNodeMixinC.new(test_attribute: 'test_value')
        node.test_attribute.class.name
      end
      expect(result).to eq('String')
      result = on_server do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, class: String
        end
        begin
          TestNodeMixinC.new(test_attribute: 10)
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, class: String
        end
        begin
          node = TestNodeMixinC.new
          node.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if attribute is_a' do
      result = on_server do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, is_a: Enumerable
        end
        node = TestNodeMixinC.new(test_attribute: ['test_value'])
        node.test_attribute.class.name
      end
      expect(result).to eq('Array')
      result = on_server do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          TestNodeMixinC.new(test_attribute: 10)
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          node = TestNodeMixinC.new
          node.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'uses a default value' do
      result = on_server do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, default: 10
        end
        node = TestNodeMixinC.new
        node.test_attribute
      end
      expect(result).to eq(10)
    end

    it 'reports a change' do
      result = on_server do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute
        end
        node = TestNodeMixinC.new(test_attribute: 10)
        node.changed?
      end
      expect(result).to be(false)
      result = on_server do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute
        end
        node = TestNodeMixinC.new(test_attribute: 10)
        node.test_attribute = 20
        node.changed?
      end
      expect(result).to be(true)
    end

    it 'converts to cid' do
      result = on_server do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute
        end
        node = TestNodeMixinC.new(id: 10)
        node.to_cid
      end
      expect(result).to eq(['TestNodeMixinC', '10'])
    end

    it 'can validate a attribute' do
      result = on_server do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, class: String
        end
        node = TestNodeMixinC.new
        node.valid_attribute?(:test_attribute, 10)
      end
      expect(result).to eq(false)
      result = on_server do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, class: String
        end
        node = TestNodeMixinC.new
        node.valid_attribute?(:test, '10')
      end
      expect(result).to eq(false)
      result = on_server do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, class: String
        end
        node = TestNodeMixinC.new
        node.valid_attribute?(:test_attribute, '10')
      end
      expect(result).to eq(true)
    end

    it 'converts to transport' do
      result = on_server do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute
        end
        node = TestNodeMixinC.new(id: 10, test_attribute: 'test')
        node.to_transport
      end
      expect(result).to eq("generic_nodes"=>{"TestNodeMixinC"=>{"10"=>{"attributes"=>{"test_attribute" => "test"}}}})
    end

    it 'keeps server_only attribute on server' do
      result = on_server do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, server_only: true
        end
        node = TestNodeMixinC.new(id: 10, test_attribute: 'test')
        node.to_transport
      end
      expect(result).to eq("generic_nodes"=>{"TestNodeMixinC"=>{"10"=>{"attributes"=>{}}}})
    end
  end

  context 'on the client' do
    before :each do
      @doc = visit('/')
    end

    it 'can instantiate a node by inheritance' do
      result = @doc.evaluate_ruby do
        class TestNodeBase < LucidGenericNode::Base
          attribute :test_attribute
        end
        node = TestNodeBase.new(test_attribute: 'test_value')
        node.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'can instantiate a node by mixin' do
      result = @doc.evaluate_ruby do
        class TestNodeMixin
          include LucidGenericNode::Mixin
          attribute :test_attribute
        end
        node = TestNodeMixin.new(test_attribute: 'test_value')
        node.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'verifies attribute class' do
      result = @doc.evaluate_ruby do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, class: String
        end
        node = TestNodeMixinC.new(test_attribute: 'test_value')
        node.test_attribute.class.name
      end
      expect(result).to eq('String')
      result = @doc.evaluate_ruby do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, class: String
        end
        begin
          TestNodeMixinC.new(test_attribute: 10)
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @doc.evaluate_ruby do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, class: String
        end
        begin
          node = TestNodeMixinC.new
          node.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if attribute is_a' do
      result = @doc.evaluate_ruby do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, is_a: Enumerable
        end
        node = TestNodeMixinC.new(test_attribute: ['test_value'])
        node.test_attribute.class.name
      end
      expect(result).to eq('Array')
      result = @doc.evaluate_ruby do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          TestNodeMixinC.new(test_attribute: 10)
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @doc.evaluate_ruby do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          node = TestNodeMixinC.new
          node.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'uses a default value' do
      result = @doc.evaluate_ruby do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, default: 10
        end
        node = TestNodeMixinC.new
        node.test_attribute
      end
      expect(result).to eq(10)
    end

    it 'reports a change' do
      # usually node data is taken from the store, thus instantiating a node with attributes declares them as changed
      result = @doc.evaluate_ruby do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute
        end
        node = TestNodeMixinC.new(test_attribute: 10)
        node.changed?
      end
      expect(result).to be(true)
    end

    it 'converts to cid' do
      result = @doc.evaluate_ruby do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute
        end
        node = TestNodeMixinC.new(id: 10)
        node.to_cid
      end
      expect(result).to eq(['TestNodeMixinC', '10'])
    end

    it 'can validate a attribute' do
      result = @doc.evaluate_ruby do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, class: String
        end
        node = TestNodeMixinC.new
        node.valid_attribute?(:test_attribute, 10)
      end
      expect(result).to eq(false)
      result = @doc.evaluate_ruby do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, class: String
        end
        node = TestNodeMixinC.new
        node.valid_attribute?(:test, '10')
      end
      expect(result).to eq(false)
      result = @doc.evaluate_ruby do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute, class: String
        end
        node = TestNodeMixinC.new
        node.valid_attribute?(:test_attribute, '10')
      end
      expect(result).to eq(true)
    end

    it 'converts to transport' do
      result = @doc.evaluate_ruby do
        class TestNodeMixinC < LucidGenericNode::Base
          attribute :test_attribute
        end
        node = TestNodeMixinC.new(id: 10, test_attribute: 'test')
        node.to_transport.to_n
      end
      expect(result).to eq("generic_nodes" => {"TestNodeMixinC" => {"10"=>{"attributes"=>{"test_attribute" => "test"}}}})
    end
  end
end
