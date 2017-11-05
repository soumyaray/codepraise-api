# frozen_string_literal: true

module CodePraise
  module Blame
    # Git blame related services
    module Report
      def self.for_file(filename)
        blame_output = Git::RepoFile.new(filename).blame
        Porcelain.parse_file_blame(blame_output)
      end
    end
  end
end
