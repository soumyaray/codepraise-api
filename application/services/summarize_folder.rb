# frozen_string_literal: true

require 'dry/transaction'

module CodePraise
  # Transaction to summarize folder from local repo
  class SummarizeFolder
    include Dry::Transaction

    step :clone_or_find_repo
    step :summarize_folder

    def clone_or_find_repo(input)
      input[:gitrepo] = GitRepo.new(input[:repo])
      if input[:gitrepo].exists_locally?
        Right(input)
      else
        repo_json = RepoRepresenter.new(input[:repo]).to_json
        CloneRepoWorker.perform_async(repo_json)
        Left(Result.new(:processing, 'Processing the summary request'))
      end
    rescue
      Left(Result.new(:internal_error, 'Could not clone repo'))
    end

    def summarize_folder(input)
      folder_summary = Blame::Summary
                       .new(input[:gitrepo])
                       .for_folder(input[:folder])
      Right(Result.new(:ok, folder_summary))
    rescue
      Left(Result.new(:internal_error, 'Could not summarize folder'))
    end
  end
end