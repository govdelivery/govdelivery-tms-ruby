require 'rails_helper'

describe SmsTemplate do
  it {is_expected.to belong_to :account}
  it {is_expected.to belong_to :user}
  it {is_expected.to validate_presence_of :body}
  it {is_expected.to validate_presence_of :user}
  it {is_expected.to validate_presence_of :account}

  let(:account) {create(:account)}
  let(:user) {account.users.create(email: 'test@evotest.govdelivery.com', password: 'test_password')}

  subject {create(:sms_template, account: account, user: user)}

  it 'should validate that template has a body that is of valid length' do
    # 160 characters body -- the maximum
    subject.body = 'x' * 160
    expect(subject).to be_valid

    # 161 characters body -- the maximum plus one
    subject.body = 'x' * 161
    expect(subject).not_to be_valid
    expect(subject.errors.messages).to include(body: ["is too long (maximum is 160 characters)"])

    subject.body = nil
    expect(subject).not_to be_valid
    expect(subject.errors.messages).to include(body: ["can't be blank"])
  end

  it "should default to user's account on creation" do
    sms_template = user.account.sms_templates.create(body: 'hello')
    expect(sms_template.account).to eql user.account
  end

  it "should verify user belongs to the account" do
    other_account = create(:account)
    subject.account = other_account
    expect(subject).not_to be_valid
    expect(subject.errors.messages).to include(user: ['must belong to same account as sms template'])
  end

  it "should verify user belongs to the account" do
    other_user = create(:user)
    subject.user = other_user
    expect(subject).not_to be_valid
    expect(subject.errors.messages).to include(user: ['must belong to same account as sms template'])
  end
end
