desc "Run parallel specs and coverage reports"
task :parallel => %w(parallel:prepare parallel:spec coverage)
