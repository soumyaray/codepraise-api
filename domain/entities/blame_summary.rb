# frozen_string_literal: true

module CodePraise
  module Entity
    # TODO: exclude folders feature, refactor, file counts

    # Summarizes blame reports for an entire folder
    class FolderSummary
      attr_reader :folder_name

      def initialize(folder_name, blame_reports)
        @folder_name = folder_name
        @blame_reports = blame_reports
      end

      def contributions
        file_summaries.each_with_object({}) do |summary, contributions|
          summary.contributions.each do |contribution|
            email = contribution[0]
            contributions[email] ||= { name: contribution[1][:name], count: 0 }
            contributions[email][:count] += contribution[1][:count]
          end
        end
      end

      private

      def file_summaries
        @file_summaries ||=
          @blame_reports.map { |file_report| FileSummary.new(file_report) }
      end
    end

    # Summarizes a single file's blame report
    class FileSummary
      attr_reader :file_report, :contributions

      def initialize(file_report)
        @filename = file_report[0]
        @contributions = summarize_line_reports(file_report[1])
      end

      private

      def summarize_line_reports(line_reports)
        line_reports.each_with_object({}) do |report, contributions|
          contributions[report['author-mail']] ||= { count: 0 }
          contributions[report['author-mail']][:name] ||= report['author']
          contributions[report['author-mail']][:count] += 1
        end
      end
    end
  end
end
