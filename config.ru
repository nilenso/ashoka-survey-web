# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run SurveyWeb::Application
use Rack::Cors do
  allow do
    origins '*'
    resource '/assets/images/font/*', :headers => :any, :methods => :get
  end
end
