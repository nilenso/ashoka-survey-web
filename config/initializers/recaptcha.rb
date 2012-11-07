Recaptcha.configure do |config|
  config.public_key  = ENV["RECAPTCHA_PUBLIC_KEY"] || '6LcVxNgSAAAAANXZol7FzZWux77l6DYpdjCmzeD_'
  config.private_key = ENV["RECAPTCHA_PRIVATE_KEY"] || '6LcVxNgSAAAAAOJHywBMAndj8SY3y2AIfWY5r5hp'
end
