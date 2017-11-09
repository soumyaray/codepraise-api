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
        message = "CodePraise API v0.1 up in #{app.environment} mode"
        HttpResponseRepresenter.new(Result.new(:ok, message)).to_json
      end

      routing.on 'api' do
        # /api/v0.1 branch
        routing.on 'v0.1' do
          # /api/v0.1/:ownername/:reponame branch
          routing.on 'repo', String, String do |ownername, reponame|
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

            # POST '/api/v0.1/repo/:ownername/:reponame
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
