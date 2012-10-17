require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  setup do
    @message = messages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:messages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create message" do
    assert_difference('Message.count') do
      post :create, message: { recipients: @message.recipients, short_body: @message.short_body }
    end

    assert_response 201
  end

  test "should show message" do
    get :show, id: @message
    assert_response :success
  end
end
