require "thor"
module Locksmith
  module CLI
    class Version < Thor::Group
      def version
        puts "Locksmith CLI version #{Locksmith::CLI::VERSION}"
      end
    end
  end
end
