class CreateKahloVendor < ActiveRecord::Migration
  def change
    if defined?(SmsVendor)
      SmsVendor.where(
        name:       'Kahlo Loopback Sender',
        username:   'n/a',
        password:   'n/a',
        from_phone: '+15553665397',
        worker:     'KahloMessageWorker',
        help_text:  'kahlo needs help too',
        stop_text:  'kahlo never stops',

      ).first_or_create!
    else

    end

  end
end
