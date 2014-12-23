require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new("spec") do |t|
  t.test_files = Dir.glob("spec/**/*_spec.rb")
end

task(:default => :spec)
