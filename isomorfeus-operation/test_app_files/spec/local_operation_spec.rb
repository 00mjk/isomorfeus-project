require 'spec_helper'

RSpec.describe 'LucidLocalOperation' do
  context 'on server' do
    it 'can instantiate by inheritance' do
      result = on_server do
        class TestLocalOperation < LucidLocalOperation::Base
        end
        o = TestLocalOperation.new()
        o.class.to_s
      end
      expect(result).to include('::TestLocalOperation')
    end

    it 'can instantiate by mixin' do
      result = on_server do
        class TestLocalOperation
          include LucidLocalOperation::Mixin
        end
        o = TestLocalOperation.new()
        o.class.to_s
      end
      expect(result).to include('::TestLocalOperation')
    end

    it 'the local operation is a valid operation class' do
      result = on_server do
        Isomorfeus.valid_operation_class_name?('SimpleLocalOperation')
      end
      expect(result).to be true
    end

    it 'the local operation has one step' do
      result = on_server do
        SimpleLocalOperation.steps.size
      end
      expect(result).to eq(1)
    end

    it 'the simple operation has one step with a regexp' do
      result = on_server do
        SimpleLocalOperation.steps[0][0].class.to_s
      end
      expect(result).to include('Regexp')
    end

    it 'the simple operation has one step with a Proc' do
      result = on_server do
        SimpleLocalOperation.steps[0][1].class.to_s
      end
      expect(result).to include('Proc')
    end

    it 'the simple operation has the procedure parsed' do
      result = on_server do
        SimpleLocalOperation.gherkin
      end
      expect(result).to eq({:ensure=>[], :failure=>[], :operation=>"SimpleLocalOperation", :procedure=>"SimpleLocalOperation executing", :steps=>["a bird"]})
    end

    it 'the simple operation has the procedure parsed and one gherkin step' do
      result = on_server do
        SimpleLocalOperation.gherkin[:steps].size
      end
      expect(result).to eq(1)
    end

    it 'the simple operation has the procedure parsed and one gherkin step "a bird"' do
      result = on_server do
        SimpleLocalOperation.gherkin[:steps][0]
      end
      expect(result).to eq("a bird")
    end

    it 'can run the simple operation on the server' do
      result = on_server do
        promise = SimpleLocalOperation.promise_run()
        promise.value
      end
      expect(result).to eq('a bird')
    end

    it 'executes the then block on success' do
      result = on_server do
        res = nil
        SimpleLocalOperation.promise_run.then do |value|
          res = value
        end
        res
      end
      expect(result).to eq('a bird')
    end

    it 'executes the fail block on failure' do
      result = on_server do
        res = nil
        SimpleLocalOperation.promise_run(fail_op: true).fail do |_|
          res = 'fail called'
        end
        res
      end
      expect(result).to eq('fail called')
    end
  end

  context 'on client' do
    before :each do
      @page = visit('/')
    end

    it 'can instantiate by inheritance' do
      result = @page.eval_ruby do
        class TestLocalOperation < LucidLocalOperation::Base
        end
        o = TestLocalOperation.new()
        o.class.to_s
      end
      expect(result).to include('TestLocalOperation')
    end

    it 'can instantiate by mixin' do
      result = @page.eval_ruby do
        class TestLocalOperation
          include LucidLocalOperation::Mixin
        end
        o = TestLocalOperation.new()
        o.class.to_s
      end
      expect(result).to include('TestLocalOperation')
    end

    it 'can run the simple operation' do
      result = @page.await_ruby do
        SimpleLocalOperation.promise_run()
      end
      expect(result).to eq('a bird')
    end

    it 'executes the then block on success' do
      result = @page.await_ruby do
        SimpleLocalOperation.promise_run.then do |result|
          'i see ' + result
        end
      end
      expect(result).to eq('i see a bird')
    end

    it 'executes the fail block on failure' do
      # the global vars are a workaround
      result = @page.await_ruby do
        SimpleLocalOperation.promise_run(fail_op: true).fail do |_|
          $promise_resolved = true
          $promise_result = 'fail called'
          'fail called'
        end
      end
      expect(result).to eq('fail called')
    end
  end
end
