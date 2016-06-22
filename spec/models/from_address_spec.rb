require 'rails_helper'

describe FromAddress do
  let(:vendor) {create(:email_vendor)}
  let(:account) {create(:account, email_vendor: vendor)}

  it_should_validate_as_email :from_email, :reply_to_email, :bounce_email

  context 'a valid from address' do
    let!(from_address){ account.from_addresses.create(is_default: true, from_email: 'one@example.com') }

    it 'should not allow duplicate default addresses' do
      account.from_addresses.create(is_default: true, from_email: 'two@example.com')
      expect(account.from_addresses.where(is_default: true).count).to eq(1)
    end

    it 'should not allow duplicate from emails' do
      fa = account.from_addresses.create(from_email: 'one@example.com')
      expect(fa.new_record?).to be true
      expect(fa.errors[:from_email]).not_to be_nil
    end

    context 'from name' do
      it 'should allow a from name to be assigned' do
        from_address.from_name = 'bill'
        expect { from_address.save! }.not_to raise_exception
      end

      it 'should allow a null from name' do
        from_address.from_name = nil
        expect { from_address.save! }.not_to raise_exception
      end

      it 'should default to null' do
        expect(from_address.from_name).to be_nil
      end
    end
  end

  context 'with account and all addresses' do
    subject {account.from_addresses.build(from_email: 'hey@dude.com', bounce_email: 'bounce@dude.com', reply_to_email: 'replyto@dude.com')}
    it {is_expected.to be_valid}
    it 'should use from email for bounce and reply-to' do
      expect(subject.bounce_email).to eq('bounce@dude.com')
      expect(subject.errors_to).to eq('bounce@dude.com')

      expect(subject.reply_to_email).to eq('replyto@dude.com')
      expect(subject.reply_to).to eq('replyto@dude.com')
    end
  end

  context 'with account and from_email' do
    subject {account.from_addresses.build(from_email: 'hey@dude.com')}
    it {is_expected.to be_valid}
  end

  context 'with no from_email' do
    subject do
      account.from_addresses.build(
        bounce_email:   'bounce@dude.com',
        reply_to_email: 'replyto@dude.com'
      )
    end
    it {is_expected.not_to be_valid}
  end
end
