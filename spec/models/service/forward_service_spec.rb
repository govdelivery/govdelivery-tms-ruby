require_relative '../../../app/concerns/mass_assignment'
require_relative '../../../app/models/service/forward_service'
require_relative '../../little_spec_helper'

describe Service::ForwardService do
  let(:client) { Service::ForwardService.new }
  let(:body) { { :foo => :bar } }
  let(:url) { "http://www.foo.com/a/sub/dir" }

  it 'should post the parameters' do
    req = stub("request object", headers: {})
    req.expects(:body=).with(body)
    post = mock("post object")
    post.expects(:post).with(url).yields(req)
    client.expects(:connection).with(nil, nil).returns(post)
    client.post(url, nil, nil, body)
  end

  it 'should get the parameters' do
    req = stub("request object", headers: {})
    req.expects(:params=).with(body)
    get = mock("get object")
    get.expects(:get).with(url).yields(req)
    client.expects(:connection).with(nil, nil).returns(get)

    client.get(url, nil, nil, body)
  end
end
