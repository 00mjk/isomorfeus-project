require 'spec_helper'

RSpec.describe 'LucidArray' do
  context 'on the server' do
    it 'can instantiate a array by inheritance' do
      result = on_server do
        class TestArrayBase < LucidArray::Base
        end
        array = TestArrayBase.new(1, [1, 2])
        array.count
      end
      expect(result).to eq(2)
    end

    it 'can instantiate a array by mixin' do
      result = on_server do
        class TestArrayMixin
          include LucidArray::Mixin
        end
        array = TestArrayMixin.new(2, [1, 2, 3])
        array.count
      end
      expect(result).to eq(3)
    end

    it 'verifies element class' do
      result = on_server do
        class TestArrayC < LucidArray::Base
          elements class: String
        end
        array = TestArrayC.new(3, ['test'])
        array[0].class.name
      end
      expect(result).to eq('String')
      result = on_server do
        class TestArrayC < LucidArray::Base
          elements class: String
        end
        begin
          TestArrayC.new(4, [1])
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
          array = TestArrayC.new(5)
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
        array = TestArrayD.new(5, ['test'])
        array[0].class.name
      end
      expect(result).to eq('String')
      result = on_server do
        class TestArrayD < LucidArray::Base
          element is_a: String
        end
        begin
          TestArrayD.new(6, [1])
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
          node = TestArrayD.new(7)
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
        array = TestArrayE.new(8)
        array.changed?
      end
      expect(result).to be(false)
      result = on_server do
        class TestArrayE < LucidArray::Base
        end
        array = TestArrayE.new(9)
        array[0] = 20
        array.changed?
      end
      expect(result).to be(true)
    end

    it 'converts to cid' do
      result = on_server do
        class TestArrayE < LucidArray::Base
        end
        array = TestArrayE.new(10)
        array.to_cid
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
        array = TestArrayG.new(13, [1, 2, 3])
        array.to_transport
      end
      expect(result).to eq("arrays"=>{"TestArrayG"=>{"13"=>[1, 2, 3]}})
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
        array = TestArrayBase.new(1, [1, 2])
        array.count
      end
      expect(result).to eq(2)
    end

    it 'can instantiate a array by mixin' do
      result = @doc.evaluate_ruby do
        class TestArrayMixin
          include LucidArray::Mixin
        end
        array = TestArrayMixin.new(2, [1, 2, 3])
        array.count
      end
      expect(result).to eq(3)
    end

    it 'verifies element class' do
      result = @doc.evaluate_ruby do
        class TestArrayC < LucidArray::Base
          elements class: String
        end
        array = TestArrayC.new(3, ['test'])
        array[0].class.name
      end
      expect(result).to eq('String')
      result = @doc.evaluate_ruby do
        class TestArrayC < LucidArray::Base
          elements class: String
        end
        begin
          TestArrayC.new(4, [1])
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
          array = TestArrayC.new(5)
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
        array = TestArrayD.new(5, ['test'])
        array[0].class.name
      end
      expect(result).to eq('String')
      result = @doc.evaluate_ruby do
        class TestArrayD < LucidArray::Base
          element is_a: String
        end
        begin
          TestArrayD.new(6, [1])
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
          node = TestArrayD.new(7)
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
        array = TestArrayE.new(8)
        array.changed?
      end
      expect(result).to be(false)
      result = @doc.evaluate_ruby do
        class TestArrayE < LucidArray::Base
        end
        array = TestArrayE.new(9)
        array[0] = 20
        array.changed?
      end
      expect(result).to be(true)
    end

    it 'converts to cid' do
      result = @doc.evaluate_ruby do
        class TestArrayE < LucidArray::Base
        end
        array = TestArrayE.new(10)
        array.to_cid
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
        array = TestArrayG.new(13, [1, 2, 3])
        JSON.dump(array.to_transport)
      end
      expect(JSON.parse(result)).to eq("arrays"=>{"TestArrayG"=>{"13"=>[1, 2, 3]}})
    end
  end
end
