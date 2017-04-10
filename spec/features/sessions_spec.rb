require 'airborne'
require 'rails_helper'

describe 'One-time session', if: ENV['XACT_ENV'] do
  EnvConfig = Struct.new(:auth_token, :host)

  def test_env
    ENV['XACT_ENV']
  end

  def env_config
    @env_config ||= build_env_config
  end

  def build_env_config
    case test_env
    when 'development'
      EnvConfig.new 'xta4wdrqpACsxFckXpWM784cWyrU96P2', 'http://localhost:3000'
    when 'qc'
      # pigeon@govdelivery.com
      EnvConfig.new 'hyArYV1PUMP5WAZZqgWeBfLPg7M82pRk', 'https://qc-tms.govdelivery.com'
    else
      raise "ENV['XACT_ENV'] #{test_env} not configured for sessions_spec"
    end
  end

  before(:each) { FakeWeb.allow_net_connect = true }
  after(:each) { FakeWeb.allow_net_connect = false }

  context 'valid token' do
    let!(:token) do
      get "#{env_config.host}/user/login", { 'X-AUTH-TOKEN' => env_config.auth_token }
      json = JSON.parse(response.body)
      json['_links']['session'].split('token=')[1]
    end
    scenario 'gets proper cookie' do
      post "#{env_config.host}/session/new", { 'token' => "#{token}" }

      cookie = response.headers[:set_cookie].first
      expect(cookie).to include '_xact_session='
      expect(cookie).to include 'HttpOnly'
      expect(cookie).to include 'secure' unless Rails.env.test? || Rails.env.development?
    end
  end
  context 'invalid token' do
    scenario 'gets proper cookie' do
      post "#{env_config.host}/session/new", { 'token' => 'abcd1234' }

      expect(response).to eq('{"error":"Failed to Login"}')
    end
  end
end
