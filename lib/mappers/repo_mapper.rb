# frozen_string_literal: false

require_relative 'contributor_mapper.rb'

module CodePraise
  module Github
    # Data Mapper object for Github's git repos
    class RepoMapper
      def initialize(gateway)
        @gateway = gateway
      end

      def load(owner_name, repo_name)
        repo_data = @gateway.repo_data(owner_name, repo_name)
        build_entity(repo_data)
      end

      def build_entity(repo_data)
        DataMapper.new(repo_data, @gateway).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(repo_data, gateway)
          @repo_data = repo_data
          @contributor_mapper = ContributorMapper.new(gateway)
        end

        def build_entity
          CodePraise::Entity::Repo.new(
            size: size,
            owner: owner,
            git_url: git_url,
            contributors: contributors
          )
        end

        def size
          @repo_data['size']
        end

        def owner
          ContributorMapper.build_entity(@repo_data['owner'])
        end

        def git_url
          @repo_data['git_url']
        end

        def contributors
          @contributor_mapper.load_several(@repo_data['contributors_url'])
        end
      end
    end
  end
end
