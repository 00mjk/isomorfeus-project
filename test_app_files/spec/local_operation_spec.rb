require 'spec_helper'

RSpec.describe 'LucidLocalOperation' do
  context 'on server' do
    it 'can instantiate by inheritance' do
      result = on_server do
        class TestLocalOperation < LucidLocalOperation::Base
        end
        o = TestLocalOperation.new({})
        o.class.to_s
      end
      expect(result).to include('::TestLocalOperation')
    end

    it 'can instantiate by mixin' do
      result = on_server do
        class TestLocalOperation
          include LucidLocalOperation::Mixin
        end
        o = TestLocalOperation.new({})
        o.class.to_s
      end
      expect(result).to include('::TestLocalOperation')
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

    it 'the simple operation has one step which returns a bird' do
      result = on_server do
        SimpleOperation.steps[0][1].call
      end
      expect(result).to eq('a bird')
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
  end

  context 'on client' do
    before :each do
      @doc = visit('/')
    end

    it 'can instantiate by inheritance' do
      result = @doc.evaluate_ruby do
        class TestLocalOperation < LucidLocalOperation::Base
        end
        o = TestLocalOperation.new({})
        o.class.to_s
      end
      expect(result).to include('TestLocalOperation')
    end

    it 'can instantiate by mixin' do
      result = @doc.evaluate_ruby do
        class TestLocalOperation
          include LucidLocalOperation::Mixin
        end
        o = TestLocalOperation.new({})
        o.class.to_s
      end
      expect(result).to include('TestLocalOperation')
    end

    it 'can run the simple operation' do
      result = @doc.await_ruby do
        SimpleOperation.promise_run({})
      end
      expect(result).to eq('a bird')
    end
  end
end