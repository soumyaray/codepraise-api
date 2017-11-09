# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:repos) do
      primary_key :id
      Integer     :origin_id, unique: true
      foreign_key :owner_id, :collaborators

      String      :name
      String      :git_url
      Integer     :size

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
