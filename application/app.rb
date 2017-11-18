# frozen_string_literal: true

require 'roda'

module CodePraise
  # Web API
  class Api < Roda
    plugin :all_verbs

    route do |routing|
      app = Api
      response['Content-Type'] = 'application/json'

      # GET / request
      routing.root do
        message = "CodePraise API v0.1 up in #{app.environment} mode"
        HttpResponseRepresenter.new(Result.new(:ok, message)).to_json
      end

      routing.on 'api' do
        # /api/v0.1 branch
        routing.on 'v0.1' do
          routing.on 'repo' do
            # /api/v0.1/repo index request
            routing.is do
              routing.get do
                repos = Repository::For[Entity::Repo].all
                ReposRepresenter.new(Repos.new(repos)).to_json
              end

              routing.delete do
                case app.environment
                when :development, :test
                  %i[repos_contributors repos collaborators].each do |table|
                    app.DB[table].delete
                  end
                  result = Result.new(:ok, 'deleted')
                when :production
                  result = Result.new(:forbidden, 'not allowed')
                end

                http_response = HttpResponseRepresenter.new(result)
                response.status = http_response.http_code
                http_response.to_json
              end
            end

            # /api/v0.1/repo/:ownername/:reponame branch
            routing.on String, String do |ownername, reponame|
              # GET /api/v0.1/repo/:ownername/:reponame request
              routing.get do
                find_result = FindDatabaseRepo.call(
                  ownername: ownername, reponame: reponame
                )

                http_response = HttpResponseRepresenter.new(find_result.value)
                response.status = http_response.http_code
                if find_result.success?
                  RepoRepresenter.new(find_result.value.message).to_json
                else
                  http_response.to_json
                end
              end

              # POST '/api/v0.1/repo/:ownername/:reponame request
              routing.post do
                service_result = LoadFromGithub.new.call(
                  config: app.config,
                  ownername: ownername,
                  reponame: reponame
                )

                http_response = HttpResponseRepresenter.new(service_result.value)
                response.status = http_response.http_code
                if service_result.success?
                  response['Location'] = "/api/v0.1/repo/#{ownername}/#{reponame}"
                  RepoRepresenter.new(service_result.value.message).to_json
                else
                  http_response.to_json
                end
              end
            end
          end
        end
      end
    end
  end
end
