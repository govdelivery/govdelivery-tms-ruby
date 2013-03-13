require 'spec_helper'

describe EmailRecipient do
  let(:macros) { {'one' => 'one_value', 'five' => 'five_value', 'two' => 'two_value'} }

  subject {
    v = create_email_vendor
    m = EmailMessage.new(:body => 'short body', :subject => 'fuuu')
    m.stubs(:vendor).returns(v)
    a = create_account(:email_vendor => v, :name => 'account', :email_vendor => v)
    u = User.create(:email => 'admin@example.com', :password => 'retek01!')
    u.account = a
    m.account = a
    r = m.recipients.build
    r.message = m
    r
  }

  its(:email) { should be_nil }
  it { should_not be_valid }

  context 'with an email' do
    before do
      subject.email='hi@man.com'
      subject.save!
    end
    it 'should have the correct ODM record designator' do
      subject.to_odm.should eq("hi@man.com::#{subject.id}")
    end
    context 'and macros' do
      before do
        subject.macros = macros
        subject.save!
      end
      it 'should have the correct ODM record designator' do
        subject.to_odm('five' => nil, 'one' => nil, 'two' => nil).should eq("hi@man.com::#{subject.id}::five_value::one_value::two_value")
        # remove one from default hash
        subject.to_odm('five' => nil, 'two' => nil).should        eq("hi@man.com::#{subject.id}::five_value::two_value")
        # merging in defaults 
        subject.to_odm({'one' => nil, 'seven' => 'seven_value'}).should eq("hi@man.com::#{subject.id}::one_value::seven_value")
      end
    end
    context 'that is sent' do
      before do
        subject.sent!(nil, Time.now)
      end
      it 'should update the record' do
        subject.reload
        subject.vendor.should_not be_nil
        subject.completed_at.should_not be_nil
        subject.ack.should be_nil
        subject.status.should eq(RecipientStatus::SENT)
      end
      it 'should save clicks' do
        subject.email_recipient_clicks.count.should == 0
        subject.clicked!("http://foo.bar.com", DateTime.now)
        subject.email_recipient_clicks.count.should == 1
      end
      it 'should save opens' do
        subject.email_recipient_opens.count.should == 0
        subject.opened!("1.1.1.1", DateTime.now) # IMPOSSIBLE!!  NO WAY!! OH   MY   GOD
        subject.email_recipient_opens.count.should == 1
      end
    end
  end
end

