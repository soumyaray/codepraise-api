# frozen_string_literal: true

module Git
  module Blame
    # Blame output for a single file
    class FileBlame
      BLAME_CMD = 'git blame --line-porcelain'

      attr_reader :filename

      def initialize(filename)
        @filename = filename
      end

      def blame_report
        PorcelainParser.call(blame_output).report
      end

      private

      def blame_output
        @blame_output ||= `#{BLAME_CMD} #{@filename}`
      end
    end
  end
end
