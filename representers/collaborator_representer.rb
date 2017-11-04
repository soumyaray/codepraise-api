# frozen_string_literal: true

# Represents essential Collaborator information for API output
module CodePraise
  class CollaboratorRepresenter < Roar::Decorator
    include Roar::JSON

    property :origin_id
    property :username
    property :email
  end
end