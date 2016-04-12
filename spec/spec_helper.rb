require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "rspec"
require "pry"
require "awesome_print"

require "locksmith-cli"

RSpec.configure do |config|
  config.color = true
  config.formatter = "documentation"
  config.raise_errors_for_deprecations!

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.filter_run_excluding broken: true
  config.filter_run_excluding turn_off: true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.filter_run_excluding :slow unless ENV["SLOW_SPECS"]
  config.filter_run_excluding :debug unless ENV["DEBUG_SPECS"]
end
