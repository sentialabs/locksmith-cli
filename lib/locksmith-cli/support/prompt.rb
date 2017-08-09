require "tty-prompt"
require_relative "bookmark"
require_relative "environment"

module Locksmith
  class Prompt
    def self.for
      self
    end

    def self.bookmark(query = nil, flag = nil)
      bookmarks = Bookmark.query(
        ENV["LS_API_URL"],
        ENV["LS_API_USER"],
        ENV["LS_API_PASS"],
        query
      )

      if bookmarks.length == 0
        puts "No matches for query: #{query}"
        exit false
      end

      if flag == "-y" && bookmarks.count == 1
        print "Select account "
        puts "\e[32m#{bookmarks.first()}\e[0m"
        return bookmarks.first()
      end

      prompt.select(
        "Select account",
        bookmarks
      )
    end

    def self.role(query = nil, flag = nil)
      bookmark(query, flag).assume_role(
        ENV["LS_AWS_ACCESS_KEY_ID"],
        ENV["LS_AWS_SECRET_ACCESS_KEY"],
        ENV["LS_AWS_MFA_SERIAL"]
      )
    end

    def self.prompt
      @prompt ||= TTY::Prompt.new(output: $stderr)
    end
  end
end
