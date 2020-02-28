require 'spec_helper'

RSpec.describe 'isomorfeus-transport' do
  before :all do
    @doc = visit('/')
  end

  it 'registers a channel class as valid channel class name when inherited' do
    result = on_server do
      class TestChannelClassBlaWhatever < LucidChannel::Base
      end
      Isomorfeus.valid_channel_class_names
    end
    expect(result).to include('TestChannelClassBlaWhatever')
  end

  it 'registers a channel class as valid channel class name when included' do
    result = on_server do
      class WhateverClassAnyThing
        include LucidChannel::Mixin
      end
      Isomorfeus.valid_channel_class_names
    end
    expect(result).to include('WhateverClassAnyThing')
  end

  context 'simple class name based channel' do
    it 'can subscribe and unsubscribe' do
      sub_result = @doc.await_ruby do
        SimpleChannel.promise_subscribe
      end
      expect(sub_result).to have_key('success')
      expect(sub_result['success']).to eq('SimpleChannel')
      unsub_result = @doc.await_ruby do
        SimpleChannel.promise_unsubscribe
      end
      expect(unsub_result).to have_key('success')
      expect(unsub_result['success']).to eq('SimpleChannel')
    end

    it 'can send and receive messages' do
      @doc.await_ruby do
        $simple_message = nil
        SimpleChannel.promise_subscribe
      end
      @doc.evaluate_ruby do
        SimpleChannel.send_message('cake')
      end
      have_message = false
      start = Time.now
      until have_message
        break if (Time.now - start) > 10
        sleep 0.1
        have_message = @doc.evaluate_ruby do
          $simple_message != nil
        end
      end
      result = @doc.evaluate_ruby do
        $simple_message
      end
      @doc.await_ruby do
        SimpleChannel.promise_unsubscribe
      end
      expect(result).to eq('cake')
    end
  end

  context 'custom channel' do
    it 'can subscribe and unsubscribe' do
      sub_result = @doc.await_ruby do
        Promise.when(
          CustomChannel.promise_subscribe,
          CustomChannel.promise_subscribe('one'),
          CustomChannel.promise_subscribe('two')
        )
      end
      expect(sub_result[1]).to have_key('success')
      expect(sub_result[1]['success']).to eq('one')
      unsub_result = @doc.await_ruby do
        Promise.when(
          CustomChannel.promise_unsubscribe,
          CustomChannel.promise_unsubscribe('one'),
          CustomChannel.promise_unsubscribe('two')
        )
      end
      expect(unsub_result[1]).to have_key('success')
      expect(unsub_result[1]['success']).to eq('one')
    end

    it 'can send and receive messages' do
      @doc.await_ruby do
        $simple_message = nil
        $custom_message = nil
        $custom_message_one = nil
        $custom_message_two = nil
        Promise.when(
          SimpleChannel.promise_subscribe,
          CustomChannel.promise_subscribe,
          CustomChannel.promise_subscribe(:one),
          CustomChannel.promise_subscribe('two')
        )
      end
      @doc.evaluate_ruby do
        CustomChannel.send_message('custom')
        CustomChannel.send_message('cat', :one)
        CustomChannel.send_message('dog', 'two')
      end
      have_message = false
      start = Time.now
      until have_message
        break if (Time.now - start) > 10
        sleep 0.1
        have_message = @doc.evaluate_ruby do
          $simple_message != nil
        end
      end
      result = @doc.evaluate_ruby do
        [$custom_message, $custom_message_one, $custom_message_two, $simple_message]
      end
      @doc.await_ruby do
        Promise.when(
          SimpleChannel.promise_unsubscribe,
          CustomChannel.promise_unsubscribe,
          CustomChannel.promise_unsubscribe('one'),
          CustomChannel.promise_unsubscribe('two')
        )
      end
      expect(result).to eq(['custom', 'cat', 'dog', 'hello from server'])
    end
  end
end
