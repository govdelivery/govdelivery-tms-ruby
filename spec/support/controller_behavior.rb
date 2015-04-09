def it_should_create_a_message(message_opts = {}, worker = CreateRecipientsWorker)
  describe '#create with a valid message' do
    before do
      model.any_instance.expects(:save_with_async_recipients).returns(true)
      model.any_instance.stubs(:new_record?).returns(false)

      worker.expects(:perform_async).with(anything).returns(true)
      post :create, message: message_opts
    end
    it 'should be accepted' do
      expect(response.response_code).to eq 201
    end
  end

  describe '#create with an invalid message' do
    before do
      model.any_instance.expects(:save_with_async_recipients).returns(false)
      model.any_instance.stubs(:new_record?).returns(true)
      post :create, message: message_opts
    end

    it 'should be unprocessable_entity' do
      expect(response.response_code).to eq 422
    end
  end
end

def it_should_have_a_pageable_index(resource, parent_class = User, relation = nil)
  describe 'index' do
    before do
      send(resource).stubs(:total_pages).returns(5)
      @params  = block_given? ? yield(self) : {}
      relation ||= model.to_s.tableize
      pageable = stub('pageable', page: send(resource))
      pageable.stubs(:includes).returns(pageable)
      parent_class.any_instance.expects(relation).returns(pageable)
    end
    it 'should work on the first page' do
      send(resource).stubs(:current_page).returns(1)
      send(resource).stubs(:first_page?).returns(true)
      send(resource).stubs(:last_page?).returns(false)
      get :index, @params
      expect(response.response_code).to eq 200
    end

    it 'should have all links' do
      r = send(resource)
      r.stubs(:current_page).returns(2)
      r.stubs(:first_page?).returns(false)
      r.stubs(:last_page?).returns(false)
      get :index, { page: 2 }.merge!(@params)
      expect(response.headers['Link']).to match(/first/)
      expect(response.headers['Link']).to match(/prev/)
      expect(response.headers['Link']).to match(/next/)
      expect(response.headers['Link']).to match(/last/)
    end

    it 'should have prev and first links' do
      r = send(resource)
      r.stubs(:current_page).returns(5)
      r.stubs(:first_page?).returns(false)
      r.stubs(:last_page?).returns(true)
      get :index, { page: 5 }.merge!(@params)
      expect(response.headers['Link']).to match(/first/)
      expect(response.headers['Link']).to match(/prev/)
      expect(response.headers['Link']).to_not match(/next/)
      expect(response.headers['Link']).to_not match(/last/)
    end
  end
end

def it_should_show_with_attributes(*attrs)
  describe '#show' do
    it 'should work' do
      message = stub(:message)
      User.any_instance.expects(model.to_s.tableize).returns(stub(find: message))
      get :show, id: 1
      expect(assigns(:message)).to_not be nil
      expect(assigns(:content_attributes)).to match_array(attrs) unless attrs.blank?
    end
  end
end
