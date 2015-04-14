# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/its'
require 'celluloid/test'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

FakeWeb.allow_net_connect = false

RSpec.configure do |config|
  config.include ActionView::TestCase::Behavior, file_path: %r{spec/presenters}
  config.mock_with :mocha
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.use_transactional_fixtures                 = true
  config.infer_base_class_for_anonymous_controllers = true
  config.order                                      = 'random'
  config.infer_spec_type_from_file_location!

  # Sidekiq needs this, requiring fakeredis/rspec isn't enough
  fakeredis_opts = {
    url:       'redis://127.0.0.1:6379/1',
    namespace: 'spec',
    driver:    Redis::Connection::Memory }

  Sidekiq.configure_client do |conf|
    conf.redis = fakeredis_opts
  end

  Sidekiq.configure_server do |conf|
    conf.redis = fakeredis_opts
  end
end

RSpec::Matchers.define :be_a_valid_twilio_sms_response do
  match do |response|
    xml_doc = Nokogiri::XML(response.body)
    !xml_doc.xpath('/Response//Sms').empty?
  end
  failure_message do |response|
    "expected \n\n#{response.body}\n to be a valid Twilio SMS response"
  end
end

def stub_command_action_create!(command_params, http_response, command_action, body = http_response.body)
  command_action.expects(:update!).with(
    error_message: nil,
    status:        http_response.status,
    content_type:  http_response.try(:headers).try(:[], 'Content-Type'),
    response_body: body).returns(command_action)
  CommandAction.expects(:where).with(
    inbound_message_id: command_params.inbound_message_id,
    command_id:         command_params.command_id).returns(
      mock('first_or_initialize', first_or_initialize: command_action)
    )
end

def stub_command_action_error!(command_params, command_action, error_message)
  mock_relation = stub('CommandAction.where', success: false)
  mock_relation.expects(:update!).with(
    error_message: error_message,
    status:        nil,
    content_type:  nil,
    response_body: nil).returns(command_action)
  CommandAction.expects(:where).with(
    inbound_message_id: command_params.inbound_message_id,
    command_id:         command_params.command_id).returns(
      mock('first_or_initialize', first_or_initialize: mock_relation)
    )
end

def exception_check(worker, expected_message, params = nil)
  begin
    if params
      worker.perform(params)
    else
      worker.perform
    end
  rescue Java.java.lang::Throwable
    java_exception_raised = false
  rescue StandardError => rex
    ruby_exception_raised = true
    expect(rex.message).to eq(expected_message)
  end

  expect(java_exception_raised).to be_falsey
  expect(ruby_exception_raised).to be_truthy
end

def stub_pagination(collection, current_page, total_pages)
  collection.stubs(:current_page).returns(current_page)
  collection.stubs(:total_pages).returns(total_pages)
  collection.stubs(:first_page?).returns(current_page == 1)
  collection.stubs(:last_page?).returns(current_page == total_pages)
end
