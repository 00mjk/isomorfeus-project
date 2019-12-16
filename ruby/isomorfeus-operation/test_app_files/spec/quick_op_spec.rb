require 'spec_helper'

RSpec.describe 'LucidQuickOp' do
  context 'on server' do
    it 'can instantiate by inheritance' do
      result = on_server do
        class TestQuickOp < LucidQuickOp::Base
        end
        o = TestQuickOp.new({})
        o.class.to_s
      end
      expect(result).to include('::TestQuickOp')
    end

    it 'can instantiate by mixin' do
      result = on_server do
        class TestQuickOp
          include LucidQuickOp::Mixin
        end
        o = TestQuickOp.new({})
        o.class.to_s
      end
      expect(result).to include('::TestQuickOp')
    end

    it 'the operation load handler is a valid handler'  do
      result = on_server do
        Isomorfeus.valid_handler_class_name?('Isomorfeus::Operation::Handler::OperationHandler')
      end
      expect(result).to be true
    end

    it 'the simple quick operation is a valid op class' do
      result = on_server do
        Isomorfeus.valid_operation_class_name?('SimpleQuickOp')
      end
      expect(result).to be true
    end

    it 'the simple quick operation has a op block' do
      result = on_server do
        SimpleQuickOp.instance_variable_get(:@op).class.to_s
      end
      expect(result).to include('Proc')
    end

    it 'the simple quick operation has a op block that has a bird' do
      result = on_server do
        SimpleQuickOp.instance_variable_get(:@op).call
      end
      expect(result).to eq('a bird')
    end

    it 'can run the simple quick operation instance on the server' do
      result = on_server do
        promise = SimpleQuickOp.new({}).promise_run
        promise.value
      end
      expect(result).to eq('a bird')
    end

    it 'can run the simple quick operation on the server' do
      result = on_server do
        promise = SimpleQuickOp.promise_run({})
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
        class TestQuickOp < LucidQuickOp::Base
        end
        o = TestQuickOp.new({})
        o.class.to_s
      end
      expect(result).to include('TestQuickOp')
    end

    it 'can instantiate by mixin' do
      result = @doc.evaluate_ruby do
        class TestQuickOp
          include LucidQuickOp::Mixin
        end
        o = TestQuickOp.new({})
        o.class.to_s
      end
      expect(result).to include('TestQuickOp')
    end

    it 'can run the simple quick operation' do
      result = @doc.await_ruby do
        SimpleQuickOp.promise_run({})
      end
      expect(result).to eq('a bird')
    end
  end
end