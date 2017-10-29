# frozen_string_literal: true

module CodePraise
  module Database
    # Object-Relational Mapper for Collaborators
    class CollaboratorOrm < Sequel::Model(:collaborators)
      one_to_many :owned_repos,
                  class: :'CodePraise::Database::RepoOrm',
                  key: :owner_id

      many_to_many :contributed_repos,
                   join_table: :repos_contributors,
                   left_key: :contributor_id, right_key: :repo_id

      plugin :timestamps, update_on_create: true

      def self.find_id(id)
        CollaboratorOrm.first(id: id)&.to_entity
      end

      def self.find_username(username)
        CollaboratorOrm.first(username: username)&.to_entity
      end

      def self.find_or_create(entity)
        find_username(entity.username) || create_from(entity)
      end

      def self.create_from(entity)
        stored = create(
          origin_id: entity.origin_id,
          username: entity.username,
          email: entity.email
        )

        stored.to_entity
      end

      def to_entity(entity_class = CodePraise::Entity::Collaborator)
        entity_class.new(
          id: id,
          origin_id: origin_id,
          username: username,
          email: email
        )
      end
    end
  end
end
