# frozen_string_literal: true

require_relative 'repo_representer'

# Represents essential Repo information for API output
module CodePraise
  # Representer object for repo clone requests
  class CloneRequestRepresenter < Roar::Decorator
    include Roar::JSON

    property :repo, extend: RepoRepresenter, class: OpenStruct
    property :id
  end
end
