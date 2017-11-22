# frozen_string_literal: true

module CodePraise
  module Blame
    # Git blame parsing and reporting services
    class Reporter
      def initialize(git_url, config = CodePraise::Api.config)
        origin = Git::RemoteRepo.new(git_url)
        @local = Git::LocalRepo.new(origin, config.REPOSTORE_PATH)
      end

      def folder_report(folder_name)
        folder_name = '' if folder_name == '/'
        files = @local.files.select { |file| file.start_with? folder_name }
        @local.in_repo do
          files.map do |filename|
            [filename, file_report(filename)]
          end
        end.to_h
      end

      def files(folder_name)
        @local.files.select { |file| file.start_with? folder_name }
      end

      def subfolders(folder_name)
        @local.folder_structure[folder_name]
      end

      def folder_structure
        @local.folder_structure
      end

      def file_report(filename)
        blame_output = Git::RepoFile.new(filename).blame
        Porcelain.parse_file_blame(blame_output)
      end
    end
  end
end
