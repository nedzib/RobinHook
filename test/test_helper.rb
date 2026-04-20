ENV["RAILS_ENV"] ||= "test"
require "simplecov"

SimpleCov.use_merging false
SimpleCov.command_name "rails-tests"

SimpleCov.start "rails" do
  add_filter "/config/"
  add_filter "/db/"
  add_filter "/test/"
  add_filter "/app/helpers/"
  add_filter "/app/jobs/application_job.rb"
  add_filter "/app/mailers/application_mailer.rb"

  minimum_coverage line: 90
end

require_relative "../config/environment"
require "rails/test_help"

Dir[Rails.root.join("app/services/**/*.rb")].sort.each { |file| load file }

module ActiveSupport
  class TestCase
    # Keep coverage collection deterministic while SimpleCov is enabled.
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
