require "thor"
require_relative "../support/prompt"

module Locksmith
  module CLI
    class Console < Thor::Group
      def env
        role = Prompt.for.role(ARGV[1], ARGV[2]) # hacky way to obtain query
        exit false if role.nil?

        Launchy.open role.signin_url
      end

      private

      def prompt
        @prompt ||= TTY::Prompt.new(output: $stderr)
      end
    end
  end
end
