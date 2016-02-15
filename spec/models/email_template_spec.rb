require 'rails_helper'

describe EmailTemplate do
  it {is_expected.to belong_to :account}
  it {is_expected.to belong_to :user}
  it {is_expected.to belong_to :from_address}
  it {is_expected.to serialize :macros}
  it {is_expected.to validate_presence_of :body}
  it {is_expected.to validate_presence_of :subject}
  it {is_expected.to validate_presence_of :user}
  it {is_expected.to validate_presence_of :account}
  it {is_expected.to validate_presence_of :from_address}

  let(:account) {create(:account)}
  let(:other_account) {create(:account)}
  let(:default_uuid) {'test_tempalte'}
  let(:user) {account.users.create(email: 'test@evotest.govdelivery.com', password: 'test_password')}
  let(:from_address) {account.default_from_address}

  subject {create(:email_template, account: account, user: user, from_address: from_address)}

  it 'should use default from address if not specified' do
    create(:email_template, account: account, user: user, from_address: nil, uuid: 'testTemplate').from_address.should eq account.default_from_address
  end

  it 'should validate macros' do
    expect(subject).to be_valid
    subject.macros = 'Not a Hash'
    expect(subject).not_to be_valid
    expect(subject.errors.messages).to include(macros: ['must be a hash or null'])
  end

  it 'should validate that user belongs to account' do
    expect(subject).to be_valid
    other_user   = other_account.users.create(email: 'test2@evotest.govdelivery.com', password: 'test_password', uuid: 'testTemplate1')
    subject.user = other_user
    expect(subject).not_to be_valid
    expect(subject.errors.messages).to include(user: ['must belong to same account as email template'])
  end

  context 'uuid validation' do
    it 'should validate uuids <= 128 characters' do
      subject.uuid = 'x' * 128
      expect(subject).to be_valid
    end
    it 'uuid should be the same as id if not set' do
      expect(subject).to be_valid
      expect(subject.uuid).to eql(subject.id.to_s)
    end
    it 'should not validate uuids > 128 characters' do
      subject.uuid = 'x' * 129
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to include(uuid: ["is too long (maximum is 128 characters)"])
    end
    it 'should validate uuids allow appropriate characters' do
      subject.uuid = 'ajzAJZ0-1_2'
      expect(subject).to be_valid
    end
    it 'should validate uuids cannot have non-allowed characters' do
      subject.uuid = 'x!;' * 10
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to include(uuid: ["only letters, numbers, -, and _ are allowed"])
    end
    it 'should validate uuids cannot have spaces' do
      subject.uuid = 'x ' * 10
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to include(uuid: ["only letters, numbers, -, and _ are allowed"])
    end
    it 'should allow other accounts to create same-uuidd templates' do
      other_user   = other_account.users.create(email: 'test2@evotest.govdelivery.com', password: 'test_password', uuid: 'testTemplate1')
      new_template = create(:email_template, account: other_account, user: other_user, from_address: other_account.default_from_address, uuid: default_uuid)
      expect(new_template).to be_valid
      subject.uuid = default_uuid
      expect(subject).to be_valid
    end
    it 'should not allow the same account to have same-uuidd templates' do
      new_template = create(:email_template, account: account, user: user, from_address: account.default_from_address, uuid: default_uuid)
      expect(new_template).to be_valid
      expect(subject).to be_valid
      subject.uuid = default_uuid
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to include(uuid: ["has already been taken"])
    end
    it 'should not allow different users on the same account to have same-uuidd templates' do
      other_user   = account.users.create(email: 'test2@evotest.govdelivery.com', password: 'test_password', uuid: 'testTemplate1')
      new_template = create(:email_template, account: account, user: other_user, from_address: account.default_from_address, uuid: "new_uuid")
      expect(new_template).to be_valid
      expect(subject).to be_valid
      subject.uuid = "new_uuid"
      expect(subject).not_to be_valid
    end
  end

  it 'should validate that from_address belongs to account' do
    expect(subject).to be_valid
    subject.from_address = other_account.default_from_address
    expect(subject).not_to be_valid
    expect(subject.errors.messages).to include(from_address: ['must belong to same account as email template'])
  end

  context 'building a template with nil *_tracking_enabled' do
    subject {build(:email_template,
                   account: account,
                   user: user,
                   from_address: from_address,
                   open_tracking_enabled: nil,
                   click_tracking_enabled: nil,
                   uuid: 'testTemplate'
    )}

    it 'default for open_tracking_enabled and click_tracking_enabled should be true on save' do
      subject.save!
      expect(subject).to be_valid
      expect(subject.open_tracking_enabled).to eq true
      expect(subject.click_tracking_enabled).to eq true
    end
  
    it 'open_tracking_enabled and click_tracking_enabled can and must be true or false on save' do
      subject.open_tracking_enabled = true
      subject.click_tracking_enabled = true
      expect{subject.save!}.not_to raise_error
      subject.open_tracking_enabled = false
      subject.click_tracking_enabled = false
      expect{subject.save!}.not_to raise_error

      subject.open_tracking_enabled = nil
      expect{subject.save!}.to raise_error
      subject.open_tracking_enabled = true
      subject.click_tracking_enabled = nil
      expect{subject.save!}.to raise_error
    end
  end
end
