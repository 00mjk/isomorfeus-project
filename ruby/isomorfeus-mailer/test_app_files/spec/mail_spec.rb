require 'spec_helper'

RSpec.describe 'LucidMail' do
  context 'on server' do
    it 'can create a mail' do
      result = on_server do
        mail = LucidMail.new(component: 'EmailComponent', props: { name: 'Werner' }, from: 'me@test.com', to: 'you@test.com', subject: 'Welcome')
        mail.build
        mail.rendered_component
      end
      expect(result).to include 'Welcome Werner!'
    end
  end
end
