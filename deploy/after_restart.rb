run "RAILS_ENV=#{environment} #{current_path}/script/delayed_job stop"
run "RAILS_ENV=#{environment} #{current_path}/script/delayed_job -n 3 start"
