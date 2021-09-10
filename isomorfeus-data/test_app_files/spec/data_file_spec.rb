require 'spec_helper'

RSpec.describe 'LucidData::File' do
  context 'on the server' do
    it 'can instantiate a file by inheritance' do
      result = on_server do
        class TestFileBase < LucidData::File::Base
        end
        file = TestFileBase.new(key: 1)
        file.key
      end
      expect(result).to eq('1')
    end

    it 'can instantiate a file by mixin' do
      result = on_server do
        class TestFileMixin
          include LucidData::File::Mixin
        end
        file = TestFileMixin.new(key: 2)
        file.key
      end
      expect(result).to eq('2')
    end

    it 'can create a simple file' do
      result = on_server do
        file = SimpleFile.create(key: '123', data: 'a')
        file.data
      end
      expect(result).to eq('a')
    end

    it 'can load a simple file' do
      result = on_server do
        file = SimpleFile.load(key: '123')
        file.data
      end
      expect(result).to eq('a')
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
        file.data = 'changed'
        before_changed = file.changed?
        file.save
        [file.data, before_changed, file.changed?]
      end
      expect(result).to eq(['changed', true, false])
    end

    it 'converts to sid' do
      result = on_server do
        class TestFileMixinC < LucidData::File::Base
        end
        file = TestFileMixinC.new(key: 11)
        file.to_sid
      end
      expect(result).to eq(['TestFileMixinC', '11'])
    end

    it 'converts to transport' do
      result = on_server do
        class TestFileMixinC < LucidData::File::Base
        end
        file = TestFileMixinC.new(key: 12)
        file.to_transport
      end
      expect(result).to eq("TestFileMixinC"=>{"12"=>{data_url: nil}})
    end
  end

  context 'on the client' do
    before :each do
      @doc = visit('/')
    end

    it 'can instantiate a file by inheritance' do
      result = @doc.evaluate_ruby do
        class TestFileBase < LucidData::File::Base
        end
        file = TestFileBase.new(key: 14)
        file.key
      end
      expect(result).to eq('14')
    end

    it 'can instantiate a file by mixin' do
      result = @doc.evaluate_ruby do
        class TestFileMixin
          include LucidData::File::Mixin
        end
        file = TestFileMixin.new(key: 15)
        file.key
      end
      expect(result).to eq('15')
    end

    it 'reports a change' do
      result = @doc.evaluate_ruby do
        class TestFileMixinC < LucidData::File::Base
        end
        file = TestFileMixinC.new(key: 23)
        file.changed?
      end
      expect(result).to be(false)
      result = @doc.evaluate_ruby do
        class TestFileMixinC < LucidData::File::Base
        end
        file = TestFileMixinC.new(key: 23)
        file.data = 20
        file.changed?
      end
      expect(result).to be(true)
    end

    it 'can load a simple file' do
      result = @doc.await_ruby do
        SimpleFile.promise_load(key: '123').then do |file|
          file.data
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
          file.data = 'changed'
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
        end
        file = TestFileMixinC.new(key: 24)
        file.to_sid
      end
      expect(result).to eq(['TestFileMixinC', '24'])
    end

    it 'converts to transport' do
      result = @doc.evaluate_ruby do
        class TestFileMixinC < LucidData::File::Base
        end
        file = TestFileMixinC.new(key: 28)
        file.to_transport.to_n
      end
      expect(result).to eq("TestFileMixinC" => {"28"=>{}})
    end

    it 'can load' do
      result = @doc.await_ruby do
        SimpleFile.promise_load(key: '123456').then do |file|
          file.data
        end
      end
      expect(result).to eq('123456')
    end

    it 'can save' do
      result = @doc.await_ruby do
        file = SimpleFile.new(key: '123456')
        file.data = 654321
        file.promise_save.then do |file|
          file.data
        end
      end
      expect(result).to eq(654321)
    end
  end
end
