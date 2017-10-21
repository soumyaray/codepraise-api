# frozen_string_literal: false

require_relative 'contributor.rb'

module RepoPraise
  module Entity
    # Domain entity object for any git repos
    class Repo < Dry::Struct
      attribute :size, Types::Strict::Int
      attribute :owner, Contributor
      attribute :git_url, Types::Strict::String
      attribute :contributors, Types::Strict::Array.member(Contributor)
    end
  end
end
