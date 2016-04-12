require "thor"
require_relative "commands/console"
require_relative "commands/environment"
require_relative "commands/shell"
require_relative "commands/version"

module Locksmith
  module CLI
    class Root < Thor
      register Locksmith::CLI::Console,
               :console,
               "console",
               "Obtain and open a login URL in your browser"
      register Locksmith::CLI::Environment,
               :env,
               "env [SHELL]",
               "Assume role, echo environment variables"
      register Locksmith::CLI::Shell,
               :sh,
               "sh",
               "Assume role, start a shell with environment variables"
      register Locksmith::CLI::Version,
               :version,
               "version",
               "Show Locksmith CLI version"
    end
  end
end
