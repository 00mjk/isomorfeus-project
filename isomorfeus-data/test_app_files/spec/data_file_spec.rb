require 'spec_helper'

RSpec.describe 'LucidData::File' do
  context 'on the server' do
    it 'can instantiate a file by inheritance' do
      result = on_server do
        class TestFileBase < LucidData::File::Base
          attribute :test_attribute
        end
        file = TestFileBase.new(key: 1, attributes: { test_attribute: 'test_value' })
        file.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'can instantiate a file by mixin' do
      result = on_server do
        class TestFileMixin
          include LucidData::File::Mixin
          attribute :test_attribute
        end
        file = TestFileMixin.new(key: 2, attributes: { test_attribute: 'test_value' })
        file.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'verifies attribute class' do
      result = on_server do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, class: String
        end
        file = TestFileMixinC.new(key: 3, attributes: { test_attribute: 'test_value' })
        file.test_attribute.class.name
      end
      expect(result).to eq('String')
      result = on_server do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, class: String
        end
        begin
          TestFileMixinC.new(key: 4, attributes: { test_attribute: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, class: String
        end
        begin
          file = TestFileMixinC.new(key: 5)
          file.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if attribute is_a' do
      result = on_server do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, is_a: Enumerable
        end
        file = TestFileMixinC.new(key: 6, attributes: { test_attribute: ['test_value'] })
        file.test_attribute.class.name
      end
      expect(result).to eq('Array')
      result = on_server do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          TestFileMixinC.new(key: 7, attributes: { test_attribute: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          file = TestFileMixinC.new(key: 7)
          file.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'has a meta attribute' do
      result = on_server do
        class TestFileMixinC1 < LucidData::File::Base
        end
        file = TestFileMixinC1.new(key: 6, attributes: { meta: { test: 'test_value' }})
        file.meta[:test]
      end
      expect(result).to eq('test_value')
    end

    it 'reports a attribute change' do
      result = on_server do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute
        end
        file = TestFileMixinC.new(key: 9, attributes: { test_attribute: 10 })
        file.changed?
      end
      expect(result).to be(false)
      result = on_server do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute
        end
        file = TestFileMixinC.new(key: 10, attributes: { test_attribute: 10 })
        file.test_attribute = 20
        file.changed?
      end
      expect(result).to be(true)
    end

    it 'can create a simple file' do
      result = on_server do
        file = SimpleFile.create(key: '123')
        file.one
      end
      expect(result).to eq('123')
    end

    it 'can load a simple file' do
      result = on_server do
        file = SimpleFile.load(key: '123')
        file.one
      end
      expect(result).to eq('123')
    end

    it 'can destroy a simple file' do
      result = on_server do
        SimpleFile.destroy(key: '123')
      end
      expect(result).to eq(true)
    end

    it 'can save a simple file' do
      result = on_server do
        file = SimpleFile.load(key: '123')
        file.one = 'changed'
        before_changed = file.changed?
        file.save
        [file.one, before_changed, file.changed?]
      end
      expect(result).to eq(['changed', true, false])
    end

    it 'converts to sid' do
      result = on_server do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute
        end
        file = TestFileMixinC.new(key: 11)
        file.to_sid
      end
      expect(result).to eq(['TestFileMixinC', '11'])
    end

    it 'can validate a attribute' do
      result = on_server do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, class: String
        end
        TestFileMixinC.valid_attribute?(:test_attribute, 10)
      end
      expect(result).to eq(false)
      result = on_server do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, class: String
        end
        TestFileMixinC.valid_attribute?(:test, '10')
      end
      expect(result).to eq(false)
      result = on_server do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, class: String
        end
        TestFileMixinC.valid_attribute?(:test_attribute, '10')
      end
      expect(result).to eq(true)
    end

    it 'converts to transport' do
      result = on_server do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute
        end
        file = TestFileMixinC.new(key: 12, attributes: { test_attribute: 'test'})
        file.to_transport
      end
      expect(result).to eq("TestFileMixinC"=>{"12"=>{"attributes" => { "test_attribute" => "test"}}})
    end

    it 'keeps server_only attribute on server' do
      result = on_server do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, server_only: true
        end
        file = TestFileMixinC.new(key: 13, attributes: { test_attribute: 'test' })
        file.to_transport
      end
      expect(result).to eq("TestFileMixinC"=>{"13"=>{"attributes" =>{}}})
    end
  end

  context 'on the client' do
    before :each do
      @doc = visit('/')
    end

    it 'can instantiate a file by inheritance' do
      result = @doc.evaluate_ruby do
        class TestFileBase < LucidData::File::Base
          attribute :test_attribute
        end
        file = TestFileBase.new(key: 14, attributes: { test_attribute: 'test_value' })
        file.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'can instantiate a file by mixin' do
      result = @doc.evaluate_ruby do
        class TestFileMixin
          include LucidData::File::Mixin
          attribute :test_attribute
        end
        file = TestFileMixin.new(key: 15, attributes: { test_attribute: 'test_value' })
        file.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'verifies attribute class' do
      result = @doc.evaluate_ruby do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, class: String
        end
        file = TestFileMixinC.new(key: 16, attributes: { test_attribute: 'test_value' })
        file.test_attribute.class.name
      end
      expect(result).to eq('String')
      result = @doc.evaluate_ruby do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, class: String
        end
        begin
          TestFileMixinC.new(key: 17, attributes: { test_attribute: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @doc.evaluate_ruby do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, class: String
        end
        begin
          file = TestFileMixinC.new(key: 18)
          file.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if attribute is_a' do
      result = @doc.evaluate_ruby do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, is_a: Enumerable
        end
        file = TestFileMixinC.new(key: 19, attributes: { test_attribute: ['test_value'] })
        file.test_attribute.class.name
      end
      expect(result).to eq('Array')
      result = @doc.evaluate_ruby do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          TestFileMixinC.new(key: 20, attributes: { test_attribute: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @doc.evaluate_ruby do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          file = TestFileMixinC.new(key: 21)
          file.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'reports a change' do
      result = @doc.evaluate_ruby do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute
        end
        file = TestFileMixinC.new(key: 23, attributes: { test_attribute: 10 })
        file.changed?
      end
      expect(result).to be(false)
      result = @doc.evaluate_ruby do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute
        end
        file = TestFileMixinC.new(key: 23, attributes: { test_attribute: 10 })
        file.test_attribute = 20
        file.changed?
      end
      expect(result).to be(true)
    end

    it 'can load a simple file' do
      result = @doc.await_ruby do
        SimpleFile.promise_load(key: '123').then do |file|
          file.one
        end
      end
      expect(result).to eq('123')
    end

    it 'can destroy a simple file' do
      result = @doc.await_ruby do
        SimpleFile.promise_destroy(key: '123').then { |result| result }
      end
      expect(result).to eq(true)
    end

    it 'can save a simple file' do
      result = @doc.await_ruby do
        SimpleFile.promise_load(key: '123').then do |file|
          file.one = 'changed'
          before_changed = file.changed?
          file.promise_save.then do |file|
            [file.one, before_changed, file.changed?]
          end
        end
      end
      expect(result).to eq(['changed', true, false])
    end

    it 'converts to sid' do
      result = @doc.evaluate_ruby do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute
        end
        file = TestFileMixinC.new(key: 24)
        file.to_sid
      end
      expect(result).to eq(['TestFileMixinC', '24'])
    end

    it 'can validate a attribute' do
      result = @doc.evaluate_ruby do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, class: String
        end
        TestFileMixinC.valid_attribute?(:test_attribute, 10)
      end
      expect(result).to eq(false)
      result = @doc.evaluate_ruby do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, class: String
        end
        TestFileMixinC.valid_attribute?(:test, '10')
      end
      expect(result).to eq(false)
      result = @doc.evaluate_ruby do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute, class: String
        end
        TestFileMixinC.valid_attribute?(:test_attribute, '10')
      end
      expect(result).to eq(true)
    end

    it 'converts to transport' do
      result = @doc.evaluate_ruby do
        class TestFileMixinC < LucidData::File::Base
          attribute :test_attribute
        end
        file = TestFileMixinC.new(key: 28, attributes: { test_attribute: 'test' })
        file.to_transport.to_n
      end
      expect(result).to eq("TestFileMixinC" => {"28"=>{"attributes" => {"test_attribute" => "test"}}})
    end

    it 'can load' do
      result = @doc.await_ruby do
        SimpleFile.promise_load(key: '123456').then do |file|
          file.one
        end
      end
      expect(result).to eq('123456')
    end

    #it 'can query' do
      #
    #end

    it 'can save' do
      result = @doc.await_ruby do
        file = SimpleFile.new(key: '123456')
        file.one = 654321
        file.promise_save.then do |file|
          file.one
        end
      end
      expect(result).to eq(654321)
    end

    #it 'can destroy' do
      #
    #end
  end
end
