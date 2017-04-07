require 'airborne'
require 'rails_helper'

describe 'One-time session' do
  EnvConfig = Struct.new(:auth_token, :host)

  def test_env
    ENV['XACT_ENV'] || Rails.env
  end

  def env_config
    if ['test', 'development'].include? test_env
      EnvConfig.new 'xta4wdrqpACsxFckXpWM784cWyrU96P2', 'http://localhost:3000'
    elsif 'qc' == test_env
      # pigeon@govdelivery.com
      EnvConfig.new 'hyArYV1PUMP5WAZZqgWeBfLPg7M82pRk', 'https://qc-tms.govdelivery.com'
    else
      raise "Environment #{test_env} not configured in sessions_spec.rb"
    end
  end

  context 'valid token' do
    before(:each) { FakeWeb.allow_net_connect = true }
    let!(:token) do
      get "#{env_config.host}/user/login", { 'X-AUTH-TOKEN' => env_config.auth_token }
      json = JSON.parse(response.body)
      json['_links']['session'].split('token=')[1]
    end
    scenario 'gets proper cookie' do
      begin

        post "#{env_config.host}/session/new", { 'token' => "#{token}" }

        cookie = response.headers[:set_cookie].first
        expect(cookie).to include '_xact_session='
        expect(cookie).to include 'HttpOnly'
        expect(cookie).to include 'secure' unless Rails.env.test? || Rails.env.development?
      ensure
        FakeWeb.allow_net_connect = false
      end
    end
  end
end 