require 'rails_helper'

describe MessageType do
  subject {create(:message_type)}
  it {is_expected.to be_valid}
  it {is_expected.to validate_presence_of(:label)}
  it {is_expected.to validate_presence_of(:code)}

  context 'when code has a space' do
    subject {build(:message_type, code: 'steve mcqueen').tap(&:valid?)}
    its(:errors) {should include(:code)}
  end

  context 'when code is, like, weird' do
    subject {build(:message_type, code: 'asd-fsd784tawt34a0w9erts897dfg*&^&*').tap(&:valid?)}
    its(:errors) {should include(:code)}
  end

  context 'when code is updated' do
    subject {create(:message_type)}
    it 'should throw an error' do
      expect do
        subject.code = 'bob'
        subject.save!
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context 'when duplicated' do
    subject {create(:message_type)}
    it 'should throw an error in same account' do
      expect do
        create(:message_type, account: subject.account)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
    it 'should not throw an error in different account' do
      expect do
        create(:message_type)
      end.not_to raise_error
    end
  end
end
