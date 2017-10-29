# frozen_string_literal: true

module CodePraise
  module Database
    # Object Relational Mapper for Repo Entities
    class RepoOrm < Sequel::Model(:repos)
      many_to_one :owner,
                  class: :'CodePraise::Database::CollaboratorOrm'

      many_to_many :contributors,
                   class: :'CodePraise::Database::CollaboratorOrm',
                   join_table: :repos_contributors,
                   left_key: :repo_id, right_key: :collaborator_id

      plugin :timestamps, update_on_create: true

      def self.find_full_name(ownername, reponame)
        # SELECT * FROM `repos` LEFT JOIN `collaborators`
        # ON (`collaborators`.`id` = `repos`.`owner_id`)
        # WHERE ((`username` = 'owername') AND (`name` = 'reponame'))
        RepoOrm.left_join(:collaborators, id: :owner_id)
               .where(username: ownername, name: reponame)
               .first&.to_entity
      end

      def self.find_id(id)
        RepoOrm.first(id: id)&.to_entity
      end

      def self.find_origin_id(origin_id)
        RepoOrm.first(origin_id: origin_id)&.to_entity
      end

      def self.find_or_create(entity)
        find_origin_id(entity.origin_id) || create_from(entity)
      end

      def self.create_from(entity)
        new_owner = CollaboratorOrm.find_or_create(entity.owner)
        db_owner = CollaboratorOrm.first(id: new_owner.id)

        stored_repo = create(
          origin_id: entity.origin_id,
          name: entity.name,
          size: entity.size,
          git_url: entity.git_url,
          owner: db_owner,
        )

        db_contributors = entity.contributors.each do |contrib|
          stored_contrib = CollaboratorOrm.find_or_create(contrib)
          contrib = CollaboratorOrm.first(id: stored_contrib.id)
          stored_repo.add_contributor(contrib)
        end

        stored_repo.to_entity
      end

      def to_entity(entity_class = CodePraise::Entity::Repo)
        entity_class.new(
          id: id,
          origin_id: origin_id,
          name: name,
          size: size,
          git_url: git_url,
          owner: owner.to_entity,
          contributors: contributors.map(&:to_entity)
        )
      end
    end
  end
end
