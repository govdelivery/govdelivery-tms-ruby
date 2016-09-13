require 'test_helper'

class GovDelivery::Kahlo::ClientTest < Minitest::Test
  def setup
    @message = {
      to:          '+16125551235',
      from:        '55115',
      body:        'ur kinda stubby :^)',
      callback_id: 'foobar29'
    }
    @now     = Time.now
  end

  def teardown
    Synapse::Supervisor.supervised_classes.clear
  end

  def test_deliver_message
    @synapse = MiniTest::Mock.new

    Time.stub :now, @now do
      @synapse.expect(:publish, nil, ["kahlo_messages", @message.merge(created_at: (@now.to_f * 1000).to_i)])
      client                = GovDelivery::Kahlo::Client.new
      client.class.publisher= @synapse
      client.deliver_message(@message)
    end

    @synapse.verify
  end

  def test_deliver_from_short_code
    @synapse        = MiniTest::Mock.new
    @message[:from] ='468311'

    Time.stub :now, @now do
      @synapse.expect(:publish, nil, ["kahlo_messages", @message.merge(created_at: (@now.to_f * 1000).to_i)])
      client                = GovDelivery::Kahlo::Client.new
      client.class.publisher= @synapse
      client.deliver_message(@message)
    end

    @synapse.verify
  end

  def test_deliver_unvalidated
    @synapse              = MiniTest::Mock.new
    client                = GovDelivery::Kahlo::Client.new
    client.class.publisher= @synapse
    message               = @message.merge(from: 'sdfasdfadsfasdf')

    Time.stub :now, @now do
      @synapse.expect(:publish, nil, ["kahlo_messages", message.merge(created_at: (@now.to_f * 1000).to_i)])
      client.deliver_message(message, validate: false)
    end

    @synapse.verify
  end

  def test_bad_to_number
    client                 = GovDelivery::Kahlo::Client.new
    client.class.publisher = nil
    @message[:to]          ='154234'

    e = assert_raises GovDelivery::Kahlo::InvalidMessage do
      client.deliver_message(@message)
    end
    assert_equal [:to], e.fields
  end

  def test_bad_from_number
    client                 = GovDelivery::Kahlo::Client.new
    client.class.publisher = nil
    @message[:from]        ='+154234'

    e = assert_raises GovDelivery::Kahlo::InvalidMessage do
      client.deliver_message(@message)
    end
    assert_equal [:from], e.fields
  end


  def test_handle_status_callbacks
    Synapse.configuration.source='testing'

    client         = GovDelivery::Kahlo::Client.new
    handler        = MiniTest::Mock.new
    msg_for_us     = {'src' => 'kahlo', 'sender_src' => 'testing'}
    msg_not_for_us = {'src' => 'kahlo', 'sender_src' => 'someone-else'}
    handler.expect(:process, nil, [msg_for_us])

    klass = client.handle_status_callbacks do |msg|
      handler.process(msg)
    end

    subscriber = klass.instance
    subscriber.handleMessage(1, 2, nil, msg_not_for_us)
    subscriber.handleMessage(1, 2, nil, msg_for_us)
    handler.verify
  end
end
