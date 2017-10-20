# frozen_string_literal: false

module RepoPraise
  # Provides access to contributor data
  module Github
    # Data Mapper for Github contributors
    class ContributorMapper
      def initialize(data_source)
        @data_source = data_source
      end

      def load_several(url)
        contribs_data = @data_source.contributors_data(url)
        contribs_data.map do |contributor_data|
          build_entity(contributor_data)
        end
      end

      def build_entity(contributor_data)
        mapper = DataMap.new(contributor_data)

        Entity::Contributor.new(
          username: mapper.username,
          email: mapper.email
        )
      end

      # Extracts entity specific elements from data structure
      class DataMap
        def initialize(contributor_data)
          @contributor_data = contributor_data
        end

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
