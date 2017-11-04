# frozen_string_literal: true

require 'dry/transaction'

module CodePraise
  # Transaction to load repo from Github and save to database
  class LoadFromGithub
    include Dry::Transaction

    step :get_repo_from_github
    step :check_if_repo_already_loaded
    step :store_repo_in_repository

    def get_repo_from_github(input)
      repo = Github::RepoMapper.new(input[:config])
                               .find(input[:ownername], input[:reponame])
      Right(repo: repo)
    rescue StandardError
      Left(Result.new(:bad_request, 'Remote git repository not found'))
    end

    def check_if_repo_already_loaded(input)
      if Repository::For[input[:repo].class].find(input[:repo])
        Left(Result.new(:conflict, 'Repo already loaded'))
      else
        Right(input)
      end
    end

    def store_repo_in_repository(input)
      stored_repo = Repository::For[input[:repo].class].create(input[:repo])
      Right(Result.new(:created, stored_repo))
    rescue StandardError => e
      puts e.to_s
      Left(Result.new(:internal_error, 'Could not store remote repository'))
    end
  end
end