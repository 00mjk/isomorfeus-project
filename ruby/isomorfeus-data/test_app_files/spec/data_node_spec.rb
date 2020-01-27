require 'spec_helper'

RSpec.describe 'LucidData::Document' do
  context 'on the server' do
    it 'can instantiate a document by inheritance' do
      result = on_server do
        class TestDocumentBase < LucidData::Document::Base
          attribute :test_attribute
        end
        document = TestDocumentBase.new(key: 1, attributes: { test_attribute: 'test_value' })
        document.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'can instantiate a document by mixin' do
      result = on_server do
        class TestDocumentMixin
          include LucidData::Document::Mixin
          attribute :test_attribute
        end
        document = TestDocumentMixin.new(key: 2, attributes: { test_attribute: 'test_value' })
        document.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'verifies attribute class' do
      result = on_server do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, class: String
        end
        document = TestDocumentMixinC.new(key: 3, attributes: { test_attribute: 'test_value' })
        document.test_attribute.class.name
      end
      expect(result).to eq('String')
      result = on_server do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, class: String
        end
        begin
          TestDocumentMixinC.new(key: 4, attributes: { test_attribute: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, class: String
        end
        begin
          document = TestDocumentMixinC.new(key: 5)
          document.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if attribute is_a' do
      result = on_server do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, is_a: Enumerable
        end
        document = TestDocumentMixinC.new(key: 6, attributes: { test_attribute: ['test_value'] })
        document.test_attribute.class.name
      end
      expect(result).to eq('Array')
      result = on_server do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          TestDocumentMixinC.new(key: 7, attributes: { test_attribute: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          document = TestDocumentMixinC.new(key: 7)
          document.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'reports a change' do
      result = on_server do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute
        end
        document = TestDocumentMixinC.new(key: 9, attributes: { test_attribute: 10 })
        document.changed?
      end
      expect(result).to be(false)
      result = on_server do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute
        end
        document = TestDocumentMixinC.new(key: 10, attributes: { test_attribute: 10 })
        document.test_attribute = 20
        document.changed?
      end
      expect(result).to be(true)
    end

    it 'can load a simple node' do
      result = on_server do
        node = SimpleNode.load(key: '123')
        node.one
      end
      expect(result).to eq('123')
    end

    it 'can destroy a simple node' do
      result = on_server do
        SimpleNode.destroy(key: '123')
      end
      expect(result).to eq(true)
    end

    it 'can save a simple node' do
      result = on_server do
        node = SimpleNode.load(key: '123')
        node.one = 'changed'
        before_changed = node.changed?
        node.save
        [node.one, before_changed, node.changed?]
      end
      expect(result).to eq(['changed', true, false])
    end

    it 'converts to sid' do
      result = on_server do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute
        end
        document = TestDocumentMixinC.new(key: 11)
        document.to_sid
      end
      expect(result).to eq(['TestDocumentMixinC', '11'])
    end

    it 'can validate a attribute' do
      result = on_server do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, class: String
        end
        TestDocumentMixinC.valid_attribute?(:test_attribute, 10)
      end
      expect(result).to eq(false)
      result = on_server do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, class: String
        end
        TestDocumentMixinC.valid_attribute?(:test, '10')
      end
      expect(result).to eq(false)
      result = on_server do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, class: String
        end
        TestDocumentMixinC.valid_attribute?(:test_attribute, '10')
      end
      expect(result).to eq(true)
    end

    it 'converts to transport' do
      result = on_server do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute
        end
        document = TestDocumentMixinC.new(key: 12, attributes: { test_attribute: 'test'})
        document.to_transport
      end
      expect(result).to eq("TestDocumentMixinC"=>{"12"=>{"attributes" => { "test_attribute" => "test"}}})
    end

    it 'keeps server_only attribute on server' do
      result = on_server do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, server_only: true
        end
        document = TestDocumentMixinC.new(key: 13, attributes: { test_attribute: 'test' })
        document.to_transport
      end
      expect(result).to eq("TestDocumentMixinC"=>{"13"=>{"attributes" =>{}}})
    end
  end

  context 'on the client' do
    before :each do
      @doc = visit('/')
    end

    it 'can instantiate a document by inheritance' do
      result = @doc.evaluate_ruby do
        class TestDocumentBase < LucidData::Document::Base
          attribute :test_attribute
        end
        document = TestDocumentBase.new(key: 14, attributes: { test_attribute: 'test_value' })
        document.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'can instantiate a document by mixin' do
      result = @doc.evaluate_ruby do
        class TestDocumentMixin
          include LucidData::Document::Mixin
          attribute :test_attribute
        end
        document = TestDocumentMixin.new(key: 15, attributes: { test_attribute: 'test_value' })
        document.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'verifies attribute class' do
      result = @doc.evaluate_ruby do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, class: String
        end
        document = TestDocumentMixinC.new(key: 16, attributes: { test_attribute: 'test_value' })
        document.test_attribute.class.name
      end
      expect(result).to eq('String')
      result = @doc.evaluate_ruby do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, class: String
        end
        begin
          TestDocumentMixinC.new(key: 17, attributes: { test_attribute: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @doc.evaluate_ruby do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, class: String
        end
        begin
          document = TestDocumentMixinC.new(key: 18)
          document.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if attribute is_a' do
      result = @doc.evaluate_ruby do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, is_a: Enumerable
        end
        document = TestDocumentMixinC.new(key: 19, attributes: { test_attribute: ['test_value'] })
        document.test_attribute.class.name
      end
      expect(result).to eq('Array')
      result = @doc.evaluate_ruby do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          TestDocumentMixinC.new(key: 20, attributes: { test_attribute: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @doc.evaluate_ruby do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          document = TestDocumentMixinC.new(key: 21)
          document.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'reports a change' do
      result = @doc.evaluate_ruby do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute
        end
        document = TestDocumentMixinC.new(key: 23, attributes: { test_attribute: 10 })
        document.changed?
      end
      expect(result).to be(false)
      result = @doc.evaluate_ruby do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute
        end
        document = TestDocumentMixinC.new(key: 23, attributes: { test_attribute: 10 })
        document.test_attribute = 20
        document.changed?
      end
      expect(result).to be(true)
    end

    it 'can load a simple node' do
      result = @doc.await_ruby do
        SimpleNode.promise_load(key: '123').then do |node|
          node.one
        end
      end
      expect(result).to eq('123')
    end

    it 'can destroy a simple node' do
      result = @doc.await_ruby do
        SimpleNode.promise_destroy(key: '123').then { |result| result }
      end
      expect(result).to eq(true)
    end

    it 'can save a simple node' do
      result = @doc.await_ruby do
        SimpleNode.promise_load(key: '123').then do |node|
          node.one = 'changed'
          before_changed = node.changed?
          node.promise_save.then do |node|
            [node.one, before_changed, node.changed?]
          end
        end
      end
      expect(result).to eq(['changed', true, false])
    end

    it 'converts to sid' do
      result = @doc.evaluate_ruby do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute
        end
        document = TestDocumentMixinC.new(key: 24)
        document.to_sid
      end
      expect(result).to eq(['TestDocumentMixinC', '24'])
    end

    it 'can validate a attribute' do
      result = @doc.evaluate_ruby do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, class: String
        end
        TestDocumentMixinC.valid_attribute?(:test_attribute, 10)
      end
      expect(result).to eq(false)
      result = @doc.evaluate_ruby do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, class: String
        end
        TestDocumentMixinC.valid_attribute?(:test, '10')
      end
      expect(result).to eq(false)
      result = @doc.evaluate_ruby do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute, class: String
        end
        TestDocumentMixinC.valid_attribute?(:test_attribute, '10')
      end
      expect(result).to eq(true)
    end

    it 'converts to transport' do
      result = @doc.evaluate_ruby do
        class TestDocumentMixinC < LucidData::Document::Base
          attribute :test_attribute
        end
        document = TestDocumentMixinC.new(key: 28, attributes: { test_attribute: 'test' })
        document.to_transport.to_n
      end
      expect(result).to eq("TestDocumentMixinC" => {"28"=>{"attributes" => {"test_attribute" => "test"}}})
    end
  end
end
