# frozen_string_literal: true

module CodePraise
  module Blame
    # Git blame parsing and reporting services
    class Summary
      def initialize(gitrepo)
        @gitrepo = gitrepo
      end

      def for_folder(folder_name)
        blame_reports = Blame::Reporter.new(@gitrepo).folder_report(folder_name)
        Entity::FolderSummary.new(@repo, folder_name, blame_reports)
      end
    end
  end
end