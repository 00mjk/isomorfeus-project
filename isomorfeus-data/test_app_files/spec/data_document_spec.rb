require 'spec_helper'

RSpec.describe 'LucidDocument' do
  context 'on the server' do
    it 'can instantiate a document by inheritance' do
      result = on_server do
        class TestDocumentBase < LucidDocument::Base
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
          include LucidDocument::Mixin
          field :test_field
        end
        document = TestDocumentMixin.new(key: 2, fields: { test_field: 'test_value' })
        document.test_field
      end
      expect(result).to eq('test_value')
    end

    it 'verifies field class' do
      result = on_server do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field, class: String
        end
        document = TestDocumentMixinC.new(key: 3, fields: { test_field: 'test_value' })
        document.test_field.class.name
      end
      expect(result).to eq('String')
      result = on_server do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field, class: String
        end
        begin
          TestDocumentMixinC.new(key: 4, fields: { test_field: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field, class: String
        end
        begin
          document = TestDocumentMixinC.new(key: 5)
          document.test_field = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if field is_a' do
      result = on_server do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field, is_a: Enumerable
        end
        document = TestDocumentMixinC.new(key: 6, fields: { test_field: ['test_value'] })
        document.test_field.class.name
      end
      expect(result).to eq('Array')
      result = on_server do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field, is_a: Enumerable
        end
        begin
          TestDocumentMixinC.new(key: 7, fields: { test_field: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field, is_a: Enumerable
        end
        begin
          document = TestDocumentMixinC.new(key: 7)
          document.test_field = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'reports a change' do
      result = on_server do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field
        end
        document = TestDocumentMixinC.new(key: 9, fields: { test_field: 10 })
        document.changed?
      end
      expect(result).to be(false)
      result = on_server do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field
        end
        document = TestDocumentMixinC.new(key: 10, fields: { test_field: 10 })
        document.test_field = 20
        document.changed?
      end
      expect(result).to be(true)
    end

    it 'can create and load a simple document' do
      result = on_server do
        document = SimpleDocument.create(fields: { one: '123' })
        document = SimpleDocument.load(key: document.key)
        document.one
      end
      expect(result).to eq('123')
    end

    it 'can promise_create and promise_load a simple document' do
      on_server do
        document = SimpleDocument.new(key: '1234', fields: { one: '123' })
        document.promise_create
      end
      result = on_server do
        document = SimpleDocument.promise_load(key: '1234').value
        document.one
      end
      expect(result).to eq('123')
    end

    it 'can create and load a simple document with a given key' do
      result = on_server do
        key = '42424242-abcdefg'
        document = SimpleDocument.create(key: key, fields: { one: '123' })
        document = SimpleDocument.load(key: key)
        [document.one, document.key]
      end
      expect(result).to eq(['123', '42424242-abcdefg'])
    end

    it 'returns nil if a simple document doesnt exist when loading by key' do
      result = on_server do
        SimpleDocument.load(key: '555555555555')
      end
      expect(result).to be(nil)
    end

    it 'can destroy a simple document' do
      result = on_server do
        document = SimpleDocument.create(fields: { one: '123' })
        SimpleDocument.destroy(key: document.key)
      end
      expect(result).to eq(true)
    end

    it 'can promise_destroy a simple document' do
      on_server do
        document = SimpleDocument.new(key: '123456')
        document.create
      end
      result = on_server do
        SimpleDocument.promise_destroy(key: '123456').value
      end
      expect(result).to eq(true)
    end

    it 'can reload a simple document' do
      on_server do
        document = SimpleDocument.new(key: '1234567')
        document.create
      end
      result = on_server do
        document = SimpleDocument.load(key: '1234567')
        document.one = 'changed'
        before_changed = document.changed?
        document.reload
        [document.one, before_changed, document.changed?]
      end
      expect(result).to eq(['', true, false])
    end

    it 'can promise_reload a simple document' do
      on_server do
        document = SimpleDocument.new(key: '12345678', fields: { one: '123' })
        document.create
      end
      result = on_server do
        document = SimpleDocument.load(key: '12345678')
        document.one = 'changed'
        before_changed = document.changed?
        document.promise_reload
        [document.one, before_changed, document.changed?]
      end
      expect(result).to eq(['123', true, false])
    end

    it 'can save a simple document' do
      result = on_server do
        document = SimpleDocument.create(fields: { one: '123' })
        document = SimpleDocument.load(key: document.key)
        document.one = 'changed'
        after_changed = document.changed?
        document.save
        [document.one, after_changed, document.changed?]
      end
      expect(result).to eq(['changed', true, false])
    end

    it 'can promise_save a simple document' do
      on_server do
        document = SimpleDocument.new(key: '123456789')
        document.create
      end
      result = on_server do
        document = SimpleDocument.load(key: '123456789')
        document.one = 'changed'
        before_changed = document.changed?
        document.promise_save
        [document.one, before_changed, document.changed?]
      end
      expect(result).to eq(['changed', true, false])
    end

    it 'converts to sid' do
      result = on_server do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field
        end
        document = TestDocumentMixinC.new(key: 11)
        document.sid
      end
      expect(result).to eq(['TestDocumentMixinC', '11'])
    end

    it 'converts to transport' do
      result = on_server do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field
        end
        document = TestDocumentMixinC.new(key: 12, fields: { test_field: 'test'})
        document.to_transport
      end
      expect(result).to eq("TestDocumentMixinC"=>{"12"=>{"fields" => { "test_field" => "test"}}})
    end

    it 'can search for documents' do
      result = on_server do
        SimpleDocument.create(key: '1234567890', fields: { one: 'one two three' })
        SimpleDocument.create(fields: { one: 'two three four' })
        SimpleDocument.create(fields: { one: 'three four five' })
        top_docs = SimpleDocument.search('one:"one"')
        [top_docs.size, top_docs.first.one]
      end
      expect(result).to eq([1, 'one two three'])
    end
  end

  context 'on the client' do
    before :each do
      @page = visit('/')
    end

    it 'can instantiate a document by inheritance' do
      result = @page.eval_ruby do
        class TestDocumentBase < LucidDocument::Base
          field :test_field
        end
        document = TestDocumentBase.new(key: 14, fields: { test_field: 'test_value' })
        document.test_field
      end
      expect(result).to eq('test_value')
    end

    it 'can instantiate a document by mixin' do
      result = @page.eval_ruby do
        class TestDocumentMixin
          include LucidDocument::Mixin
          field :test_field
        end
        document = TestDocumentMixin.new(key: 15, fields: { test_field: 'test_value' })
        document.test_field
      end
      expect(result).to eq('test_value')
    end

    it 'verifies field class' do
      result = @page.eval_ruby do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field, class: String
        end
        document = TestDocumentMixinC.new(key: 16, fields: { test_field: 'test_value' })
        document.test_field.class.name
      end
      expect(result).to eq('String')
      result = @page.eval_ruby do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field, class: String
        end
        begin
          TestDocumentMixinC.new(key: 17, fields: { test_field: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @page.eval_ruby do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field, class: String
        end
        begin
          document = TestDocumentMixinC.new(key: 18)
          document.test_field = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if field is_a' do
      result = @page.eval_ruby do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field, is_a: Enumerable
        end
        document = TestDocumentMixinC.new(key: 19, fields: { test_field: ['test_value'] })
        document.test_field.class.name
      end
      expect(result).to eq('Array')
      result = @page.eval_ruby do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field, is_a: Enumerable
        end
        begin
          TestDocumentMixinC.new(key: 20, fields: { test_field: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @page.eval_ruby do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field, is_a: Enumerable
        end
        begin
          document = TestDocumentMixinC.new(key: 21)
          document.test_field = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'reports a change' do
      result = @page.eval_ruby do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field
        end
        document = TestDocumentMixinC.new(key: 23, fields: { test_field: 10 })
        document.changed?
      end
      expect(result).to be(false)
      result = @page.eval_ruby do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field
        end
        document = TestDocumentMixinC.new(key: 23, fields: { test_field: 10 })
        document.test_field = 20
        document.changed?
      end
      expect(result).to be(true)
    end

    it 'can execute load for a simple document' do
      result = @page.await_ruby do
        SimpleDocument.promise_create(key: '234', fields: { one: '123' }).then do |document|
          SimpleDocument.load(key: '234').one
        end
      end
      expect(result).to eq('123')
    end

    it 'can execute create for a simple document' do
      result = @page.eval_ruby do
        SimpleDocument.create(key: '234', fields: { one: '123' }).one
      end
      expect(result).to eq('123')
    end

    it 'can promise_create and promise_load a simple document' do
      result = @page.await_ruby do
        SimpleDocument.promise_create(fields: { one: '123' }).then do |doc|
          SimpleDocument.promise_load(key: doc.key).then do |document|
            document.one
          end
        end
      end
      expect(result).to eq('123')
    end

    it 'can destroy a simple document' do
      result = @page.await_ruby do
        SimpleDocument.promise_create(key: '2345', fields: { one: '123' }).then do |document|
          SimpleDocument.destroy(key: '2345')
        end
      end
      expect(result).to eq(true)
    end

    it 'can promise_destroy a simple document' do
      result = @page.await_ruby do
        SimpleDocument.promise_create(fields: { one: '123' }).then do |doc|
          SimpleDocument.promise_destroy(key: doc.key).then { |result| result }
        end
      end
      expect(result).to eq(true)
    end

    it 'can call reload on a simple document' do
      result = @page.await_ruby do
        SimpleDocument.promise_create(key: '2345678', fields: { one: '123' }).then do |document|
          SimpleDocument.promise_load(key: '2345678').then do |document|
            document.one = 'changed'
            document.reload
            document.one
          end
        end
      end
      expect(['changed', '123']).to include(result)
    end

    it 'can promise_reload a simple document' do
      result = @page.await_ruby do
        SimpleDocument.promise_create(key: '23456789', fields: { one: '123' }).then do |document|
          SimpleDocument.promise_load(key: '23456789').then do |document|
            document.one = 'changed'
            before_changed = document.changed?
            document.promise_reload.then do |document|
              [document.one, before_changed, document.changed?]
            end
          end
        end
      end
      expect(result).to eq(['123', true, false])
    end

    it 'can promise_save a simple document' do
      result = @page.await_ruby do
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

    it 'can save a simple document' do
     key =  @page.await_ruby do
        SimpleDocument.promise_create(fields: { one: '123' }).then do |doc|
          SimpleDocument.promise_load(key: doc.key).then do |document|
            document.one = 'changed'
            document.save
            document.key
          end
        end
      end
      sleep 5 # needs a better way
      result = SimpleDocument.load(key: key).one
      expect(result).to eq('changed')
    end

    it 'can promise_save a simple document' do
      result = @page.await_ruby do
        SimpleDocument.promise_create(key: '2345678901', fields: { one: '123' }).then do |document|
          SimpleDocument.promise_load(key: '2345678901').then do |document|
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
      result = @page.eval_ruby do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field
        end
        document = TestDocumentMixinC.new(key: 24)
        document.sid
      end
      expect(result).to eq(['TestDocumentMixinC', '24'])
    end

    it 'converts to transport' do
      result = @page.eval_ruby do
        class TestDocumentMixinC < LucidDocument::Base
          field :test_field
        end
        document = TestDocumentMixinC.new(key: 28, fields: { test_field: 'test' })
        document.to_transport.to_n
      end
      expect(result).to eq("TestDocumentMixinC" => {"28"=>{"fields" => {"test_field" => "test"}}})
    end

    it 'can load' do
      result = @page.await_ruby do
        SimpleDocument.promise_create(fields: { one: '123456' }).then do |doc|
          SimpleDocument.promise_load(key: doc.key).then do |document|
            document.one
          end
        end
      end
      expect(result).to eq('123456')
    end

    it 'can save and does not convert numeric field to string' do
      result = @page.await_ruby do
        SimpleDocument.promise_create(fields: { one: '123' }).then do |doc|
          document = SimpleDocument.new(key: doc.key)
          document.one = 654321
          document.promise_save.then do |document|
            document.one
          end
        end
      end
      expect(result).to eq(654321)
    end
  end
end
