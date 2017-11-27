# frozen_string_literal: true

module CodePraise
  module Blame
    # Git blame parsing and reporting services
    class Summary
      MAX_SIZE = 1000 # for cloning, analysis, summaries, etc.

      module Errors
        TooLargeToSummarize = Class.new(StandardError)
      end

      def initialize(repo)
        @repo = repo
      end

      def too_large?
        @repo.size > MAX_SIZE
      end

      def for_folder(folder_name)
        raise TooLargeToSummarize if too_large?
        blame_reports = Blame::Reporter.new(@repo).folder_report(folder_name)
        Entity::FolderSummary.new(@repo, folder_name, blame_reports)
      end
    end
  end
end