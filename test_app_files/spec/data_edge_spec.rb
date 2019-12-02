require 'spec_helper'

RSpec.describe 'LucidData::Edge' do
  context 'on the server' do
    it 'can instantiate a document by inheritance' do
      result = on_server do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeBase < LucidData::Edge::Base
          attribute :test_attribute
        end
        document = TestEdgeBase.new(key: 1, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: 'test_value' })
        document.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'can instantiate a document by mixin' do
      result = on_server do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixin
          include LucidData::Edge::Mixin
          attribute :test_attribute
        end
        document = TestEdgeMixin.new(key: 2, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: 'test_value' })
        document.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'verifies attribute class' do
      result = on_server do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        document = TestEdgeMixinC.new(key: 3, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: 'test_value' })
        document.test_attribute.class.name
      end
      expect(result).to eq('String')
      result = on_server do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        begin
          TestEdgeMixinC.new(key: 4, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        begin
          document = TestEdgeMixinC.new(key: 5, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2))
          document.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if attribute is_a' do
      result = on_server do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, is_a: Enumerable
        end
        document = TestEdgeMixinC.new(key: 6, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: ['test_value'] })
        document.test_attribute.class.name
      end
      expect(result).to eq('Array')
      result = on_server do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          TestEdgeMixinC.new(key: 7, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          document = TestEdgeMixinC.new(key: 7, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2))
          document.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'reports a change' do
      result = on_server do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute
        end
        document = TestEdgeMixinC.new(key: 9, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: 10 })
        document.changed?
      end
      expect(result).to be(false)
      result = on_server do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute
        end
        document = TestEdgeMixinC.new(key: 10, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: 10 })
        document.test_attribute = 20
        document.changed?
      end
      expect(result).to be(true)
    end

    it 'converts to sid' do
      result = on_server do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute
        end
        document = TestEdgeMixinC.new(key: 11, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2))
        document.to_sid
      end
      expect(result).to eq(['TestEdgeMixinC', '11'])
    end

    it 'can validate a attribute' do
      result = on_server do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        TestEdgeMixinC.valid_attribute?(:test_attribute, 10)
      end
      expect(result).to eq(false)
      result = on_server do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        TestEdgeMixinC.valid_attribute?(:test, '10')
      end
      expect(result).to eq(false)
      result = on_server do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        TestEdgeMixinC.valid_attribute?(:test_attribute, '10')
      end
      expect(result).to eq(true)
    end

    it 'converts to transport' do
      result = on_server do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute
        end
        document = TestEdgeMixinC.new(key: 12, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: 'test'})
        document.to_transport
      end
      expect(result).to eq("TestEdgeMixinC" => {"12"=>{ "attributes"=>{"test_attribute" => "test"},
                                                        "from" => ["TestDocumentBase", "1"],
                                                        "to" => ["TestDocumentBase", "2"]}})
    end

    it 'keeps server_only attribute on server' do
      result = on_server do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, server_only: true
        end
        document = TestEdgeMixinC.new(key: 13, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: 'test' })
        document.to_transport
      end
      expect(result).to eq("TestEdgeMixinC" => {"13"=>{ "attributes"=>{},
                                                        "from" => ["TestDocumentBase", "1"],
                                                        "to" => ["TestDocumentBase", "2"]}})
    end
  end

  context 'on the client' do
    before :each do
      @doc = visit('/')
    end

    it 'can instantiate a document by inheritance' do
      result = @doc.evaluate_ruby do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeBase < LucidData::Edge::Base
          attribute :test_attribute
        end
        document = TestEdgeBase.new(key: 14, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: 'test_value' })
        document.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'can instantiate a document by mixin' do
      result = @doc.evaluate_ruby do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixin
          include LucidData::Edge::Mixin
          attribute :test_attribute
        end
        document = TestEdgeMixin.new(key: 15, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: 'test_value' })
        document.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'verifies attribute class' do
      result = @doc.evaluate_ruby do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        document = TestEdgeMixinC.new(key: 16, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: 'test_value' })
        document.test_attribute.class.name
      end
      expect(result).to eq('String')
      result = @doc.evaluate_ruby do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        begin
          TestEdgeMixinC.new(key: 17, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @doc.evaluate_ruby do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        begin
          document = TestEdgeMixinC.new(key: 18, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2))
          document.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if attribute is_a' do
      result = @doc.evaluate_ruby do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, is_a: Enumerable
        end
        document = TestEdgeMixinC.new(key: 19, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: ['test_value'] })
        document.test_attribute.class.name
      end
      expect(result).to eq('Array')
      result = @doc.evaluate_ruby do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          TestEdgeMixinC.new(key: 20, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @doc.evaluate_ruby do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          document = TestEdgeMixinC.new(key: 21, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2))
          document.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'reports a change' do
      result = @doc.evaluate_ruby do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute
        end
        document = TestEdgeMixinC.new(key: 23, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: 10 })
        document.changed?
      end
      expect(result).to be(true)
      result = @doc.evaluate_ruby do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute
        end
        document = TestEdgeMixinC.new(key: 23, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: 10 })
        document.test_attribute = 20
        document.changed?
      end
      expect(result).to be(true)
    end

    it 'converts to sid' do
      result = @doc.evaluate_ruby do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute
        end
        document = TestEdgeMixinC.new(key: 24, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2))
        document.to_sid
      end
      expect(result).to eq(['TestEdgeMixinC', '24'])
    end

    it 'can validate a attribute' do
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        TestEdgeMixinC.valid_attribute?(:test_attribute, 10)
      end
      expect(result).to eq(false)
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        TestEdgeMixinC.valid_attribute?(:test, '10')
      end
      expect(result).to eq(false)
      result = @doc.evaluate_ruby do
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute, class: String
        end
        TestEdgeMixinC.valid_attribute?(:test_attribute, '10')
      end
      expect(result).to eq(true)
    end

    it 'converts to transport' do
      result = @doc.evaluate_ruby do
        class TestDocumentBase < LucidData::Document::Base; end
        class TestEdgeMixinC < LucidData::Edge::Base
          attribute :test_attribute
        end
        document = TestEdgeMixinC.new(key: 28, from: TestDocumentBase.new(key: 1), to: TestDocumentBase.new(key: 2), attributes: { test_attribute: 'test' })
        document.to_transport.to_n
      end
      expect(result).to eq("TestEdgeMixinC" => {"28"=>{ "attributes"=>{"test_attribute" => "test"},
                                                        "from" => ["TestDocumentBase", "1"],
                                                        "to" => ["TestDocumentBase", "2"]}})
    end
  end
end
