desc "Run parallel specs and coverage reports"
task :default => %w(parallel:prepare parallel:spec coverage)
