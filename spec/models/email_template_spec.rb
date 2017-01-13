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

  it "should validate liquid templates" do
    expect(subject).to be_valid
    subject.body = 'Hello {{name }'
    expect(subject).not_to be_valid
    expect(subject.errors.messages).to include(body: ['cannot include invalid Liquid markup'])

    subject.body = 'Hello {{name }}'
    expect(subject).to be_valid
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
      template = create(:email_template, account: account, user: user, from_address: from_address, uuid: 'ajzAJZ0-1_2')
      expect(template).to be_valid
    end
    it 'should not allow the uuid to be updated' do
      subject.uuid = "new-template-name"
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to include(uuid: ["cannot be updated"])
    end
    it 'uuid should be the same as id if not set' do
      expect(subject).to be_valid
      expect(subject.uuid).to eql(subject.id.to_s)
    end
    it 'should not validate uuids > 128 characters' do
      subject.uuid = 'x' * 129
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to include(uuid: ["is too long (maximum is 128 characters)","cannot be updated"])
    end
    it 'empty string defaults to uuid' do
      template = create(:email_template, account: account, user: user, from_address: from_address, uuid: 'ajzAJZ0-1_2')
      expect(template).to be_valid
    end
    it 'should validate uuids allow appropriate characters' do
      template = create(:email_template, account: account, user: user, from_address: from_address, uuid: '')
      expect(template).to be_valid
      expect(template.uuid).to eql(template.id.to_s)
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
    it 'should allow other accounts to create same-uuidd templates' do
      other_user   = other_account.users.create(email: 'test2@evotest.govdelivery.com', password: 'test_password', uuid: 'testTemplate1')
      expect(subject).to be_valid
      new_template = create(:email_template, account: other_account, user: other_user, from_address: other_account.default_from_address, uuid: subject.uuid)
      expect(new_template).to be_valid
      expect(subject).to be_valid
    end
    it 'should not allow the same account to have same-uuidd templates' do
      new_template = create(:email_template, account: account, user: user, from_address: account.default_from_address, uuid: default_uuid)
      expect(new_template).to be_valid
      expect(subject).to be_valid
      subject.uuid = default_uuid
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to include(uuid: ["has already been taken","cannot be updated"])
    end
    it 'should not allow different users on the same account to have same-uuidd templates' do
      other_user   = account.users.create(email: 'test2@evotest.govdelivery.com', password: 'test_password', uuid: 'testTemplate1')
      new_template = create(:email_template, account: account, user: other_user, from_address: account.default_from_address, uuid: "new_uuid")
      expect(new_template).to be_valid
      expect(subject).to be_valid
      subject.uuid = "new_uuid"
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to include(uuid: ["has already been taken","cannot be updated"])
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
      expect{subject.save!}.to raise_error(ActiveRecord::RecordInvalid)
      subject.open_tracking_enabled = true
      subject.click_tracking_enabled = nil
      expect{subject.save!}.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context 'MessageType' do
    let(:template_params){{body: 'hello', subject: 'greetings'}}
    # these are the steps to set the message_type
    let(:template){ subject.message_type_code = 'salutations'; subject.save!; subject; }
    it 'should save with just code' do
      email_template = user.email_templates.create(template_params.merge(message_type_code: 'type_a'))
      expect(email_template.message_type.code).to eq( 'type_a' )
      expect(email_template.message_type.label).to eq( 'Type A' )
    end

    it 'should save with label and code' do
      email_template = user.email_templates.create(template_params.merge(message_type_code: 'type_b', message_type_label: 'Type B'))
      expect(email_template.message_type.code).to eq( 'type_b' )
      expect(email_template.message_type.label).to eq( 'Type B' )
      expect(email_template.message_type).to be_persisted
    end

    it 'should not save with just label' do
      email_template = user.email_templates.create(template_params.merge(message_type_label: 'Type B'))
      expect(email_template.errors[:message_type_label]).to be_present
      expect(email_template).to be_new_record
    end

    it 'should resolve message_type_code from message_type' do
      new_template = EmailTemplate.find(template.id)
      expect(new_template.message_type_code).to eql('salutations')
    end

    it 'should remove message_type when updating with message_type_code set to nil' do
      template.message_type_code = nil
      template.save!
      template.reload
      expect(template.message_type).to be_nil
      expect(template.message_type_code).to be_nil
    end
  end
end
