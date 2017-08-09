require "thor"
require_relative "../support/prompt"

module Locksmith
  module CLI
    class Shell < Thor::Group
      def sh
        role = Prompt.for.role(ARGV[1], ARGV[2]) # hacky way to obtain query
        exit false if role.nil?

        env = self.class.clean_environment

        Environment::ENVIRONMENT_VARIABLES.each do |key, envs|
          (envs.respond_to?(:each) ? envs : [envs]).each do |e|
            env[e.to_s] = role.send(key).to_s
          end
        end

        command = "#{Etc.getpwnam(Etc.getlogin).shell} -l"
        exec(env, command)
      end

      def self.clean_environment(src = ENV)
        env = src.to_h

        if env["BUNDLE_ORIG_MANPATH"]
          env["MANPATH"] = env["BUNDLE_ORIG_MANPATH"]
        end

        %w(
          BUNDLE_BIN_PATH
          BUNDLE_GEMFILE
          BUNDLE_ORIG_MANPATH
          GEM_HOME
          GEM_PATH
          LS_AWS_ACCESS_KEY_ID
          LS_AWS_MFA_SERIAL
          LS_AWS_SECRET_ACCESS_KEY
          RBENV_DIR
          RBENV_HOOK_PATH
          RBENV_ROOT
          RBENV_VERSION
          RUBYLIB
          RUBYOPT
        ).each { |name| env.delete(name) }

        env["PATH"] = env["PATH"].split(":").delete_if do |item|
          item =~ %r{rbenv/(\.shims|versions|plugins)}
        end.join(":")

        env # return env
      end
    end
  end
end
