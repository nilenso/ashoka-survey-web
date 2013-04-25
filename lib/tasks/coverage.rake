namespace :coverage do
  desc "Set up coverage config in enviroment"
  task :prepare_environment do
    puts "Preparing coverage environment"
    ENV["ENABLE_COVERAGE"] = "true"
  end

  task :default => :prepare_environment do
    Rake::Task["parallel:spec"].invoke
  end
end
