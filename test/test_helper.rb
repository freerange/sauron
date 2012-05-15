ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'
require 'fakes/fake_gmail'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...

  def assert_same_elements(expected, actual, message=nil)
    assert_equal expected.sort, actual.sort, message
  end
end

Mocha::Configuration.prevent(:stubbing_non_existent_method)
