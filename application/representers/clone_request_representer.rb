# frozen_string_literal: true

require_relative 'collaborator_representer'

# Represents essential Repo information for API output
module CodePraise
  class CloneRequestRepresenter < Roar::Decorator
    include Roar::JSON

    property :repo, extend: RepoRepresenter, class: OpenStruct
    property :id
  end
end
