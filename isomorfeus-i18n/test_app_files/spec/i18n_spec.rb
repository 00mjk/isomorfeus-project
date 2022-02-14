require 'spec_helper'

RSpec.describe 'LucidI18n::Mixin' do
  context 'on server' do
    it 'can mixin' do
      result = on_server do
        class TestClass
          include LucidI18n::Mixin
        end
        TestClass.ancestors
      end
      expect(result).to include(LucidI18n::Mixin)
    end

    it 'has available locales' do
      result = on_server do
        Isomorfeus.available_locales
      end
      expect(result).to eq(['de'])
    end

    it 'has locale' do
      result = on_server do
        Isomorfeus.default_locale
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
          extend LucidI18n::Mixin
        end
        TestClass._('simple')
      end
      expect(result).to eq('einfach')
    end

    it 'can translate on instance level' do
      result = on_server do
        class TestClass
          include LucidI18n::Mixin
        end
        TestClass.new._('simple')
      end
      expect(result).to eq('einfach')
    end

    it 'can localize' do
      result = on_server do
        class TestClass
          include LucidI18n::Mixin
        end
        TestClass.new.l(1.2345)
      end
      expect(result).to eq('1,2345')
    end
  end

  context 'Server Side Rendering' do
    before do
      @page = visit('/ssr')
    end

    it 'renders on the server' do
      expect(@page.inner_text).to include('Rendered!')
    end

    it 'translates' do
      expect(@page.inner_text).to include('einfach')
    end

    it 'localizes' do
      expect(@page.inner_text).to include('localized numbers: 1.000 1,235')
    end
  end

  context 'Client Side Rendering' do
    before do
      @page = visit('/snc?skip_ssr=true')
    end

    it 'renders in the browser' do
      @page.wait_for_selector('#nav_links')
      res = @page.inner_text
      expect(@page.inner_text).to include('Rendered!')
    end

    it 'translates' do
      @page.wait_for_selector('#nav_links')
      res = @page.inner_text
      expect(@page.inner_text).to include('einfach')
    end

    it 'translates' do
      @page.wait_for_selector('#nav_links')
      res = @page.inner_text
      expect(@page.inner_text).to include('localized numbers: 1.000 1,235')
    end
  end
end
