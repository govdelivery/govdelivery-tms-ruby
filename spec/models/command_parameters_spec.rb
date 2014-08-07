require 'rails_helper'

describe CommandParameters do
  let(:params) do
    CommandParameters::PARAMS.inject({}) do |hsh, param|
      hsh.merge(param => "#{param} value")
    end
  end

  let(:command_type) do
    stub(:string_fields => [:dcm_account_code, :username],
         :array_fields => [:dcm_topic_codes],
         :required_string_fields => [:dcm_account_code, :username],
         :required_array_fields => [:dcm_topic_codes],
         :name => :test_command_type)
  end

  let(:account) do
    stub(:dcm_account_codes => ["AB"])
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
      command_parameters.send(p).should eq("#{p} value")
    end
    command_parameters.account_id = nil
    command_parameters.to_hash.has_key?(:account_id).should == false
  end

  it "should merge correctly" do
    other_parameters = CommandParameters.new(:account_id => 10, :sms_body => nil)

    command_parameters.merge!(other_parameters)

    # properties in other_parameters should replace properties in command_parameters
    command_parameters.account_id.should eq(10)

    # nil stuff should not override existing properties
    command_parameters.sms_body.should eq("sms_body value")
  end

  it "should validate empty parameters" do
    empty_parameters.should be_invalid
    empty_parameters.errors[:username].should eq(["can't be blank"])
    empty_parameters.errors[:dcm_topic_codes].should include("can't be blank")
    empty_parameters.errors[:dcm_topic_codes].should include("must be an array")
    empty_parameters.username = :foo
    empty_parameters.dcm_account_code = "AB"
    empty_parameters.dcm_topic_codes = [:foo]

    empty_parameters.valid?
    empty_parameters.should be_valid

  end

  it "should have default values for some params" do
    # nil case
    empty_parameters.sms_body_param_name.should eq("sms_body")
    empty_parameters.from_param_name.should eq("from")
    empty_parameters.strip_keyword.should be_nil

    # the parameter has been set
    command_parameters.sms_body_param_name.should eq("sms_body_param_name value")
    command_parameters.from_param_name.should eq("from_param_name value")
    command_parameters.strip_keyword.should eq("strip_keyword value")
  end

  it "should not allow expected_content_type to be application/json" do
    command_parameters = build(:forward_command_parameters, expected_content_type: 'application/json').tap(&:valid?)
    command_parameters.errors.should include(:expected_content_type)
  end

  it "should default expected_content_type to text/plain" do
    command_parameters = build(:forward_command_parameters, expected_content_type: nil).tap(&:valid?)
    command_parameters.expected_content_type.should eql('text/plain')
  end

end
