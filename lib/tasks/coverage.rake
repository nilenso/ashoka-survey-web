namespace :coverage do
  desc "Run coverage report"
  task :default do
    ENV["ENABLE_COVERAGE"] = "true"
    Rake::Task["parallel:spec"].invoke
  end
end
