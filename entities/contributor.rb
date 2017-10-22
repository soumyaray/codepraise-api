# frozen_string_literal: false

require 'dry-struct'

module CodePraise
  module Entity
    # Domain entity object for git contributors
    class Contributor < Dry::Struct
      attribute :username, Types::Strict::String
      attribute :email, Types::Strict::String.optional
    end
  end
end
