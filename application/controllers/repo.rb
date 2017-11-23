# frozen_string_literal: true

module CodePraise
  # Web API
  class Api < Roda
    plugin :all_verbs

    route('repo') do |routing|
      # #{API_ROOT}/repo index request
      routing.is do
        routing.get do
          repos = Repository::For[Entity::Repo].all
          ReposRepresenter.new(Repos.new(repos)).to_json
        end

        Api.configure :development, :test do
          routing.delete do
            %i[repos_contributors repos collaborators].each do |table|
              Api.DB[table].delete
            end
            http_response = HttpResponseRepresenter
                            .new(Result.new(:ok, 'deleted tables'))
            response.status = http_response.http_code
            http_response.to_json
          end
        end
      end

      # #{API_ROOT}/repo/:ownername/:reponame branch
      routing.on String, String do |ownername, reponame|
        # GET #{API_ROOT}/repo/:ownername/:reponame request
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

        # POST #{API_ROOT}/repo/:ownername/:reponame request
        routing.post do
          service_result = LoadFromGithub.new.call(
            config: Api.config,
            ownername: ownername,
            reponame: reponame
          )

          http_response = HttpResponseRepresenter.new(service_result.value)
          response.status = http_response.http_code
          if service_result.success?
            response['Location'] = "#{@api_root}/repo/#{ownername}/#{reponame}"
            RepoRepresenter.new(service_result.value.message).to_json
          else
            http_response.to_json
          end
        end
      end
    end
  end
end
