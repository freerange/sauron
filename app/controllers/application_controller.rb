class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :protect_messages_from_spies

  private

  attr_reader :current_username
  helper_method :current_username

  def protect_messages_from_spies
    authenticate_or_request_with_http_basic('Sauron') do |username, password|
      if Team.new.has_member?(username) && password == ENV['HTTP_PASSWORD']
        @current_username = username
      end
    end
  end

  def render_not_found
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
  end
end
