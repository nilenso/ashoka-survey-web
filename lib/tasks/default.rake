desc "Run parallel specs and coverage reports"
task :default => %w(parallel:prepare coverage:prepare_environment parallel:spec)
