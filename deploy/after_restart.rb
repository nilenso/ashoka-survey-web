if environment == "staging"
  run "/data/surveyweb/current/script/delayed_job restart"
else
  run "RAILS_ENV=production /data/surveyweb/current/script/delayed_job restart"
end