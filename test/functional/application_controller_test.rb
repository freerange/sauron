require 'test_helper'

class TestController < ApplicationController
  def index
    head status: 200
  end
end

class ApplicationControllerTest < ActionController::TestCase
  tests TestController

  test 'prevents access without HTTP basic authentication' do
    get :index
    assert_response :unauthorized
  end

  test 'prevents access with incorrect HTTP basic credentials' do
    ENV["HTTP_PASSWORD"] = "password"
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("admin:wrongpassword")
    get :index
    assert_response :unauthorized
  end

  test 'allows access with the correct HTTP basic credentials' do
    ENV["HTTP_PASSWORD"] = "password"
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("admin:password")
    get :index
    assert_response :success
  end
end