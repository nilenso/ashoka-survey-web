Recaptcha.configure do |config|
  if Rails.env.production?
    config.public_key  = Figaro.env.recaptcha_public_key
    config.private_key = Figaro.env.recaptcha_private_key
  else
    config.public_key  = '6LcVxNgSAAAAANXZol7FzZWux77l6DYpdjCmzeD_'
    config.private_key = '6LcVxNgSAAAAAOJHywBMAndj8SY3y2AIfWY5r5hp'
  end
end
