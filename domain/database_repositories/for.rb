# frozen_string_literal: true

module CodePraise
  module Repository
    For = {
      Entity::Repo         => Repos,
      Entity::Collaborator => Collaborators
    }.freeze
  end
end
