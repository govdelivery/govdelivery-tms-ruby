# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
# breaks zeus
# require 'rspec/autorun'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|

  config.mock_with :mocha

  config.use_transactional_fixtures = true

  config.infer_base_class_for_anonymous_controllers = false

  config.order = "random"
end

def stub_command_action_create!(command_params, http_response, command_action)
  mock_relation = mock('CommandAction.where')
  mock_relation.expects(:first_or_create!).with(
    status: http_response.status,
    content_type: http_response.headers['Content-Type'],
    response_body: http_response.body).returns(command_action)
  CommandAction.expects(:where).with(
    inbound_message_id: command_params.inbound_message_id,
    command_id: command_params.command_id).returns(mock_relation)
end

def exception_check(worker, expected_message, params=nil)
  begin
    if params
      worker.perform(params)
    else
      worker.perform
    end
  rescue Java::java::lang::Throwable  => jt
    java_exception_raised = false
  rescue Exception => rex
    ruby_exception_raised = true
    rex.message.should eq(expected_message)
  end

  java_exception_raised.should be_false
  ruby_exception_raised.should be_true
end
