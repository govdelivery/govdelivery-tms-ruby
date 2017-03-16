require 'rails_helper'

describe OneTimeSessionToken do
  let(:token) {create(:one_time_session_token)}
  subject {token}

  context 'when valid' do
    specify {expect(subject.valid?).to eq(true)}
    specify {expect(subject.value).not_to be_nil}
    specify {expect(subject.user_id).not_to be_nil}
  end

  it 'should not change token value for multiple validations' do
    old_value = subject.value
    new_value = subject.value
    expect(old_value).to eq(new_value)
  end

  context 'when user_id is empty' do
    before {subject.user_id = nil}
    specify {expect(subject.valid?).to eq(false)}
  end

  it 'should find user by token and destroy token' do
    expect(OneTimeSessionToken.user_for(subject.value)).to eq(subject.user)
    expect{OneTimeSessionToken.find(subject.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end
end
