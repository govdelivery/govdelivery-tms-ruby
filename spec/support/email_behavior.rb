##
# This assumes your email field has a max of 255 chars.
# It also assumes that you have a factory for the class, i.e. 
# EmailMessage => create(:email_message)
#
def it_should_validate_as_email(*args)
  # ModelClass => :model_class
  factory_symbol = described_class.name.underscore.to_sym

  args.each do |email_meth|
    context "##{email_meth}" do
      before do 
        subject{ create(factory_symbol) }
      end 

      it "should be invalid when not an email" do
        subject.send("#{email_meth}=", 'invalid')
        subject.should_not be_valid
        subject.errors.get(email_meth).should_not be_nil
      end

      it "should be invalid when too long" do
        # adds up to 256 characters
        subject.send("#{email_meth}=", 'five@' + 'e' * 246 + '.five')
        subject.should_not be_valid
        subject.errors.get(email_meth).should_not be_nil
      end
    end
  end
end