ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    # Automatic authentication for IntegrationTest
    def sign_in_as(user, password: 'password')
      if defined?(post) && respond_to?(:post)
        post login_url, params: { email: user.email_address, password: password }
      elsif defined?(open_session)
        open_session do |sess|
          sess.post login_url, params: { email: user.email_address, password: password }
        end
      end
    end
  end
end
