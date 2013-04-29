Bitly.configure do |config|
  config.api_version = 3
  config.login = ENV["BITLY_USERNAME"]
  config.api_key = ENV["BITLY_API_KEY"]
end
