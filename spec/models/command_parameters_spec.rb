require File.expand_path('../../../app/concerns/mass_assignment', __FILE__)
require File.expand_path('../../../app/models/command_parameters', __FILE__)
require File.expand_path('../../little_spec_helper', __FILE__)

describe CommandParameters do
  let(:params) do
    CommandParameters::PARAMS.inject({}) do |hsh, param|
      hsh.merge(param => "#{param} value")
    end
  end

  let(:command_parameters) { CommandParameters.new(params)}

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
end