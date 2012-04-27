require 'test_helper'

class TestController < ApplicationController
  def index
    render inline: '', layout: 'application'
  end
end

class ApplicationControllerTest < ActionController::TestCase
  tests TestController

  test 'prevents access without HTTP basic authentication' do
    get :index
    assert_response :unauthorized
  end

  test 'prevents access with incorrect HTTP basic authentication password' do
    ENV["TEAM"] = "alice@example.com"
    ENV["HTTP_PASSWORD"] = "password"
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("alice@example.com:wrongpassword")
    get :index
    assert_response :unauthorized
  end

  test 'prevents access with incorrect HTTP basic authentication username' do
    ENV["TEAM"] = "alice@example.com"
    ENV["HTTP_PASSWORD"] = "password"
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("bob@example.com:password")
    get :index
    assert_response :unauthorized
  end

  test 'allows access with the correct HTTP basic authentication credentials' do
    ENV["TEAM"] = "alice@example.com"
    ENV["HTTP_PASSWORD"] = "password"
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("alice@example.com:password")
    get :index
    assert_response :success
  end

  test 'assigns current username when authentication succeeds' do
    ENV["TEAM"] = "alice@example.com"
    ENV["HTTP_PASSWORD"] = "password"
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("alice@example.com:password")
    get :index
    assert_equal "alice@example.com", assigns(:current_username)
  end

  test "displays currently logged in username" do
    ENV["TEAM"] = "alice@example.com"
    ENV["HTTP_PASSWORD"] = "password"
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("alice@example.com:password")
    get :index
    assert_select "#session .username", text: "alice@example.com"
  end
end