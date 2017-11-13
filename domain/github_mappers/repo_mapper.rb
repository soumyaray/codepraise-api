# frozen_string_literal: false

require_relative 'collaborator_mapper.rb'

module CodePraise
  module Github
    # Data Mapper object for Github's git repos
    class RepoMapper
      def initialize(config, gateway_class = Github::Api)
        @config = config
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@config.GH_TOKEN)
      end

      def find(owner_name, repo_name)
        data = @gateway.repo_data(owner_name, repo_name)
        build_entity(data)
      end

      def build_entity(data)
        DataMapper.new(data, @config, @gateway_class).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, config, gateway_class)
          @data = data
          @contributor_mapper = CollaboratorMapper.new(
            config, gateway_class
          )
        end

        def build_entity
          CodePraise::Entity::Repo.new(
            id: nil,
            origin_id: origin_id,
            name: name,
            size: size,
            git_url: git_url,
            owner: owner,
            contributors: contributors
          )
        end

        def origin_id
          @data['id']
        end

        def name
          @data['name']
        end

        def size
          @data['size']
        end

        def owner
          CollaboratorMapper.build_entity(@data['owner'])
        end

        def git_url
          @data['git_url']
        end

        def contributors
          @contributor_mapper.load_several(@data['contributors_url'])
        end
      end
    end
  end
end
