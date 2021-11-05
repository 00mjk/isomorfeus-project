require 'spec_helper'

RSpec.describe 'LucidQuery' do
  context 'on the server' do
    it 'can do inheritance' do
      result = on_server do
        class TestQueryBase < LucidQuery::Base
          prop :test_prop

          execute_query do
          end
        end
        TestQueryBase.to_s.split('::').last
      end
      expect(result).to eq('TestQueryBase')
    end

    it 'can do mixin' do
      result = on_server do
        class TestQueryMixin
          include LucidQuery::Mixin
          prop :test_prop

          execute_query do
          end
        end
        TestQueryMixin.to_s.split('::').last
      end
      expect(result).to eq('TestQueryMixin')
    end

    it 'verifies prop class' do
      result = on_server do
        class TestNode < LucidObject::Base
          attribute :test
        end
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop, class: String

          execute_query do
            { node: TestNode.new(key: 1, attributes: { test: props.test_prop }) }
          end
        end
        query_result = TestQueryMixinC.execute(test_prop: 'testing')
        query_result.node.test
      end
      expect(result).to eq('testing')
      result = on_server do
        class TestNode < LucidObject::Base
          attribute :test
        end
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop, class: String

          execute_query do
            { node: TestNode.new(key: 1, attributes: { test: props.test_prop }) }
          end
        end
        begin
          query_result = TestQueryMixinC.execute(test_prop: 1)
          query_result.node.test
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestNode < LucidObject::Base
          attribute :test
        end
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop, class: String

          execute_query do
            { node: TestNode.new(key: 1, attributes: { test: props.test_prop }) }
          end
        end
        begin
          query_result = TestQueryMixinC.execute()
          query_result.node.test
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if prop is_a' do
      result = on_server do
        class TestNode < LucidObject::Base
          attribute :test
        end
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop, is_a: Enumerable

          execute_query do
            { node: TestNode.new(key: 1, attributes: { test: props.test_prop }) }
          end
        end
        query_result = TestQueryMixinC.execute(test_prop: ['test_value'])
        query_result.node.test.class.name
      end
      expect(result).to eq('Array')
      result = on_server do
        class TestNode < LucidObject::Base
          attribute :test
        end
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop, is_a: Enumerable

          execute_query do
            { node: TestNode.new(key: 1, attributes: { test: props.test_prop }) }
          end
        end
        begin
          query_result = TestQueryMixinC.execute(test_prop: 10)
          query_result.node.test.class.name
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestNode < LucidObject::Base
          attribute :test
        end
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop, is_a: Enumerable

          execute_query do
            { node: TestNode.new(key: 1, attributes: { test: props.test_prop }) }
          end
        end
        begin
          query_result = TestQueryMixinC.execute()
          query_result.node.test.class.name
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'converts result to transport' do
      result = on_server do
        class TestNode < LucidObject::Base
          attribute :test
        end
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop

          execute_query do
            { node: TestNode.new(key: 1, attributes: { test: props.test_prop }) }
          end
        end
        query_result = TestQueryMixinC.execute( test_prop: 123 )
        query_result.instance_variable_set(:@key, '1')
        query_result.to_transport
      end
      expect(result).to eq("LucidQueryResult" => {"1"=>{'node'=>["TestNode", "1"]}})
    end

    it 'can validate a prop' do
      result = on_server do
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop, class: String
        end
        TestQueryMixinC.valid_prop?(:test_prop, 10)
      end
      expect(result).to eq(false)
      result = on_server do
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop, class: String
        end
        TestQueryMixinC.valid_prop?(:test, '10')
      end
      expect(result).to eq(false)
      result = on_server do
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop, class: String
        end
        TestQueryMixinC.valid_prop?(:test_prop, '10')
      end
      expect(result).to eq(true)
    end

    it 'can execute a simple query' do
      result = on_server do
        query_result = SimpleQuery.execute(simple_prop: 'simple_text')
        query_result.node.one
      end
      expect(result).to eq('simple_text')
    end
  end

  context 'on the client' do
    before :each do
      @doc = visit('/')
    end

    it 'can do inheritance' do
      result = @doc.evaluate_ruby do
        class TestQueryBase < LucidQuery::Base
          prop :test_prop

          execute_query do
          end
        end
        TestQueryBase.to_s.split('::').last
      end
      expect(result).to eq('TestQueryBase')
    end

    it 'can do mixin' do
      result = @doc.evaluate_ruby do
        class TestQueryMixin
          include LucidQuery::Mixin
          prop :test_prop

          execute_query do
          end
        end
        TestQueryMixin.to_s.split('::').last
      end
      expect(result).to eq('TestQueryMixin')
    end

    it 'verifies prop class' do
      result = @doc.evaluate_ruby do
        class TestNode < LucidObject::Base
          attribute :test
        end
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop, class: String

          execute_query do
            { node: TestNode.new(key: 1, attributes: { test: props.test_prop }) }
          end
        end
        query_result = TestQueryMixinC.execute( test_prop: 'testing' )
        query_result.class.to_s
      end
      expect(result).to eq('LucidQueryResult')
      result = @doc.evaluate_ruby do
        class TestNode < LucidObject::Base
          attribute :test
        end
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop, class: String

          execute_query do
            { node: TestNode.new(key: 1, attributes: { test: props.test_prop }) }
          end
        end
        begin
          query_result = TestQueryMixinC.execute( test_prop: 1 )
          query_result.class.to_s
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @doc.evaluate_ruby do
        class TestNode < LucidObject::Base
          attribute :test
        end
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop, class: String, required: true

          execute_query do
            { node: TestNode.new(key: 1, attributes: { test: props.test_prop }) }
          end
        end
        begin
          query_result = TestQueryMixinC.execute()
          query_result.class.to_s
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if prop is_a' do
      result = @doc.evaluate_ruby do
        class TestNode < LucidObject::Base
          attribute :test
        end
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop, is_a: Enumerable

          execute_query do
            { node: TestNode.new(key: 1, attributes: { test: props.test_prop }) }
          end
        end
        query_result = TestQueryMixinC.execute( test_prop: ['test_value'] )
        query_result.class.to_s
      end
      expect(result).to eq('LucidQueryResult')
      result = @doc.evaluate_ruby do
        class TestNode < LucidObject::Base
          attribute :test
        end
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop, is_a: Enumerable

          execute_query do
            { node: TestNode.new(key: 1, attributes: { test: props.test_prop }) }
          end
        end
        begin
          query_result = TestQueryMixinC.execute( test_prop: 10 )
          query_result.class.to_s
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @doc.evaluate_ruby do
        class TestNode < LucidObject::Base
          attribute :test
        end
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop, is_a: Enumerable, required: true

          execute_query do
            { node: TestNode.new(key: 1, attributes: { test: props.test_prop }) }
          end
        end
        begin
          query_result = TestQueryMixinC.execute()
          query_result.class.to_s
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'can validate a prop' do
      result = @doc.evaluate_ruby do
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop, class: String
        end
        TestQueryMixinC.valid_prop?(:test_prop, 10)
      end
      expect(result).to eq(false)
      result = @doc.evaluate_ruby do
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop, class: String
        end
        TestQueryMixinC.valid_prop?(:test, '10')
      end
      expect(result).to eq(false)
      result = @doc.evaluate_ruby do
        class TestQueryMixinC < LucidQuery::Base
          prop :test_prop, class: String
        end
        TestQueryMixinC.valid_prop?(:test_prop, '10')
      end
      expect(result).to eq(true)
    end

    it 'can execute a simple query' do
      result = @doc.await_ruby do
        SimpleQuery.promise_execute(simple_prop: 'simple_text').then do |query_result|
          query_result.node.one
        end
      end
      expect(result).to eq('simple_text')
    end
  end
end
