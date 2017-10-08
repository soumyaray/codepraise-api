# frozen_string_literal: false

require 'http'
require_relative 'repo.rb'
require_relative 'contributor.rb'

module RepoPraise
  module Errors
    # Not allowed to access resource
    Unauthorized = Class.new(StandardError)
    # Requested resource not found
    NotFound = Class.new(StandardError)
  end

  # Library for Github Web API
  class GithubApi
    # Encapsulates API response success and errors
    class Response
      HTTP_ERROR = {
        401 => Errors::Unauthorized,
        404 => Errors::NotFound
      }.freeze

      def initialize(response)
        @response = response
      end

      def successful?
        HTTP_ERROR.keys.include?(@response.code) ? false : true
      end

      def response_or_error
        successful? ? @response : raise(HTTP_ERROR[@response.code])
      end
    end

    def initialize(token)
      @gh_token = token
    end

    def repo(username, repo_name)
      repo_req_url = GithubApi.path([username, repo_name].join('/'))
      repo_data = call_gh_url(repo_req_url).parse
      Repo.new(repo_data, self)
    end

    def contributors(contributors_url)
      contributors_data = call_gh_url(contributors_url).parse
      contributors_data.map { |account_data| Contributor.new(account_data) }
    end

    def self.path(path)
      'https://api.github.com/repos/' + path
    end

    private

    def call_gh_url(url)
      response = HTTP.headers('Accept' => 'application/vnd.github.v3+json',
                              'Authorization' => "token #{@gh_token}").get(url)
      Response.new(response).response_or_error
    end
  end
end
