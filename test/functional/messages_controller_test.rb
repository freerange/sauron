require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  setup do
    ENV["HTTP_PASSWORD"] = "password"
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("admin:password")
  end

  test "#index finds messages via repository" do
    messages = [Mail.new("FROM: George\nDate: 2012-01-01 12:00:00"), Mail.new("FROM: Bob\nDate: 2012-01-01 12:00:00")]
    MessageRepository.stubs(:messages).with().returns(messages)
    get :index
    assert_equal messages, assigns[:messages]
  end

  test "#show finds message via repository" do
    message = stub(subject: 'a', from: 'b', date: Time.now, original: 'Whut')
    MessageRepository.stubs(:find).with('1234').returns(message)
    get :show, id: '1234'
    assert_equal message, assigns[:message]
  end
end