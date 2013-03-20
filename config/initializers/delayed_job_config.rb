# Calls to Rails.logger go to the same object as Delayed::Worker.logger
Delayed::Worker.logger = Rails.logger