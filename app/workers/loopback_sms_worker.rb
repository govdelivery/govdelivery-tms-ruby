class LoopbackSmsWorker < LoopbackMessageWorker

  @magic_addresses =
    {
      sent:         '15005550006',
      blacklisted:  '15005550005',
      failed:       '15005550004',
      canceled:     '15005550003',
      inconclusive: '15005550002',
      sending:      '15005550001',
      new:          '15005550000'
    }

  def perform(options)
    @message = SmsMessage.find(options['message_id'])
    super
  end

  def target(recipient)
    recipient.phone
  end

end
