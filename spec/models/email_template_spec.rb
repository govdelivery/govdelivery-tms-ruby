require 'rails_helper'

describe EmailTemplate do
  it { is_expected.to belong_to :account }
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :from_address }
  it { is_expected.to serialize :macros }
  it { is_expected.to validate_presence_of :body }
  it { is_expected.to validate_presence_of :subject }
  it { is_expected.to validate_presence_of :user }
  it { is_expected.to validate_presence_of :account }
  it { is_expected.to validate_presence_of :from_address }

  let(:account) { create(:account) }
  let(:other_account) { create(:account) }
  let(:user) { account.users.create(email: 'test@evotest.govdelivery.com', password: 'test_password') }
  let(:from_address) { account.default_from_address }

  subject { create(:email_template, account: account, user: user, from_address: from_address) }

  it 'should validate macros' do
    expect(subject).to be_valid
    subject.macros = 'Not a Hash'
    expect(subject).not_to be_valid
    expect(subject.errors.messages).to include(macros: ['must be a hash or null'])
  end

  it 'should validate that user belongs to account' do
    expect(subject).to be_valid
    other_user = other_account.users.create(email: 'test2@evotest.govdelivery.com', password: 'test_password')
    subject.user = other_user
    expect(subject).not_to be_valid
    expect(subject.errors.messages).to include(user: ['must belong to same account as email template'])
  end

  it 'should validate that from_address belongs to account' do
    expect(subject).to be_valid
    subject.from_address = other_account.default_from_address
    expect(subject).not_to be_valid
    expect(subject.errors.messages).to include(from_address: ['must belong to same account as email template'])
  end
end
