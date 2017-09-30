# frozen_string_literal: false

require_relative 'contributor.rb'

module RepoPraise
  # Model for Repo
  class Repo
    def initialize(repo_data, data_source)
      @repo = repo_data
      @data_source = data_source
    end

    def size
      @repo['size']
    end

    def owner
      @owner ||= Contributor.new(@repo['owner'])
    end

    def git_url
      @repo['git_url']
    end

    def contributors
      @contributors ||= @data_source.contributors(@repo['contributors_url'])
    end
  end
end
