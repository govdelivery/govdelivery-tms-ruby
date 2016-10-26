require 'rails_helper'

describe InboundMessageHandler do
  let(:vendor) { create(:sms_vendor) }
  let(:to) { vendor.from_phone }
  let(:from) { "+16515551234" }
  let(:sid) { '0' * 34 }

  subject { InboundMessageHandler.new(SmsVendor.where(username: vendor.username)) }

  it 'should initialize and use supplied scope' do
    handler = InboundMessageHandler.new(SmsVendor.where('1!=1'))
    expect { handler.handle(sid, to, from, 'uhhh') }.to raise_error ActiveRecord::RecordNotFound
  end

  context 'without a prefix' do
    it "responds to 'STOP' with vendor stop text" do
      SmsVendor.any_instance.expects(:stop!).with(kind_of(CommandParameters))
      ForwardStopsToDcm.expects(:verify_and_forward!)
      expect(subject.handle(sid, to, from, 'STOP')).to be true
      expect(subject.vendor).to eq vendor
      expect(subject.outbound_recipient).to be from
      expect(subject.inbound_recipient).to eq vendor.from_phone
      expect(subject.response_text).to eq Service::Keyword::DEFAULT_STOP_TEXT
    end

    it "responds to 'HELP' with vendor help text" do
      expect(subject.handle(sid, to, from, 'HELP')).to be true
      expect(subject.vendor).to eq vendor
      expect(subject.outbound_recipient).to be from
      expect(subject.inbound_recipient).to eq vendor.from_phone
      expect(subject.response_text).to eq Service::Keyword::DEFAULT_HELP_TEXT
    end

    it "responds to: 'GIBBERISH' with account default response text" do
      account                       = create_account 'pirate', 'plunder', vendor
      default_keyword               = account.default_keyword
      default_keyword.response_text = 'Aye! Ye got me booty!'
      default_keyword.save

      expect(subject.handle(sid, to, from, 'GIBBERISH')).to be true
      expect(subject.vendor).to eq vendor
      expect(subject.outbound_recipient).to be from
      expect(subject.inbound_recipient).to eq vendor.from_phone
      expect(subject.response_text).to eq 'Aye! Ye got me booty!'
    end

    context 'that should be ignored' do
      before do
        InboundMessage.any_instance.stubs(:ignored?).returns(true)
        Service::Keyword.any_instance.expects(:respond!).returns("don't send this")
      end

      it 'should execute comands but not return response text' do
        expect(subject.handle(sid, to, from, 'i am in my car right now, will reply later')).to be false
        expect(subject.response_text).to eq "don't send this"
      end
    end
  end

  context 'an account with prefix: pirate' do
    context "a keyword with name: 'plunder' and a forward command without response text " do
      before :each do
        @account = create_account 'pirate', 'plunder', vendor
        @keyword = @account.keywords.last
      end
      it 'does not respond' do
        expect(subject.handle(sid, to, from, 'pirate plunder kind of blue by miles davis')).to be true
        expect(subject.vendor).to eq vendor
        expect(subject.outbound_recipient).to be from
        expect(subject.inbound_recipient).to eq vendor.from_phone
        expect(subject.response_text).to be nil
      end

      context " adding response text: 'ok' to the keyword" do
        # Note: had to set the @keyword var in the :all block for this to work (?)
        it "responds with 'ok'" do
          @keyword.update_attribute(:response_text, 'ok')
          expect(subject.handle(sid, to, from, 'pirate plunder kind of blue by miles davis')).to be true
          expect(subject.response_text).to eq 'ok'
        end
      end

      context 'an account WITHOUT custom stop text, help text, or default response text' do
        it "responds to 'pirate stop' with vendor stop text" do
          expect(subject.handle(sid, to, from, 'pirate stop')).to be true
          expect(subject.response_text).to eql(Service::Keyword::DEFAULT_STOP_TEXT)
        end
        it "responds to 'pirate help' with vendor help text" do
          expect(subject.handle(sid, to, from, 'pirate help')).to be true
          expect(subject.response_text).to eql(Service::Keyword::DEFAULT_HELP_TEXT)
        end
        it "responds to 'pirate nothin' with nothing" do
          expect(subject.handle(sid, to, from, 'pirate nothin')).to be true
          expect(subject.response_text).to be_nil
        end
      end

      context 'an account WITH custom stop text, help text, and default response text' do
        before :each do
          stop_keyword               = @account.stop_keyword
          stop_keyword.response_text = 'oh sorry'
          stop_keyword.save
          help_keyword               = @account.help_keyword
          help_keyword.response_text = 'maybe later'
          help_keyword.save
          default_keyword               = @account.default_keyword
          default_keyword.response_text = 'wat'
          default_keyword.save
        end
        it "responds to 'pirate stop' with account stop text" do
          expect(subject.handle(sid, to, from, 'pirate stop')).to be true
          expect(subject.response_text).to eql('oh sorry')
        end
        it "responds to 'pirate help' with account help text" do
          expect(subject.handle(sid, to, from, 'pirate help')).to be true
          expect(subject.response_text).to eql('maybe later')
        end
        it "responds to 'pirate nothin' with account default response text" do
          expect(subject.handle(sid, to, from, 'pirate nothin')).to be true
          expect(subject.response_text).to eq 'wat'
        end
      end
    end
  end

  def create_account(prefix, keyword, vendor)
    account = create(:account_with_sms, prefix: prefix, sms_vendor: vendor)
    account.create_command!(keyword, params: {command_type: :forward,
                                              http_method:  'POST',
                                              url:          'http://what.cd'},
                            command_type:    :forward)
    account.save!
    account
  end

  def twilio_request_params(body, vendor)
    @sid ||= ('0' * 34)
    @sid.succ!
    {format:      'xml',
     'SmsSid'     => @sid,
     'MessageSid' => @sid,
     'AccountSid' => vendor.username,
     'From'       => vendor.username,
     'To'         => vendor.from_phone,
     'Body'       => body}
  end

end