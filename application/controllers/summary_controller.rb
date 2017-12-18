# frozen_string_literal: true

module CodePraise
  # Web API
  class Api < Roda
    plugin :halt

    route('summary') do |routing|
      # #{API_ROOT}/summary/ownername/reponame index request
      routing.on String, String do |ownername, reponame|
        find_result = FindDatabaseRepo.call(
          ownername: ownername, reponame: reponame
        )
        routing.halt(404, 'Repo not found') if find_result.failure?
        @repo = find_result.value.message

      routing.get do
        path = request.remaining_path
        folder = path.empty? ? '' : path[1..-1]

        request_id = [request.env, request.path, Time.now.to_f].hash

        summarize_result = SummarizeFolder.new.call(
          repo: @repo,
          folder: folder,
          id: request_id
        )

        represent_response(summarize_result, FolderSummaryRepresenter)
      end
      end
    end
  end
end
