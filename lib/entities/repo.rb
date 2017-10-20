# frozen_string_literal: false

module RepoPraise
  module Entity
    # Domain entity object for any git repos
    class Repo
      attr_accessor :size, :owner, :git_url, :contributors

      def initialize(size: nil, owner: nil, git_url: nil, contributors: nil)
        @size = size
        @owner = owner
        @git_url = git_url
        @contributors = contributors
      end
    end
  end
end
