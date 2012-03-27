ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'
require 'fakes/fake_gmail'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def self.let(name, &block)
    define_method name do
      @_memoized ||= {}
      @_memoized.fetch(name) { |k| @_memoized[k] = instance_eval(&block) }
    end
  end

  def self.subject(&block)
    let :subject, &block
  end

  def self.stub(name, options = {})
    let name do
      stub(name.to_s, options)
    end
  end
end

Mocha::Configuration.prevent(:stubbing_non_existent_method)
