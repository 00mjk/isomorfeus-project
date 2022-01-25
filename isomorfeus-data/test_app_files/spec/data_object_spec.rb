require 'spec_helper'

RSpec.describe 'LucidObject' do
  context 'on the server' do
    it 'can instantiate a object by inheritance' do
      result = on_server do
        class TestObjectBase < LucidObject::Base
          attribute :test_attribute
        end
        object = TestObjectBase.new(key: 1, attributes: { test_attribute: 'test_value' })
        object.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'can instantiate a object by mixin' do
      result = on_server do
        class TestObjectMixin
          include LucidObject::Mixin
          attribute :test_attribute
        end
        object = TestObjectMixin.new(key: 2, attributes: { test_attribute: 'test_value' })
        object.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'verifies attribute class' do
      result = on_server do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, class: String
        end
        object = TestObjectMixinC.new(key: 3, attributes: { test_attribute: 'test_value' })
        object.test_attribute.class.name
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
          object = TestObjectMixinC.new(key: 5)
          object.test_attribute = 10
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
        object = TestObjectMixinC.new(key: 6, attributes: { test_attribute: ['test_value'] })
        object.test_attribute.class.name
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
          object = TestObjectMixinC.new(key: 7)
          object.test_attribute = 10
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
        object = TestObjectMixinC.new(key: 9, attributes: { test_attribute: 10 })
        object.changed?
      end
      expect(result).to be(false)
      result = on_server do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute
        end
        object = TestObjectMixinC.new(key: 10, attributes: { test_attribute: 10 })
        object.test_attribute = 20
        object.changed?
      end
      expect(result).to be(true)
    end

    it 'can create and load a simple object' do
      on_server do
        obj = SimpleObject.new(key: '123')
        obj.one = '123'
        obj.create
      end
      result = on_server do
        object = SimpleObject.load(key: '123')
        object.one
      end
      expect(result).to eq('123')
    end

    it 'can promise_create and promise_load a simple object' do
      on_server do
        obj = SimpleObject.new(key: '1234')
        obj.one = '1234'
        obj.promise_create
      end
      result = on_server do
        object = SimpleObject.promise_load(key: '1234').value
        object.one
      end
      expect(result).to eq('1234')
    end

    it 'returns nil if a simple object doesnt exist when loading by key' do
      result = on_server do
        SimpleObject.load(key: '555555555555')
      end
      expect(result).to be(nil)
    end

    it 'can destroy a simple object' do
      on_server do
        obj = SimpleObject.new(key: '12345')
        obj.create
      end
      result = on_server do
        SimpleObject.destroy(key: '12345')
      end
      expect(result).to eq(true)
    end

    it 'can promise_destroy a simple object' do
      on_server do
        obj = SimpleObject.new(key: '123456')
        obj.create
      end
      result = on_server do
        SimpleObject.promise_destroy(key: '123456').value
      end
      expect(result).to eq(true)
    end

    it 'can reload a simple object' do
      on_server do
        obj = SimpleObject.new(key: '1234567')
        obj.create
      end
      result = on_server do
        object = SimpleObject.load(key: '1234567')
        object.one = 'changed'
        before_changed = object.changed?
        object.reload
        [object.one, before_changed, object.changed?]
      end
      expect(result).to eq([nil, true, false])
    end

    it 'can promise_reload a simple object' do
      on_server do
        obj = SimpleObject.new(key: '1234567')
        obj.create
      end
      result = on_server do
        object = SimpleObject.load(key: '1234567')
        object.one = 'changed'
        before_changed = object.changed?
        object.promise_reload
        [object.one, before_changed, object.changed?]
      end
      expect(result).to eq([nil, true, false])
    end

    it 'can save a simple object' do
      on_server do
        obj = SimpleObject.new(key: '12345678')
        obj.create
      end
      result = on_server do
        object = SimpleObject.load(key: '12345678')
        object.one = 'changed'
        before_changed = object.changed?
        object.save
        [object.one, before_changed, object.changed?]
      end
      expect(result).to eq(['changed', true, false])
    end

    it 'can promise_save a simple object' do
      on_server do
        obj = SimpleObject.new(key: '123456789')
        obj.create
      end
      result = on_server do
        object = SimpleObject.load(key: '123456789')
        object.one = 'changed'
        before_changed = object.changed?
        object.promise_save
        [object.one, before_changed, object.changed?]
      end
      expect(result).to eq(['changed', true, false])
    end

    it 'converts to sid' do
      result = on_server do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute
        end
        object = TestObjectMixinC.new(key: 11)
        object.sid
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
        object = TestObjectMixinC.new(key: 12, attributes: { test_attribute: 'test'})
        object.to_transport
      end
      expect(result).to eq("TestObjectMixinC"=>{"12"=>{"attributes" => { "test_attribute" => "test"}}})
    end

    it 'keeps server_only attribute on server' do
      result = on_server do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, server_only: true
        end
        object = TestObjectMixinC.new(key: 13, attributes: { test_attribute: 'test' })
        object.to_transport
      end
      expect(result).to eq("TestObjectMixinC"=>{"13"=>{"attributes" =>{}}})
    end

    it 'can search for objects' do
      result = on_server do
        SimpleObject.create(attributes: { two: 'two', three: 'one two three' })
        SimpleObject.create(attributes: { two: 'one', three: 'two three four' })
        SimpleObject.create(attributes: { two: 'three', three: 'three four five' })
        top_objs_v = SimpleObject.search(:two, "one")
        top_objs_t = SimpleObject.search(:three, '"two"')
        [top_objs_v.size, top_objs_v.first&.two, top_objs_t.size]
      end
      expect(result).to eq([1, 'one', 2])
    end
  end

  context 'on the client' do
    before :each do
      @page = visit('/')
    end

    it 'can instantiate a object by inheritance' do
      result = @page.eval_ruby do
        class TestObjectBase < LucidObject::Base
          attribute :test_attribute
        end
        object = TestObjectBase.new(key: 14, attributes: { test_attribute: 'test_value' })
        object.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'can instantiate a object by mixin' do
      result = @page.eval_ruby do
        class TestObjectMixin
          include LucidObject::Mixin
          attribute :test_attribute
        end
        object = TestObjectMixin.new(key: 15, attributes: { test_attribute: 'test_value' })
        object.test_attribute
      end
      expect(result).to eq('test_value')
    end

    it 'verifies attribute class' do
      result = @page.eval_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, class: String
        end
        object = TestObjectMixinC.new(key: 16, attributes: { test_attribute: 'test_value' })
        object.test_attribute.class.name
      end
      expect(result).to eq('String')
      result = @page.eval_ruby do
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
      result = @page.eval_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, class: String
        end
        begin
          object = TestObjectMixinC.new(key: 18)
          object.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if attribute is_a' do
      result = @page.eval_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, is_a: Enumerable
        end
        object = TestObjectMixinC.new(key: 19, attributes: { test_attribute: ['test_value'] })
        object.test_attribute.class.name
      end
      expect(result).to eq('Array')
      result = @page.eval_ruby do
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
      result = @page.eval_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, is_a: Enumerable
        end
        begin
          object = TestObjectMixinC.new(key: 21)
          object.test_attribute = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'reports a change' do
      result = @page.eval_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute
        end
        object = TestObjectMixinC.new(key: 23, attributes: { test_attribute: 10 })
        object.changed?
      end
      expect(result).to be(false)
      result = @page.eval_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute
        end
        object = TestObjectMixinC.new(key: 23, attributes: { test_attribute: 10 })
        object.test_attribute = 20
        object.changed?
      end
      expect(result).to be(true)
    end

    it 'can execute load for a simple object' do
      result = @page.await_ruby do
        SimpleObject.promise_create(key: '234', attributes: { one: '123' }).then do |object|
          SimpleObject.load(key: '234').one
        end
      end
      expect(result).to eq('123')
    end

    it 'can execute create for a simple object' do
      result = @page.eval_ruby do
        SimpleObject.create(key: '234', attributes: { one: '123' }).one
      end
      expect(result).to eq('123')
    end

    it 'can promise_ceate and promise_load a simple object' do
      result = @page.await_ruby do
        SimpleObject.promise_create(key: '2345', attributes: { one: '123' }).then do |object|
          SimpleObject.promise_load(key: '2345').then do |object|
            object.one
          end
        end
      end
      expect(result).to eq('123')
    end

    it 'can destroy a simple object' do
      result = @page.await_ruby do
        SimpleObject.promise_create(key: '23456', attributes: { one: '123' }).then do |object|
          SimpleObject.destroy(key: '23456')
        end
      end
      expect(result).to eq(true)
    end

    it 'can promise_destroy a simple object' do
      result = @page.await_ruby do
        SimpleObject.promise_create(key: '234567', attributes: { one: '123' }).then do |object|
          SimpleObject.promise_destroy(key: '234567').then { |result| result }
        end
      end
      expect(result).to eq(true)
    end

    it 'can call reload on a simple object' do
      result = @page.await_ruby do
        SimpleObject.promise_create(key: '2345678', attributes: { one: '123' }).then do |object|
          SimpleObject.promise_load(key: '2345678').then do |object|
            object.one = 'changed'
            object.reload
            object.one
          end
        end
      end
      expect(['changed', '123']).to include(result)
    end

    it 'can promise_reload a simple object' do
      result = @page.await_ruby do
        SimpleObject.promise_create(key: '23456789', attributes: { one: '123' }).then do |object|
          SimpleObject.promise_load(key: '23456789').then do |object|
            object.one = 'changed'
            before_changed = object.changed?
            object.promise_reload.then do |object|
              [object.one, before_changed, object.changed?]
            end
          end
        end
      end
      expect(result).to eq(['123', true, false])
    end

    it 'can save a simple object' do
      @page.await_ruby do
        SimpleObject.promise_create(key: '234567890', attributes: { one: '123' }).then do |obj|
          SimpleObject.promise_load(key: '234567890').then do |object|
            obj.one = 'changed'
            obj.save
          end
        end
      end
      sleep 5 # needs a better way
      result = SimpleObject.load(key: '234567890').one
      expect(result).to eq('changed')
    end

    it 'can promise_save a simple object' do
      result = @page.await_ruby do
        SimpleObject.promise_create(key: '2345678901', attributes: { one: '123' }).then do |object|
          SimpleObject.promise_load(key: '2345678901').then do |object|
            object.one = 'changed'
            before_changed = object.changed?
            object.promise_save.then do |object|
              [object.one, before_changed, object.changed?]
            end
          end
        end
      end
      expect(result).to eq(['changed', true, false])
    end

    it 'converts to sid' do
      result = @page.eval_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute
        end
        object = TestObjectMixinC.new(key: 24)
        object.sid
      end
      expect(result).to eq(['TestObjectMixinC', '24'])
    end

    it 'can validate a attribute' do
      result = @page.eval_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, class: String
        end
        TestObjectMixinC.valid_attribute?(:test_attribute, 10)
      end
      expect(result).to eq(false)
      result = @page.eval_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, class: String
        end
        TestObjectMixinC.valid_attribute?(:test, '10')
      end
      expect(result).to eq(false)
      result = @page.eval_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute, class: String
        end
        TestObjectMixinC.valid_attribute?(:test_attribute, '10')
      end
      expect(result).to eq(true)
    end

    it 'converts to transport' do
      result = @page.eval_ruby do
        class TestObjectMixinC < LucidObject::Base
          attribute :test_attribute
        end
        object = TestObjectMixinC.new(key: 28, attributes: { test_attribute: 'test' })
        object.to_transport.to_n
      end
      expect(result).to eq("TestObjectMixinC" => {"28"=>{"attributes" => {"test_attribute" => "test"}}})
    end
  end
end
