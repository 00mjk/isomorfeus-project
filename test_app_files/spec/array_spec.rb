require 'spec_helper'

RSpec.describe 'LucidArray' do
  context 'on the server' do
    it 'can instantiate a array by inheritance' do
      result = on_server do
        class TestArrayBase < LucidArray::Base
        end
        array = TestArrayBase.new(key: 1, elements: [1, 2])
        array.count
      end
      expect(result).to eq(2)
    end

    it 'can instantiate a array by mixin' do
      result = on_server do
        class TestArrayMixin
          include LucidArray::Mixin
        end
        array = TestArrayMixin.new(key: 2, elements: [1, 2, 3])
        array.count
      end
      expect(result).to eq(3)
    end

    it 'verifies element class' do
      result = on_server do
        class TestArrayC < LucidArray::Base
          elements class: String
        end
        array = TestArrayC.new(key: 3, elements: ['test'])
        array[0].class.name
      end
      expect(result).to eq('String')
      result = on_server do
        class TestArrayC < LucidArray::Base
          elements class: String
        end
        begin
          TestArrayC.new(key: 4, elements: [1])
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestArrayC < LucidArray::Base
          elements class: String
        end
        begin
          array = TestArrayC.new(key: 5)
          array[1] = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if element is_a' do
      result = on_server do
        class TestArrayD < LucidArray::Base
          element is_a: String
        end
        array = TestArrayD.new(key: 5, elements: ['test'])
        array[0].class.name
      end
      expect(result).to eq('String')
      result = on_server do
        class TestArrayD < LucidArray::Base
          element is_a: String
        end
        begin
          TestArrayD.new(key: 6, elements: [1])
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestArrayD < LucidArray::Base
          element is_a: String
        end
        begin
          node = TestArrayD.new(key: 7)
          node[0] = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'reports a change' do
      result = on_server do
        class TestArrayE < LucidArray::Base
        end
        array = TestArrayE.new(key: 8)
        array.changed?
      end
      expect(result).to be(false)
      result = on_server do
        class TestArrayE < LucidArray::Base
        end
        array = TestArrayE.new(key: 9)
        array[0] = 20
        array.changed?
      end
      expect(result).to be(true)
    end

    it 'converts to cid' do
      result = on_server do
        class TestArrayE < LucidArray::Base
        end
        array = TestArrayE.new(key: 10)
        array.to_sid
      end
      expect(result).to eq(['TestArrayE', '10'])
    end

    it 'can validate a element' do
      result = on_server do
        class TestArrayF < LucidArray::Base
          element class: String
        end
        TestArrayF.valid_element?(10)
      end
      expect(result).to eq(false)
      result = on_server do
        class TestArrayF < LucidArray::Base
          element class: String
        end
        TestArrayF.valid_element?('10')
      end
      expect(result).to eq(true)
    end

    it 'converts to transport' do
      result = on_server do
        class TestArrayG < LucidArray::Base
        end
        array = TestArrayG.new(key: 13, elements: [1, 2, 3])
        array.to_transport
      end
      expect(result).to eq("TestArrayG"=>{"13"=>[1, 2, 3]})
    end
  end

  context 'on the client' do
    before :each do
      @doc = visit('/')
    end

    it 'can instantiate a array by inheritance' do
      result = @doc.evaluate_ruby do
        class TestArrayBase < LucidArray::Base
        end
        array = TestArrayBase.new(key: 1, elements: [1, 2])
        array.count
      end
      expect(result).to eq(2)
    end

    it 'can instantiate a array by mixin' do
      result = @doc.evaluate_ruby do
        class TestArrayMixin
          include LucidArray::Mixin
        end
        array = TestArrayMixin.new(key: 2, elements: [1, 2, 3])
        array.count
      end
      expect(result).to eq(3)
    end

    it 'verifies element class' do
      result = @doc.evaluate_ruby do
        class TestArrayC < LucidArray::Base
          elements class: String
        end
        array = TestArrayC.new(key: 3, elements: ['test'])
        array[0].class.name
      end
      expect(result).to eq('String')
      result = @doc.evaluate_ruby do
        class TestArrayC < LucidArray::Base
          elements class: String
        end
        begin
          TestArrayC.new(key: 4, elements: [1])
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @doc.evaluate_ruby do
        class TestArrayC < LucidArray::Base
          elements class: String
        end
        begin
          array = TestArrayC.new(key: 5)
          array[1] = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if element is_a' do
      result = @doc.evaluate_ruby do
        class TestArrayD < LucidArray::Base
          element is_a: String
        end
        array = TestArrayD.new(key: 5, elements: ['test'])
        array[0].class.name
      end
      expect(result).to eq('String')
      result = @doc.evaluate_ruby do
        class TestArrayD < LucidArray::Base
          element is_a: String
        end
        begin
          TestArrayD.new(key: 6, elements: [1])
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @doc.evaluate_ruby do
        class TestArrayD < LucidArray::Base
          element is_a: String
        end
        begin
          node = TestArrayD.new(key: 7)
          node[0] = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'reports a change' do
      result = @doc.evaluate_ruby do
        class TestArrayE < LucidArray::Base
        end
        array = TestArrayE.new(key: 8)
        array.changed?
      end
      expect(result).to be(true)
      result = @doc.evaluate_ruby do
        class TestArrayE < LucidArray::Base
        end
        array = TestArrayE.new(key: 9)
        array[0] = 20
        array.changed?
      end
      expect(result).to be(true)
    end

    it 'converts to cid' do
      result = @doc.evaluate_ruby do
        class TestArrayE < LucidArray::Base
        end
        array = TestArrayE.new(key: 10)
        array.to_sid
      end
      expect(result).to eq(['TestArrayE', '10'])
    end

    it 'can validate a element' do
      result = @doc.evaluate_ruby do
        class TestArrayF < LucidArray::Base
          element class: String
        end
        TestArrayF.valid_element?(10)
      end
      expect(result).to eq(false)
      result = @doc.evaluate_ruby do
        class TestArrayF < LucidArray::Base
          element class: String
        end
        TestArrayF.valid_element?('10')
      end
      expect(result).to eq(true)
    end

    it 'converts to transport' do
      result = @doc.evaluate_ruby do
        class TestArrayG < LucidArray::Base
        end
        array = TestArrayG.new(key: 13, elements: [1, 2, 3])
        JSON.dump(array.to_transport)
      end
      expect(JSON.parse(result)).to eq("TestArrayG"=>{"13"=>[1, 2, 3]})
    end
  end
end
