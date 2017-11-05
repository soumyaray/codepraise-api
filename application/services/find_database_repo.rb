# frozen_string_literal: true

require 'dry-monads'

module CodePraise
  # Service to find a repo from our database
  # Usage:
  #   result = FindDatabaseRepo.call(ownername: 'soumyaray', reponame: 'YPBT-app')
  #   result.success?
  module FindDatabaseRepo
    extend Dry::Monads::Either::Mixin

    def self.call(input)
      repo = Repository::For[Entity::Repo]
             .find_full_name(input[:ownername], input[:reponame])
      if repo
        Right(Result.new(:ok, repo))
      else
        Left(Result.new(:not_found, 'Could not find stored git repository'))
      end
    end
  end
end
