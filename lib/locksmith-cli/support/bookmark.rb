require "json"
require "rest-client"
require_relative "assumed_role"

module Locksmith
  class Bookmark
    attr_reader :name, :account_number, :role_name

    def initialize(options)
      @name = options["name"]
      @account_number = options["account_number"]
      @role_name = options["role_name"]
    end

    def assume_role(access_key_id, secret_access_key, serial_number)
      AssumedRole.obtain(access_key_id, secret_access_key, serial_number, self)
    end

    def to_s
      name
    end

    def self.all(url, user, pass)
      bookmark_list = []
      bookmarks(url, user, pass) do |bookmark|
        bookmark_list << bookmark
      end
      bookmark_list.sort_by!(&:name)
      bookmark_list # return
    end

    def self.query(url, user, pass, query)
      bookmarks = all(url, user, pass)

      if query
        return bookmarks.select do |b|
          b.name =~ /#{query}/i || b.account_number =~ /#{query}/i
        end
      end

      bookmarks
    end

    def self.bookmarks(url, user, pass, &block)
      RestClient::Request.execute(
        method: :get,
        url: url,
        user: user,
        password: pass
      ) do |response|
        data = JSON.load response

        if data["bookmarks"]
          data["bookmarks"].each do |bookmark|
            yield Bookmark.new bookmark
          end
        end

        break unless data["_links"]
        break unless data["_links"]["next"]
        break unless data["_links"]["next"]["href"]

        bookmarks data["_links"]["next"]["href"], user, pass, &block
      end
    end
  end
end
