# frozen_string_literal: true

require 'roda'

module CodePraise
  # Web API
  class Api < Roda
    plugin :json
    plugin :halt

    route do |routing|
      app = Api

      # GET / request
      routing.root do
        { 'message' => "CodePraise API v0.1 up in #{app.environment} mode" }
      end

      routing.on 'api' do
        # /api/v0.1 branch
        routing.on 'v0.1' do
          # /api/v0.1/:ownername/:repo_name branch
          routing.on 'repo', String, String do |ownername, repo_name|
            # GET /api/v0.1/repo/:ownername/:repo_name request
            routing.is do
              repo = Database::ORM[Entity::Repo]
                     .find_full_name(ownername, repo_name)

              routing.halt(404, error: 'Repository not found') unless repo
              repo.to_h
            end

            # post '/api/v0.1/repo/:ownername/:repo_name
            routing.post do
              github_repo = Github::RepoMapper.new(app.config)
              begin
                repo = github_repo.load(ownername, repo_name)
              rescue StandardError
                routing.halt(404, error: 'Repository not found')
              end

              stored_repo = Database::ORM[Entity::Repo].find_or_create(repo)
              stored_repo.to_h
            end
          end
        end
      end
    end
  end
end
