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
    end
  end
end
