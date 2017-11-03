# frozen_string_literal: true

require 'roda'

module CodePraise
  # Web API
  class Api < Roda
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
              begin
                repo = Repository::For[Entity::Repo]
                      .find_full_name(ownername, reponame)
              rescue StandardError
                error = { error: 'Repository not found' }
                routing.halt(500, error.to_json)
              end

              error = { error: 'Repository not found' }
              routing.halt(404, error.to_json) unless repo

              repo.to_h.to_json
            end

            # POST '/api/v0.1/repo/:ownername/:reponame
            routing.post do
              begin
                repo = Github::RepoMapper.new(app.config)
                                         .load(ownername, reponame)
              rescue StandardError
                error = { error: 'Repository not found' }
                routing.halt(404, error.to_json)
              end

              if Repository::For[repo.class].find(repo)
                error = { error: 'Repository not found' }
                routing.halt(409, error.to_json)
              end

              begin
                stored_repo = Repository::For[repo.class].create(repo)
              rescue StandardError
                error = { error: 'Repository not found' }
                routing.halt(500, error.to_json)
              end

              response.status = 201
              response['Location'] = "/api/v0.1/repo/#{ownername}/#{reponame}"
              stored_repo.to_h.to_json
            end
          end
        end
      end
    end
  end
end
