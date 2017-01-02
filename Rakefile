require "bundler/gem_tasks"
Rake::Task["release"].clear # Gems are autopublished
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new

task :default => [:spec]
