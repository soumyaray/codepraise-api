# frozen_string_literal: false

require_relative 'collaborator.rb'

module CodePraise
  module Entity
    # Domain entity object for any git repos
    class Repo < Dry::Struct
      attribute :id, Types::Int.optional
      attribute :origin_id, Types::Strict::Int
      attribute :name, Types::Strict::String
      attribute :size, Types::Strict::Int
      attribute :git_url, Types::Strict::String
      attribute :owner, Collaborator
      attribute :contributors, Types::Strict::Array.member(Collaborator)

      MAX_SIZE = 1000 # for cloning, analysis, summaries, etc.

      def summarizable?
        size < MAX_SIZE
      end

      def folder_summary(folder_name)
        Blame::Summary.new(self).for_folder(folder_name) if summarizable?
      end
    end
  end
end
