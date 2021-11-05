require 'spec_helper'

RSpec.describe 'LucidObject' do
  context 'on the server' do
    it 'can instantiate a node by inheritance' do
      result = on_server do
        class TestObjectBase < LucidObject::Base
          attribute :test_attribute
        end
        node = TestObjectBase.new(key: 1, attributes: { test_attribute: 'test_value' })
        node.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'can instantiate a node by mixin' do
      result = on_server do
        class TestObjectMixin
          include LucidObject::Mixin
          attribute :test_attribute
        end
        node = TestObjectMixin.new(key: 2, attributes: { test_attribute: 'test_value' })
        node.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'verifies attribute class' do
      result = on_server do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, class: String
        end
        node = TestObjectMixinC.new(key: 3, attributes: { test_attribute: 'test_value' })
        node.test_attribute.class.name
      end
      expect(result).to eq('String')
      result = on_server do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, class: String
        end
        begin
          TestObjectMixinC.new(key: 4, attributes: { test_attribute: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, class: String
        end
        begin
          node = TestObjectMixinC.new(key: 5)
          node.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if attribute is_a' do
      result = on_server do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, is_a: Enumerable
        end
        node = TestObjectMixinC.new(key: 6, attributes: { test_attribute: ['test_value'] })
        node.test_attribute.class.name
      end
      expect(result).to eq('Array')
      result = on_server do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          TestObjectMixinC.new(key: 7, attributes: { test_attribute: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          node = TestObjectMixinC.new(key: 7)
          node.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'reports a change' do
      result = on_server do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute
        end
        node = TestObjectMixinC.new(key: 9, attributes: { test_attribute: 10 })
        node.changed?
      end
      expect(result).to be(false)
      result = on_server do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute
        end
        node = TestObjectMixinC.new(key: 10, attributes: { test_attribute: 10 })
        node.test_attribute = 20
        node.changed?
      end
      expect(result).to be(true)
    end

    it 'can load a simple node' do
      on_server do
        obj = SimpleObject.new(key: '123')
        obj.one = '123'
        obj.create
      end
      result = on_server do
        node = SimpleObject.load(key: '123')
        node.one
      end
      expect(result).to eq('123')
    end

    it 'can destroy a simple node' do
      on_server do
        obj = SimpleObject.new(key: '1234')
        obj.create
      end
      result = on_server do
        SimpleObject.destroy(key: '1234')
      end
      expect(result).to eq(true)
    end

    it 'can save a simple node' do
      on_server do
        obj = SimpleObject.new(key: '12345')
        obj.create
      end
      result = on_server do
        node = SimpleObject.load(key: '12345')
        node.one = 'changed'
        before_changed = node.changed?
        node.save
        [node.one, before_changed, node.changed?]
      end
      expect(result).to eq(['changed', true, false])
    end

    it 'converts to sid' do
      result = on_server do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute
        end
        node = TestObjectMixinC.new(key: 11)
        node.sid
      end
      expect(result).to eq(['TestObjectMixinC', '11'])
    end

    it 'can validate a attribute' do
      result = on_server do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, class: String
        end
        TestObjectMixinC.valid_attribute?(:test_attribute, 10)
      end
      expect(result).to eq(false)
      result = on_server do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, class: String
        end
        TestObjectMixinC.valid_attribute?(:test, '10')
      end
      expect(result).to eq(false)
      result = on_server do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, class: String
        end
        TestObjectMixinC.valid_attribute?(:test_attribute, '10')
      end
      expect(result).to eq(true)
    end

    it 'converts to transport' do
      result = on_server do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute
        end
        node = TestObjectMixinC.new(key: 12, attributes: { test_attribute: 'test'})
        node.to_transport
      end
      expect(result).to eq("TestObjectMixinC"=>{"12"=>{"attributes" => { "test_attribute" => "test"}}})
    end

    it 'keeps server_only attribute on server' do
      result = on_server do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, server_only: true
        end
        node = TestObjectMixinC.new(key: 13, attributes: { test_attribute: 'test' })
        node.to_transport
      end
      expect(result).to eq("TestObjectMixinC"=>{"13"=>{"attributes" =>{}}})
    end
  end

  context 'on the client' do
    before :each do
      @doc = visit('/')
    end

    it 'can instantiate a node by inheritance' do
      result = @doc.evaluate_ruby do
        class TestObjectBase < LucidObject::Base
          attribute :test_attribute
        end
        node = TestObjectBase.new(key: 14, attributes: { test_attribute: 'test_value' })
        node.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'can instantiate a node by mixin' do
      result = @doc.evaluate_ruby do
        class TestObjectMixin
          include LucidObject::Mixin
          attribute :test_attribute
        end
        node = TestObjectMixin.new(key: 15, attributes: { test_attribute: 'test_value' })
        node.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'verifies attribute class' do
      result = @doc.evaluate_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, class: String
        end
        node = TestObjectMixinC.new(key: 16, attributes: { test_attribute: 'test_value' })
        node.test_attribute.class.name
      end
      expect(result).to eq('String')
      result = @doc.evaluate_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, class: String
        end
        begin
          TestObjectMixinC.new(key: 17, attributes: { test_attribute: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @doc.evaluate_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, class: String
        end
        begin
          node = TestObjectMixinC.new(key: 18)
          node.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if attribute is_a' do
      result = @doc.evaluate_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, is_a: Enumerable
        end
        node = TestObjectMixinC.new(key: 19, attributes: { test_attribute: ['test_value'] })
        node.test_attribute.class.name
      end
      expect(result).to eq('Array')
      result = @doc.evaluate_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          TestObjectMixinC.new(key: 20, attributes: { test_attribute: 10 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @doc.evaluate_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          node = TestObjectMixinC.new(key: 21)
          node.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'reports a change' do
      result = @doc.evaluate_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute
        end
        node = TestObjectMixinC.new(key: 23, attributes: { test_attribute: 10 })
        node.changed?
      end
      expect(result).to be(false)
      result = @doc.evaluate_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute
        end
        node = TestObjectMixinC.new(key: 23, attributes: { test_attribute: 10 })
        node.test_attribute = 20
        node.changed?
      end
      expect(result).to be(true)
    end

    it 'can load a simple node' do
      result = @doc.await_ruby do
        SimpleObject.promise_create(key: '234', attributes: { one: '123' }).then do |node|
          SimpleObject.promise_load(key: '234').then do |node|
            node.one
          end
        end
      end
      expect(result).to eq('123')
    end

    it 'can destroy a simple node' do
      result = @doc.await_ruby do
        SimpleObject.promise_create(key: '2345', attributes: { one: '123' }).then do |node|
          SimpleObject.promise_destroy(key: '2345').then { |result| result }
        end
      end
      expect(result).to eq(true)
    end

    it 'can save a simple node' do
      result = @doc.await_ruby do
        SimpleObject.promise_create(key: '23456', attributes: { one: '123' }).then do |node|
          SimpleObject.promise_load(key: '23456').then do |node|
            node.one = 'changed'
            before_changed = node.changed?
            node.promise_save.then do |node|
              [node.one, before_changed, node.changed?]
            end
          end
        end
      end
      expect(result).to eq(['changed', true, false])
    end

    it 'converts to sid' do
      result = @doc.evaluate_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute
        end
        node = TestObjectMixinC.new(key: 24)
        node.sid
      end
      expect(result).to eq(['TestObjectMixinC', '24'])
    end

    it 'can validate a attribute' do
      result = @doc.evaluate_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, class: String
        end
        TestObjectMixinC.valid_attribute?(:test_attribute, 10)
      end
      expect(result).to eq(false)
      result = @doc.evaluate_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, class: String
        end
        TestObjectMixinC.valid_attribute?(:test, '10')
      end
      expect(result).to eq(false)
      result = @doc.evaluate_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, class: String
        end
        TestObjectMixinC.valid_attribute?(:test_attribute, '10')
      end
      expect(result).to eq(true)
    end

    it 'converts to transport' do
      result = @doc.evaluate_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute
        end
        node = TestObjectMixinC.new(key: 28, attributes: { test_attribute: 'test' })
        node.to_transport.to_n
      end
      expect(result).to eq("TestObjectMixinC" => {"28"=>{"attributes" => {"test_attribute" => "test"}}})
    end

    it 'can load' do
      result = @doc.await_ruby do
        SimpleObject.promise_create(key: '234567', attributes: { one: '123456' }).then do |node|
          SimpleObject.promise_load(key: '234567').then do |node|
            node.one
          end
        end
      end
      expect(result).to eq('123456')
    end

    #it 'can query' do
      #
    #end

    it 'can save' do
      result = @doc.await_ruby do
        node = SimpleObject.new(key: '123456')
        node.one = 654321
        node.promise_save.then do |node|
          node.one
        end
      end
      expect(result).to eq(654321)
    end

    #it 'can destroy' do
      #
    #end
  end
end
