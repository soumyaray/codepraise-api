# frozen_string_literal: true

module CodePraise
  module Repository
    # Repository for Repo Entities
    class Repos
      def self.all
        Database::RepoOrm.all.map { |db_repo| rebuild_entity(db_repo) }
      end

      def self.find_full_name(ownername, reponame)
        # SELECT * FROM `repos` LEFT JOIN `collaborators`
        # ON (`collaborators`.`id` = `repos`.`owner_id`)
        # WHERE ((`username` = 'owername') AND (`name` = 'reponame'))
        db_repo = Database::RepoOrm.left_join(:collaborators, id: :owner_id)
                                   .where(username: ownername, name: reponame)
                                   .first
        rebuild_entity(db_repo)
      end

      def self.find(entity)
        find_origin_id(entity.origin_id)
      end

      def self.find_id(id)
        db_record = Database::RepoOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find_origin_id(origin_id)
        db_record = Database::RepoOrm.first(origin_id: origin_id)
        rebuild_entity(db_record)
      end

      def self.all
        Database::RepoOrm.all.map { |db_repo| rebuild_entity(db_repo) }
      end

      def self.create(entity)
        raise 'Repo already exists' if find(entity)

        new_owner = Collaborators.find_or_create(entity.owner)
        db_owner = Database::CollaboratorOrm.first(id: new_owner.id)

        db_repo = Database::RepoOrm.create(
          origin_id: entity.origin_id,
          name: entity.name,
          size: entity.size,
          git_url: entity.git_url,
          owner: db_owner
        )

        entity.contributors.each do |contrib|
          stored_contrib = Collaborators.find_or_create(contrib)
          contrib = Database::CollaboratorOrm.first(id: stored_contrib.id)
          db_repo.add_contributor(contrib)
        end

        rebuild_entity(db_repo)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        contribs = db_record.contributors.map do |db_contrib|
          Collaborators.rebuild_entity(db_contrib)
        end

        Entity::Repo.new(
          id: db_record.id,
          origin_id: db_record.origin_id,
          name: db_record.name,
          size: db_record.size,
          git_url: db_record.git_url,
          owner: Collaborators.rebuild_entity(db_record.owner),
          contributors: contribs
        )
      end
    end
  end
end
