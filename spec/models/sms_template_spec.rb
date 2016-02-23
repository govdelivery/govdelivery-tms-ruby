require 'rails_helper'

describe SmsTemplate do
  it {is_expected.to belong_to :account}
  it {is_expected.to belong_to :user}

  it {is_expected.to validate_presence_of :body}
  it {is_expected.to validate_presence_of :user}
  it {is_expected.to validate_presence_of :account}

  it {is_expected.to validate_length_of :uuid}

  let(:account) {create(:account)}
  let(:other_account) {create(:account)}
  let(:user) {account.users.create(email: 'test@evotest.govdelivery.com', password: 'test_password')}

  subject {create(:sms_template, account: account, user: user, body: 'x' * 100)}

  context 'body field validation' do
    it 'should validate the body can be >= 160 characters' do
      subject.body = 'x' * 160
      expect(subject).to be_valid
    end
    it 'should validate that the body cannot be > 160 characters' do
      subject.body = 'x' * 161
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to include(body: ["is too long (maximum is 160 characters)"])
    end
    it 'should validate that the body cannot be empty' do
      subject.body = ''
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to include(body: ["can't be blank"])
    end
  end

  it 'should validate that user belongs to account' do
    expect(subject).to be_valid
    other_user   = other_account.users.create(email: 'test2@evotest.govdelivery.com', password: 'test_password', uuid: 'testTemplate1')
    subject.user = other_user
    expect(subject).not_to be_valid
    expect(subject.errors.messages).to include(user: ['must belong to same account as sms template'])
  end

  context 'uuid validation' do
    it 'should not allow uuid to be updated' do
      subject.uuid = "new-updated-uuid"
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to include(uuid: ["cannot be updated"])
    end
    it 'should validate uuids <= 128 characters' do
      template = create(:sms_template, account: account, user: user, body: 'x' * 100, uuid: 'x' * 128)
      expect(template).to be_valid
    end
    it 'should update uuids to id if not supplied' do
      expect(subject).to be_valid
      expect(subject.uuid).to eql(subject.id.to_s)
    end
    it 'should not validate uuids > 128 characters' do
      subject.uuid = 'x' * 129
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to include(uuid: ["is too long (maximum is 128 characters)","cannot be updated"])
    end
    it 'should validate uuids allow appropriate characters' do
      template = create(:sms_template, account: account, user: user, body: 'x' * 100, uuid: 'ajzAJZ0-1_2')
      expect(template).to be_valid
    end
    it 'should validate uuids cannot have non-allowed characters' do
      subject.uuid = 'x!;' * 10
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to include(uuid: ["only letters, numbers, -, and _ are allowed","cannot be updated"])
    end
    it 'should validate uuids cannot have spaces' do
      subject.uuid = 'x ' * 10
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to include(uuid: ["only letters, numbers, -, and _ are allowed","cannot be updated"])
    end
    it 'should allow other accounts to create templates with the same uuid' do
      other_user   = other_account.users.create(email: 'test2@evotest.govdelivery.com', password: 'test_password')
      new_template = create(:sms_template, account: other_account, user: other_user, uuid: subject.uuid, body: 'x' * 100)
      expect(new_template).to be_valid
      expect(subject).to be_valid
    end
    it 'should not allow the same account to have templates with the same uuid' do
      new_template = create(:sms_template, account: account, user: user, uuid: "new_uuid", body: 'x' * 100)
      expect(new_template).to be_valid
      expect(subject).to be_valid
      subject.uuid = "new_uuid"
      expect(subject).not_to be_valid
    end
    it 'should not allow different users on the same account to have templates with the same uuid' do
      other_user   = account.users.create(email: 'test2@evotest.govdelivery.com', password: 'test_password', uuid: 'testTemplate1')
      new_template = create(:sms_template, account: account, user: other_user, uuid: "new_uuid", body: 'x' * 100)
      expect(new_template).to be_valid
      expect(subject).to be_valid
      subject.uuid = "new_uuid"
      expect(subject).not_to be_valid
    end
  end

  it "should default to user's account on creation" do
    sms_template = user.account.sms_templates.create(body: 'hello', uuid: 'testTemplate')
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
