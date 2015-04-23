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
        subject {create(factory_symbol)}
      end

      it 'should be invalid when not an email' do
        subject.send("#{email_meth}=", 'invalid')
        expect(subject).not_to be_valid
        expect(subject.errors.get(email_meth)).not_to be_nil
      end

      it 'should be invalid when too long' do
        # adds up to 256 characters
        subject.send("#{email_meth}=", 'five@' + 'e' * 246 + '.five')
        expect(subject).not_to be_valid
        expect(subject.errors.get(email_meth)).not_to be_nil
      end
    end
  end
end
