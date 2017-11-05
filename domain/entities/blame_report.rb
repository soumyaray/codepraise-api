# frozen_string_literal: true

module CodePraise
  module Entity
    # Produces blame report for an entire remote repo
    # TODO: exclude folders feature, refactor, file counts
    # USAGE: (from rake console)
    #   app.reload!
    #   url = CodePraise::Repository::Repos.find_id(1).git_url
    #   report = CodePraise::BlameReport.new(app.config, url)
    #   all_report = report.file_summaries
    class BlameSummary
      attr_accessor :local
      DEFAULT_EXCLUDE_FOLDERS = %w[fixtures]

      def initialize(local_repo)
        @local = local_repo
      end

      def summarize_folder(folder_name)
        relevant_file_summaries = file_summaries.select do |summary|
          summary[:filename].start_with? folder_name
        end

        contributions = {}
        relevant_file_summaries.each do |summary|
          summary[:contributions].each do |contribution|
            email = contribution[0]
            contributions[email] ||= { name: contribution[1][:name], count: 0}
            contributions[email][:count] += contribution[1][:count]
          end
        end

        { folder_name: folder_name, contributions: contributions }
      end

      private

      def file_summaries
        return @file_summaries if @file_summaries

        file_reports = blame_all_files
        @file_summaries = file_reports.map { |file_report| summarize_file_report(file_report) }
      end

      def summarize_file_report(file_report)
        filename = file_report[0]
        line_reports = file_report[1]
        contributions = {}

        line_reports.each do |report|
          contributions[report['author-mail']] ||= { :count => 0 }
          contributions[report['author-mail']][:name] ||= report['author']
          contributions[report['author-mail']][:count] += 1
        end

        { filename: filename, contributions: contributions }
      end

      def blame_all_files
        files = @local.files
        @local.in_repo do
          files.map do |filename|
            [filename, Blame::Report.for_file(filename)]
          end
        end.to_h
      end
    end
  end
end
