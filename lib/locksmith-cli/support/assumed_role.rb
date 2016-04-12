require "aws-sdk"
require "cgi"
require "English"
require "rest-client"
require "tty-prompt"
require "uri"

module Locksmith
  class AssumedRole
    attr_reader :arn,
                :access_key_id,
                :assumed_role_id,
                :bookmark,
                :expiration,
                :secret_access_key,
                :session_token

    def initialize(options)
      @access_key_id = options[:access_key_id]
      @arn = options[:arn]
      @assumed_role_id = options[:assumed_role_id]
      @bookmark = options[:bookmark]
      @expiration = options[:expiration]
      @secret_access_key = options[:secret_access_key]
      @session_token = options[:session_token]
    end

    def to_s
      arn
    end

    def self.prompt
      @prompt ||= TTY::Prompt.new(output: $stderr)
    end

    def name; bookmark.name; end
    def account_number; bookmark.account_number; end

    def signin_url
      query = {
        Action: :login,
        Issuer: nil,
        Destination: "https://console.aws.amazon.com/?region=eu-west-1",
        SigninToken: signin_token
      }

      URI::HTTPS.build(
        host: "signin.aws.amazon.com",
        path: "/federation",
        query: query.map do |k, v|
          "#{CGI.escape k.to_s}=#{CGI.escape v.to_s}"
        end.join("&")
      )
    end

    def signin_token
      RestClient::Request.execute(
        method: :get,
        url: "https://signin.aws.amazon.com/federation",
        headers: {
          params: {
            Action: :getSigninToken,
            Session: JSON.generate(
              sessionId: access_key_id,
              sessionKey: secret_access_key,
              sessionToken: session_token
            )
          }
        }
      ) do |response|
        data = JSON.load(response)
        return data["SigninToken"]
      end

      nil # return
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    def self.obtain(access_key_id, secret_access_key, serial_number, bookmark)
      attempts = 0
      provide_serial = false
      mfa_required = false

      sts = Aws::STS::Client.new(
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        region: ENV['AWS_REGION'] || ENV['AWS_DEFAULT_REGION'] || "eu-central-1"
      )

      begin
        if mfa_required
          token_code = prompt.ask("Enter current MFA code") do |q|
            q.validate(/^\d{6}$/)
          end
        end

        options = {
          role_arn: "arn:aws:iam::#{bookmark.account_number}" \
                    ":role/#{bookmark.role_name}",
          role_session_name: "AssumeRoleSession"
        }

        options[:serial_number] = serial_number if provide_serial
        options[:token_code] = token_code if mfa_required

        assumed_role = sts.assume_role(options)

        AssumedRole.new(
          arn: assumed_role[:assumed_role_user][:arn],
          assumed_role_id: assumed_role[:assumed_role_user][:assumed_role_id],
          session_token: assumed_role[:credentials][:session_token],
          access_key_id: assumed_role[:credentials][:access_key_id],
          secret_access_key: assumed_role[:credentials][:secret_access_key],
          expiration: assumed_role[:credentials][:expiration].to_i,
          bookmark: bookmark
        )
      rescue Aws::STS::Errors::AccessDenied
        if $ERROR_INFO.to_s =~ /not authorized to perform:? sts:AssumeRole/i
          unless provide_serial
            provide_serial = true
            retry
          end

          prompt.error "You are not allowed to assume role " \
                       "#{bookmark.role_name} in account " \
                       "#{bookmark.name} (#{bookmark.account_number})"
          return
        end

        if $ERROR_INFO.to_s =~ /provide both MFA serial number/i
          mfa_required = true
          retry
        end

        if $ERROR_INFO.to_s =~ /invalid MFA one time pass code/i
          prompt.error "Provided code was invalid"
          attempts += 1
          retry unless attempts >= 3
          return
        end

        raise
      end
    end
  end
end
