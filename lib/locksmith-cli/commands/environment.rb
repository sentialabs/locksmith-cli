require "launchy"
require "thor"
require_relative "../support/prompt"

module Locksmith
  module CLI
    class Environment < Thor::Group
      ENVIRONMENT_VARIABLES = {
        access_key_id: :AWS_ACCESS_KEY_ID,
        account_number: :AWS_SESSION_ACCOUNT_ID,
        arn: :ASSUMED_ROLE_ARN,
        assumed_role_id: :ASSUMED_ROLE_ID,
        expiration: :AWS_SESSION_EXPIRES,
        name: :AWS_SESSION_ACCOUNT_NAME,
        secret_access_key: :AWS_SECRET_ACCESS_KEY,
        session_token: :AWS_SESSION_TOKEN
      }

      def env
        role = Prompt.for.role(ARGV[1]) # hacky way to obtain query
        exit false if role.nil?

        ENVIRONMENT_VARIABLES.each do |key, env|
          puts "export #{env}=\"#{role.send(key)}\""
        end
      end
    end
  end
end
