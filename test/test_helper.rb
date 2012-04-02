ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'
require 'fakes/fake_gmail'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
end

Mocha::Configuration.prevent(:stubbing_non_existent_method)
