# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:repos_contributors) do
      foreign_key :repo_id, :repos
      foreign_key :collaborator_id, :collaborators
      primary_key [:repo_id, :collaborator_id]
      index [:repo_id, :collaborator_id]
    end
  end
end
