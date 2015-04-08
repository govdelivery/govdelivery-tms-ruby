require 'rails_helper'

describe CommandParameters do
  let(:params) do
    CommandParameters::PARAMS.inject({}) do |hsh, param|
      hsh.merge(param => "#{param} value")
    end
  end

  let(:command_type) do
    stub(string_fields: [:dcm_account_code, :username],
         array_fields: [:dcm_topic_codes],
         required_string_fields: [:dcm_account_code, :username],
         required_array_fields: [:dcm_topic_codes],
         name: :test_command_type)
  end

  let(:account) do
    stub(dcm_account_codes: ["AB"])
  end

  let(:command_parameters) { CommandParameters.new(params)}

  let(:empty_parameters) do
    c = CommandParameters.new
    c.command_type = command_type
    c.account      = account
    c
  end

  it "should convert to hash correctly" do
    hash = command_parameters.to_hash
    CommandParameters::PARAMS.each do |p|
      expect(command_parameters.send(p)).to eq("#{p} value")
    end
    command_parameters.account_id = nil
    expect(command_parameters.to_hash.has_key?(:account_id)).to eq(false)
  end

  it "should merge correctly" do
    other_parameters = CommandParameters.new(account_id: 10, sms_body: nil)

    command_parameters.merge!(other_parameters)

    # properties in other_parameters should replace properties in command_parameters
    expect(command_parameters.account_id).to eq(10)

    # nil stuff should not override existing properties
    expect(command_parameters.sms_body).to eq("sms_body value")
  end

  it "should validate empty parameters" do
    expect(empty_parameters).to be_invalid
    expect(empty_parameters.errors[:username]).to eq(["can't be blank"])
    expect(empty_parameters.errors[:dcm_topic_codes]).to include("can't be blank")
    expect(empty_parameters.errors[:dcm_topic_codes]).to include("must be an array")
    empty_parameters.username = :foo
    empty_parameters.dcm_account_code = "AB"
    empty_parameters.dcm_topic_codes = [:foo]

    empty_parameters.valid?
    expect(empty_parameters).to be_valid

  end

  it "should have default values for some params" do
    # nil case
    expect(empty_parameters.sms_body_param_name).to eq("sms_body")
    expect(empty_parameters.from_param_name).to eq("from")
    expect(empty_parameters.strip_keyword).to be_nil

    # the parameter has been set
    expect(command_parameters.sms_body_param_name).to eq("sms_body_param_name value")
    expect(command_parameters.from_param_name).to eq("from_param_name value")
    expect(command_parameters.strip_keyword).to eq("strip_keyword value")
  end

  it ".to_hash should include params with empty and false values" do
    empty_parameters.sms_tokens = []
    empty_parameters.sms_body = ""
    empty_parameters.strip_keyword = false

    expect(empty_parameters.to_hash[:sms_tokens]).to eq([])
    expect(empty_parameters.to_hash[:sms_body]).to eq("")
    expect(empty_parameters.to_hash[:strip_keyword]).to eq(false)
  end
end
