ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'rubygems'
require 'spork'
require 'capybara/rails'
require 'capybara/rspec'
require "paperclip/matchers"

Capybara.javascript_driver = :webkit

Spork.prefork do
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = true
    config.infer_base_class_for_anonymous_controllers = false
    config.order = "random"

    config.include Paperclip::Shoulda::Matchers

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:user_owner] = OmniAuth::AuthHash.new({
      :provider => 'user_owner',
      :uid => '12345',
      :info => {
        :name => 'tim',
        :email => 'smit@smit.smit',
        :role => 'user',
        :org_id => '1098',
        :organizations => [{:id => 123, :name => 'nid'}]
      },
      :credentials => { :token => "thisisatoken" }
    })
  end
end

Spork.each_run do
end

def sign_in_as(role)
  session[:user_id] = 123
  session[:user_info] = { :role => role }
end
