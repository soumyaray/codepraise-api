# frozen_string_literal: false

require 'dry-struct'

module RepoPraise
  module Entity
    # Add dry types to Entity module
    module Types
      include Dry::Types.module
    end

    # Contributor entity objects
    class Contributor < Dry::Struct
      attribute :username, Types::Strict::String
      attribute :email, Types::Strict::String.optional
    end
  end
end
