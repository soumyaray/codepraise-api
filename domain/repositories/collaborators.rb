# frozen_string_literal: true

module CodePraise
  module Repository
    # Repository for Collaborators
    class Collaborators
      def self.find_id(id)
        db_record = Database::CollaboratorOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find_username(username)
        db_record = Database::CollaboratorOrm.first(username: username)
        rebuild_entity(db_record)
      end

      def self.find_or_create(entity)
        find_username(entity.username) || create(entity)
      end

      def self.create(entity)
        db_collaborator = Database::CollaboratorOrm.create(
          origin_id: entity.origin_id,
          username: entity.username,
          email: entity.email
        )

        self.rebuild_entity(db_collaborator)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Collaborator.new(
          id: db_record.id,
          origin_id: db_record.origin_id,
          username: db_record.username,
          email: db_record.email
        )
      end
    end
  end
end
