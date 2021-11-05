require 'spec_helper'

RSpec.describe 'LucidData::Document' do
  context 'on the server' do
    it 'can instantiate a document by inheritance' do
      result = on_server do
        class TestDocumentBase < LucidData::Document::Base
          field :test_field
        end
        document = TestDocumentBase.new(key: 1, fields: { test_field: 'test_value' })
        document.test_field
      end
      expect(result).to eq('test_value')
    end

    it 'can instantiate a document by mixin' do
      result = on_server do
        class TestDocumentMixin
          include LucidData::Document::Mixin
          field :test_field
        end
        document = TestDocumentMixin.new(key: 2, fields: { test_field: 'test_value' })
        document.test_field
      end
      expect(result).to eq('test_value')
    end

    it 'reports a change' do
      result = on_server do
        class TestDocumentMixinC < LucidData::Document::Base
          field :test_field
        end
        document = TestDocumentMixinC.new(key: 9, fields: { test_field: 10 })
        document.changed?
      end
      expect(result).to be(false)
      result = on_server do
        class TestDocumentMixinC < LucidData::Document::Base
          field :test_field
        end
        document = TestDocumentMixinC.new(key: 10, fields: { test_field: 10 })
        document.test_field = 20
        document.changed?
      end
      expect(result).to be(true)
    end

    it 'can load a simple document' do
      result = on_server do
        document = SimpleDocument.create(fields: { one: '123' })
        document = SimpleDocument.load(key: document.key)
        document.one
      end
      expect(result).to eq('123')
    end

    it 'can destroy a simple document' do
      result = on_server do
        document = SimpleDocument.create(fields: { one: '123' })
        SimpleDocument.destroy(key: document.key)
      end
      expect(result).to eq(true)
    end

    it 'can save a simple document' do
      result = on_server do
        document = SimpleDocument.create(fields: { one: '123' })
        document = SimpleDocument.load(key: document.key)
        document.one = 'changed'
        before_changed = document.changed?
        document.save
        [document.one, before_changed, document.changed?]
      end
      expect(result).to eq(['changed', true, false])
    end

    it 'converts to sid' do
      result = on_server do
        class TestDocumentMixinC < LucidData::Document::Base
          field :test_field
        end
        document = TestDocumentMixinC.new(key: 11)
        document.sid
      end
      expect(result).to eq(['TestDocumentMixinC', '11'])
    end

    it 'converts to transport' do
      result = on_server do
        class TestDocumentMixinC < LucidData::Document::Base
          field :test_field
        end
        document = TestDocumentMixinC.new(key: 12, fields: { test_field: 'test'})
        document.to_transport
      end
      expect(result).to eq("TestDocumentMixinC"=>{"12"=>{"fields" => { "test_field" => "test"}}})
    end
  end

  context 'on the client' do
    before :each do
      @doc = visit('/')
    end

    it 'can instantiate a document by inheritance' do
      result = @doc.evaluate_ruby do
        class TestDocumentBase < LucidData::Document::Base
          field :test_field
        end
        document = TestDocumentBase.new(key: 14, fields: { test_field: 'test_value' })
        document.test_field
      end
      expect(result).to eq('test_value')
    end

    it 'can instantiate a document by mixin' do
      result = @doc.evaluate_ruby do
        class TestDocumentMixin
          include LucidData::Document::Mixin
          field :test_field
        end
        document = TestDocumentMixin.new(key: 15, fields: { test_field: 'test_value' })
        document.test_field
      end
      expect(result).to eq('test_value')
    end

    it 'reports a change' do
      result = @doc.evaluate_ruby do
        class TestDocumentMixinC < LucidData::Document::Base
          field :test_field
        end
        document = TestDocumentMixinC.new(key: 23, fields: { test_field: 10 })
        document.changed?
      end
      expect(result).to be(false)
      result = @doc.evaluate_ruby do
        class TestDocumentMixinC < LucidData::Document::Base
          field :test_field
        end
        document = TestDocumentMixinC.new(key: 23, fields: { test_field: 10 })
        document.test_field = 20
        document.changed?
      end
      expect(result).to be(true)
    end

    it 'can load a simple document' do
      result = @doc.await_ruby do
        SimpleDocument.promise_create(fields: { one: '123' }).then do |doc|
          SimpleDocument.promise_load(key: doc.key).then do |document|
            document.one
          end
        end
      end
      expect(result).to eq('123')
    end

    it 'can destroy a simple document' do
      result = @doc.await_ruby do
        SimpleDocument.promise_create(fields: { one: '123' }).then do |doc|
          SimpleDocument.promise_destroy(key: doc.key).then { |result| result }
        end
      end
      expect(result).to eq(true)
    end

    it 'can save a simple document' do
      result = @doc.await_ruby do
        SimpleDocument.promise_create(fields: { one: '123' }).then do |doc|
          SimpleDocument.promise_load(key: doc.key).then do |document|
            document.one = 'changed'
            before_changed = document.changed?
            document.promise_save.then do |document|
              [document.one, before_changed, document.changed?]
            end
          end
        end
      end
      expect(result).to eq(['changed', true, false])
    end

    it 'converts to sid' do
      result = @doc.evaluate_ruby do
        class TestDocumentMixinC < LucidData::Document::Base
          field :test_field
        end
        document = TestDocumentMixinC.new(key: 24)
        document.sid
      end
      expect(result).to eq(['TestDocumentMixinC', '24'])
    end

    it 'converts to transport' do
      result = @doc.evaluate_ruby do
        class TestDocumentMixinC < LucidData::Document::Base
          field :test_field
        end
        document = TestDocumentMixinC.new(key: 28, fields: { test_field: 'test' })
        document.to_transport.to_n
      end
      expect(result).to eq("TestDocumentMixinC" => {"28"=>{"fields" => {"test_field" => "test"}}})
    end

    it 'can load' do
      result = @doc.await_ruby do
        SimpleDocument.promise_create(fields: { one: '123456' }).then do |doc|
          SimpleDocument.promise_load(key: doc.key).then do |document|
            document.one
          end
        end
      end
      expect(result).to eq('123456')
    end

    #it 'can query' do
      #
    #end

    it 'can save and converts field to string' do
      result = @doc.await_ruby do
        SimpleDocument.promise_create(fields: { one: '123' }).then do |doc|
          document = SimpleDocument.new(key: doc.key)
          document.one = 654321
          document.promise_save.then do |document|
            document.one
          end
        end
      end
      expect(result).to eq('654321')
    end

    #it 'can destroy' do
      #
    #end
  end
end