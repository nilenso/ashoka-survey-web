CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',                        # required
    :aws_access_key_id      => ENV['S3_ACCESS_KEY'],                        # required
    :aws_secret_access_key  => ENV['S3_SECRET'],                        # required
  }
  config.fog_directory  = 'surveywebstaging'                     # required
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end