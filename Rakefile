require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new("spec") do |t|
  t.test_files = Dir.glob("spec/**/*_spec.rb")
end

task(:default => :spec)

namespace :spec do
  task :all do
    Dir["Gemfile*"].reject {|name| name[".lock"] }.each do |gemfile|
      sh "BUNDLE_GEMFILE=#{gemfile} bundle exec rake spec"
    end
  end
end
