require "bundler/gem_tasks"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = \
    " --format RspecJunitFormatter" \
    " --out test-reports/rspec.xml"
end

task :pry do
  require "pry"
  require "awesome_print"
  require_relative "lib/locksmith-cli"
  ARGV.clear
  Pry.start
end

task :run do
  require_relative "lib/locksmith-cli"
  args = ARGV.dup
  Locksmith::CLI::Root.start(args)
end

require "rubocop"
require "rubocop/rake_task"
require "rubocop/formatter/base_formatter"
require "rubocop/formatter/junit_formatter"
desc "Run RuboCop on the lib directory"
RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = false
  task.patterns = ["lib/**/*.rb"]
  task.options << "--format"
  task.options << "RuboCop::Formatter::JUnitFormatter"
  task.options << "--out"
  task.options << "test-reports/rubocop.xml"
end

task default: [:rubocop, :spec]
