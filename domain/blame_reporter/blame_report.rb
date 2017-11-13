# frozen_string_literal: true

module CodePraise
  module Blame
    # Produces blame report for an entire remote repo
    # USAGE: (from rake console)
    # app.reload!
    # repo = CodePraise::Repository::Repos.find_id(1)
    # summary = CodePraise::Blame::Summary.new(repo)
    # root_summary = summary.for_folder('');
    # root_summary.contributions

    class Summary
      DEFAULT_EXCLUDE_FOLDERS = %w[fixtures].freeze

      def initialize(repo, config = CodePraise::Api.config)
        origin = Git::RemoteRepo.new(repo.git_url)
        @local = Git::LocalRepo.new(origin, config.REPOSTORE_PATH)
        @blame_reports = Blame::Report.new(@local)
      end

      def for_folder(folder_name)
        reports = @blame_reports.in_folder(folder_name)
        Entity::FolderSummary.new(folder_name, reports)
      end
    end

    # Git blame related services
    class Report
      def initialize(local_gitrepo)
        @local = local_gitrepo
      end

      def in_folder(folder_name)
        files = @local.files.select { |file| file.start_with? folder_name }
        @local.in_repo do
          files.map do |filename|
            [filename, report_for_file(filename)]
          end
        end.to_h
      end

      private

      def report_for_file(filename)
        blame_output = Git::RepoFile.new(filename).blame
        Porcelain.parse_file_blame(blame_output)
      end
    end
  end
end
