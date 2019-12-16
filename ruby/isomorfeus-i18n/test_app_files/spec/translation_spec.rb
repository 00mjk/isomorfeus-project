require 'spec_helper'

RSpec.describe 'LucidTranslation::Mixin' do
  context 'on server' do
    it 'can mixin' do
      result = on_server do
        class TestClass
          include LucidTranslation::Mixin
        end
        TestClass.ancestors
      end
      expect(result).to include(LucidTranslation::Mixin)
    end

    it 'has available locales' do
      result = on_server do
        Isomorfeus.available_locales
      end
      expect(result).to eq(['de'])
    end

    it 'has locale' do
      result = on_server do
        Isomorfeus.locale
      end
      expect(result).to eq('de')
    end

    it 'has domain' do
      result = on_server do
        Isomorfeus.i18n_domain
      end
      expect(result).to eq('app')
    end

    it 'can translate on class level' do
      result = on_server do
        class TestClass
          extend LucidTranslation::Mixin
        end
        TestClass._('simple')
      end
      expect(result).to eq('einfach')
    end

    it 'can translate on instance level' do
      result = on_server do
        class TestClass
          include LucidTranslation::Mixin
        end
        TestClass.new._('simple')
      end
      expect(result).to eq('einfach')
    end
  end

  context 'Server Side Rendering' do
    before do
      @doc = visit('/ssr')
    end

    it 'renders on the server' do
      expect(@doc.html).to include('Rendered!')
    end

    it 'translates' do
      expect(@doc.html).to include('einfach')
    end
  end
end
