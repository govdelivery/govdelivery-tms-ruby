require 'spec_helper'
describe LoopbackEmailWorker do
  let(:email_vendor) { create(:email_vendor, :worker => 'LoopbackEmailWorker') }
  let(:account) { create(:account, email_vendor: email_vendor, name: 'name') }
  let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:message) { create(:email_message, account: account) }
  let(:recipient) { create(:email_recipient, message: message)}

   # :recipients_attributes => [
   #   {:email => "schwoop@sink.govdelivery.com", :vendor => email_vendor}]) }

  context 'a send' do
    it 'should mark complete' do
      recipient # force the creation of this
      subject.perform({'message_id' => message.id})
      message.reload.status.should eq(Message::Status::COMPLETED)
      recipient.reload.status.should eq(RecipientStatus::SENT)
    end
  end
end


