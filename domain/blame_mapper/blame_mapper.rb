# frozen_string_literal: true

module CodePraise
  module Blame
    # Parses git blame porcelain: https://git-scm.com/docs/git-blame/1.6.0
    class Report
      def self.for_file(filename)
        blame_output = Git::RepoFile.new(filename).blame
        Porcelain.parse_file_blame(blame_output)
      end
    end
  end
end
