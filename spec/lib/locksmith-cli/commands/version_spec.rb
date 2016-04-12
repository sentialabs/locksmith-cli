require "spec_helper"

describe Locksmith::CLI::Version do
  let(:cli) { Locksmith::CLI::Root.new }

  context "#version" do
    it "outputs the Locksmith cli version" do
      # rubocop:disable LineLength
      expect { cli.version }.to output("Locksmith CLI version #{Locksmith::CLI::VERSION}\n").to_stdout
      # rubocop:enable LineLength
    end
  end
end
