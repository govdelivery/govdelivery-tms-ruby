require 'rails_helper'
describe WebhookWorker do
  let(:connection) { stub('faraday OK', post: stub('response', status: 200)) }
  let(:connection_timeout) do
    stub('faraday timeout').tap do |obj|
      obj.stubs(:post).raises(Faraday::TimeoutError, 'timeout')
    end
  end
  let(:connection_404) do
    stub('faraday 404').tap do |obj|
      obj.stubs(:post).raises(Faraday::Error::ResourceNotFound, status: 404, headers: {}, body: 'nope')
    end
  end

  let(:connection_500) do
    stub('faraday 500').tap do |obj|
      obj.stubs(:post).raises(Faraday::Error::ClientError, status: 500, headers: {}, body: 'nope')
    end
  end

  subject { WebhookWorker.new }
  it 'should work real nice' do
    subject.stubs(:connection).returns(connection)
  end

  it 'should fail on timeout' do
    subject.stubs(:connection).returns(connection_timeout)
    expect do
      subject.perform('url' => 'http://www.google.com', 'params' => { hi: 'true' })
    end.to raise_error(Faraday::Error::TimeoutError)
  end

  it 'should fail on 500' do
    subject.stubs(:connection).returns(connection_500)
    expect do
      subject.perform('url' => 'http://www.google.com', 'params' => { hi: 'true' })
    end.to raise_error(Faraday::Error::ClientError)
  end

  it 'should ignore 404' do
    subject.stubs(:connection).returns(connection_404)
    subject.perform('url' => 'http://www.google.com', 'params' => { hi: 'true' })
  end
end
