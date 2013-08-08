if defined?(Konacha)
  Capybara.register_driver(:slow_poltergeist) { |app| Capybara::Poltergeist::Driver.new(app, :timeout => 2.minutes) }
  Konacha.configure do |config|
    require 'capybara/poltergeist'
    config.driver = :slow_poltergeist
  end
end