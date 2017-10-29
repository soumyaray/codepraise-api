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
          # /api/v0.1/:ownername/:reponame branch
          routing.on 'repo', String, String do |ownername, reponame|
            # GET /api/v0.1/repo/:ownername/:reponame request
            routing.get do
              repo = Database::ORM[Entity::Repo]
                     .find_full_name(ownername, reponame)

              routing.halt(404, error: 'Repository not found') unless repo
              repo.to_h
            end

            # POST '/api/v0.1/repo/:ownername/:reponame
            routing.post do
              begin
                github_repo = Github::RepoMapper.new(app.config)
                repo = github_repo.load(ownername, reponame)
              rescue StandardError
                routing.halt(404, error: "Repo not found")
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
