# frozen_string_literal: true

module CodePraise
  # Represents essential Collaborator information for API output
  # USAGE:
  #   collab = Repository::Collaborators.find_id(1)
  #   CollaboratorRepresenter.new(collab).to_json
  class CollaboratorRepresenter < Roar::Decorator
    include Roar::JSON

    property :origin_id
    property :username
    property :email
  end
end
