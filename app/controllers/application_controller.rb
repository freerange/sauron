class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :protect_messages_from_spies

  private

  def protect_messages_from_spies
    authenticate_or_request_with_http_basic('Sauron') do |username, password|
      username == 'admin' && password == ENV['HTTP_PASSWORD']
    end
  end
end
