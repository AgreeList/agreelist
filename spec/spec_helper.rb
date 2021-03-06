# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require_relative 'support/wait_for_ajax'
require 'rspec/autorun'
require 'capybara/rspec'
require "rack_session_access/capybara"
require 'webdrivers'
require 'capybara-screenshot/rspec'
require "fakeredis"
require 'sidekiq/testing'
Sidekiq::Testing.fake!

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: {
      args: %w[headless enable-features=NetworkService,NetworkServiceInProcess]
    }
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end

Capybara.default_driver = :headless_chrome
Capybara.javascript_driver = :headless_chrome

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.include Capybara::DSL
  config.use_transactional_fixtures = false

  config.before :each do
    if Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :transaction
    else
      DatabaseCleaner.strategy = :truncation
    end
    DatabaseCleaner.start
    $redis = Redis.new
    $redis.flushall
  end

  config.after do
    DatabaseCleaner.clean
  end
end

OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:twitter] = {
  "uid" => '1337',
  "provider" => 'twitter',
  "info" => {
    "nickname" => 'arpahector',
    "name" => 'Hector Perez'
  }
}

# driver_urls = Webdrivers::Common.subclasses.map { |driver| driver.send(:base_url) }
# driver_urls = (ObjectSpace.each_object(Webdrivers::Common.singleton_class).to_a - [Webdrivers::Common]).map(&:base_url)
driver_urls = Webdrivers::Common.subclasses.map do |driver|
  Addressable::URI.parse(driver.base_url).host
end
VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.ignore_hosts(
    '127.0.0.1',
    'localhost',
    *driver_urls
  )
end
WebMock.disable_net_connect!(allow_localhost: true, allow: driver_urls)

def login
  visit "/auth/twitter"
end

def login_as_admin
  login
  Individual.last.update_attributes(admin: true)
end
