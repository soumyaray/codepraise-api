# frozen_string_literal: false

module CodePraise
  # Provides access to contributor data
  module Github
    # Data Mapper for Github contributors
    class CollaboratorMapper
      def initialize(config, gateway_class = Github::Api)
        @config = config
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@config.GH_TOKEN)
      end

      def load_several(url)
        contribs_data = @gateway.collaborators_data(url)
        contribs_data.map do |data|
          CollaboratorMapper.build_entity(data)
        end
      end

      def self.build_entity(data)
        DataMapper.new(data).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
        end

        def build_entity
          Entity::Collaborator.new(
            id: nil,
            origin_id: origin_id,
            username: username,
            email: email
          )
        end

        private

        def origin_id
          @data['id']
        end

        def username
          @data['login']
        end

        def email
          @data['email']
        end
      end
    end
  end
end
