# frozen_string_literal: true

require 'roda'
require 'econfig'
require_relative 'lib/init.rb'

module CodePraise
  # Web API
  class Api < Roda
    plugin :environments
    plugin :json
    plugin :halt

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    route do |routing|
      app = Api
      config = Api.config

      # GET / request
      routing.root do
        { 'message' => "CodePraise API v0.1 up in #{app.environment}" }
      end

      routing.on 'api' do
        # /api/v0.1 branch
        routing.on 'v0.1' do
          # /api/v0.1/:ownername/:repo_name branch
          routing.on 'repo', String, String do |ownername, repo_name|
            github_api = Github::Api.new(config.gh_token)
            repo_mapper = Github::RepoMapper.new(github_api)
            begin
              repo = repo_mapper.load(ownername, repo_name)
            rescue StandardError
              routing.halt(404, error: 'Repo not found')
            end

            # GET /api/v0.1/:ownername/:repo_name request
            routing.is do
              { repo: { owner: repo.owner.to_h, size: repo.size } }
            end

            # GET /api/v0.1/:ownername/:repo_name/contributors request
            routing.get 'contributors' do
              { contributors: repo.contributors.map(&:to_h) }
            end
          end
        end
      end
    end
  end
end
