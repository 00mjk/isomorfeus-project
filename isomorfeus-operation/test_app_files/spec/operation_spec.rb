require 'spec_helper'

RSpec.describe 'LucidOperation' do
  context 'on server' do
    it 'can instantiate by inheritance' do
      result = on_server do
        class TestOperation < LucidOperation::Base
        end
        o = TestOperation.new({})
        o.class.to_s
      end
      expect(result).to include('::TestOperation')
    end

    it 'can instantiate by mixin' do
      result = on_server do
        class TestOperation
          include LucidOperation::Mixin
        end
        o = TestOperation.new({})
        o.class.to_s
      end
      expect(result).to include('::TestOperation')
    end

    it 'the operation load handler is a valid handler'  do
      result = on_server do
        Isomorfeus.valid_handler_class_name?('Isomorfeus::Operation::Handler::OperationHandler')
      end
      expect(result).to be true
    end

    it 'the simple operation is a valid operation class' do
      result = on_server do
        Isomorfeus.valid_operation_class_name?('SimpleOperation')
      end
      expect(result).to be true
    end

    it 'the simple operation has one step' do
      result = on_server do
        SimpleOperation.steps.size
      end
      expect(result).to eq(1)
    end

    it 'the simple operation has one step with a regexp' do
      result = on_server do
        SimpleOperation.steps[0][0].class.to_s
      end
      expect(result).to include('Regexp')
    end

    it 'the simple operation has one step with a Proc' do
      result = on_server do
        SimpleOperation.steps[0][1].class.to_s
      end
      expect(result).to include('Proc')
    end

    it 'the simple operation has the procedure parsed' do
      result = on_server do
        SimpleOperation.gherkin
      end
      expect(result).to eq({:ensure=>[], :failure=>[], :operation=>"SimpleOperation", :procedure=>"SimpleOperation executing", :steps=>["a bird"]})
    end

    it 'the simple operation has the procedure parsed and one gherkin step' do
      result = on_server do
        SimpleOperation.gherkin[:steps].size
      end
      expect(result).to eq(1)
    end

    it 'the simple operation has the procedure parsed and one gherkin step "a bird"' do
      result = on_server do
        SimpleOperation.gherkin[:steps][0]
      end
      expect(result).to eq("a bird")
    end

    it 'can run the simple operation on the server' do
      result = on_server do
        promise = SimpleOperation.promise_run({})
        promise.value
      end
      expect(result).to eq('a bird')
    end

    it 'executes the then block on success' do
      result = on_server do
        res = nil
        SimpleOperation.promise_run.then do |value|
          res = value
        end
        res
      end
      expect(result).to eq('a bird')
    end

    it 'executes the fail block on failure' do
      result = on_server do
        res = nil
        SimpleOperation.promise_run(fail_op: true).fail do |_|
          res = 'fail called'
        end
        res
      end
      expect(result).to eq('fail called')
    end
  end

  context 'on client' do
    before :each do
      @doc = visit('/')
    end

    it 'can instantiate by inheritance' do
      result = @doc.evaluate_ruby do
        class TestOperation < LucidOperation::Base
        end
        o = TestOperation.new({})
        o.class.to_s
      end
      expect(result).to include('TestOperation')
    end

    it 'can instantiate by mixin' do
      result = @doc.evaluate_ruby do
        class TestOperation
          include LucidOperation::Mixin
        end
        o = TestOperation.new({})
        o.class.to_s
      end
      expect(result).to include('TestOperation')
    end

    it 'can run the simple operation' do
      result = @doc.await_ruby do
        SimpleOperation.promise_run({})
      end
      expect(result).to eq('a bird')
    end

    it 'executes the then block on success' do
      result = @doc.await_ruby do
        SimpleOperation.promise_run.then do |result|
          'i see ' + result
        end
      end
      expect(result).to eq('i see a bird')
    end

    it 'executes the fail block on failure' do
      result = @doc.await_ruby do
        SimpleOperation.promise_run(fail_op: true).fail do |_|
          'fail called'
        end
      end
      expect(result).to eq('fail called')
    end
  end
end
