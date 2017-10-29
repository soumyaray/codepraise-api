# frozen_string_literal: false

require 'dry-struct'

module CodePraise
  module Entity
    # Domain entity object for git contributors
    class Collaborator < Dry::Struct
      attribute :id, Types::Int.optional
      attribute :origin_id, Types::Strict::Int
      attribute :username, Types::Strict::String
      attribute :email, Types::Strict::String.optional
    end
  end
end
