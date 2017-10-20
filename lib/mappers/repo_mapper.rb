# frozen_string_literal: false

require_relative 'contributor_mapper.rb'

module RepoPraise
  module Github
    # Repository object for Github's git repos
    class RepoMapper
      def initialize(data_source)
        @data_source = data_source
      end

      def load(owner_name, repo_name)
        repo_data = @data_source.repo_data(owner_name, repo_name)
        build_entity(repo_data)
      end

      def build_entity(repo_data)
        mapper = DataMap.new(repo_data, @data_source)

        RepoPraise::Entity::Repo.new(
          size: mapper.size,
          owner: mapper.owner,
          git_url: mapper.git_url,
          contributors: mapper.contributors
        )
      end

      # Extracts entity specific elements from data structure
      class DataMap
        def initialize(repo_data, data_source)
          @repo_data = repo_data
          @contributor_mapper = ContributorMapper.new(data_source)
        end

        def size
          @repo_data['size']
        end

        def owner
          @contributor_mapper.build_entity(@repo_data['owner'])
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
