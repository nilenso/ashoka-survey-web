if ENV["ENABLE_COVERAGE"]
  require 'simplecov'
  SimpleCov.start 'rails'
end

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'rubygems'

Fog.mock!
CarrierWave.configure do |config|
  config.enable_processing = false
end

connection = Fog::Storage.new(
  :aws_access_key_id      => ENV['S3_ACCESS_KEY'],
  :aws_secret_access_key  => ENV['S3_SECRET'],
  :provider               => 'AWS',
  :region                 => "us-east-1"
)
connection.directories.create(:key => ENV['S3_BUCKET'])

LOGGED_IN_ORG_ID = 1
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"

  if ENV["ENABLE_COVERAGE"]
    config.before(:each) do
      SimpleCov.command_name "RSpec:#{Process.pid.to_s}#{ENV['TEST_ENV_NUMBER']}"
    end
  end


  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:user_owner] = OmniAuth::AuthHash.new({
                                                                    :provider => 'user_owner',
                                                                    :uid => '12345',
                                                                    :info => {
                                                                      :name => 'tim',
                                                                      :email => 'smit@smit.smit',
                                                                      :role => 'user',
                                                                      :org_id => '1098',
                                                                      :org_type => 'CSO',
                                                                      :organizations => [{:id => 123, :name => 'nid'}]
                                                                    },
                                                                    :credentials => { :token => "thisisatoken" }
  })

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

def sign_in_as(role)
  session[:user_id] = 123
  session[:user_info] = OmniAuth::AuthHash.new({ :role => role, :org_id => LOGGED_IN_ORG_ID })
  session[:access_token] = "123"
end
