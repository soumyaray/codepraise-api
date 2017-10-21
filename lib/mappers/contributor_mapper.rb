# frozen_string_literal: false

module RepoPraise
  # Provides access to contributor data
  module Github
    # Data Mapper for Github contributors
    class ContributorMapper
      def initialize(gateway)
        @gateway = gateway
      end

      def load_several(url)
        contribs_data = @gateway.contributors_data(url)
        contribs_data.map do |contributor_data|
          ContributorMapper.build_entity(contributor_data)
        end
      end

      def self.build_entity(contributor_data)
        DataMapper.new(contributor_data).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(contributor_data)
          @contributor_data = contributor_data
        end

        def build_entity
          Entity::Contributor.new(
            username: username,
            email: email
          )
        end

        private

        def username
          @contributor_data['login']
        end

        def email
          @contributor_data['email']
        end
      end
    end
  end
end
