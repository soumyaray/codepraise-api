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
    end
  end
end
