# frozen_string_literal: true

require 'dry/transaction'

module CodePraise
  # Transaction to load repo from Github and save to database
  class FindDatabaseRepo
    include Dry::Transaction

    step :find_repo
    step :check_valid_repo

    def find_repo(input)
      repo = Repository::For[Entity::Repo]
        .find_full_name(input[:ownername], input[:reponame])
      Right(repo: repo)
    rescue StandardError
      Left(Result.new(:internal_error, 'Could not access database'))
    end

    def check_valid_repo(input)
      if input[:repo]
        Right(Result.new(:ok, input[:repo]))
      else
        Left(Result.new(:not_found, 'Could not find stored git repository'))
      end
    end
  end
end