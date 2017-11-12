# frozen_string_literal: true

require_relative 'repo_representer'

# Represents essential Repo information for API output
module CodePraise
  class ReposRepresenter < Roar::Decorator
    include Roar::JSON

    collection :repos, extend: RepoRepresenter
  end
end
