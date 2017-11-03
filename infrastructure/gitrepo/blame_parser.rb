# frozen_string_literal: true

module CodePraise
  module GitBlame
    # Parses git blame porcelain: https://git-scm.com/docs/git-blame/1.6.0
    class PorcelainParser
      CODE_LINE_REGEX = /(\n\t[^\n]*\n)/
      NEWLINE = "\n"

      def initialize(output)
        @output = output
      end

      def report
        line_blocks = PorcelainParser.split_by_line_porcelain(@output)
        line_blocks.map do |line_blame|
          PorcelainParser.parse_line_porcelain(line_blame)
        end
      end

      def self.split_by_line_porcelain(output)
        header_code = output.split(CODE_LINE_REGEX)
        header_code.each_slice(2).map { |slice| slice.join }
      end

      def self.parse_line_porcelain(porcelain)
        line_block = porcelain.split(NEWLINE)
        line_report = {
          'line_num' => parse_first_line(line_block[0]),
          'code' => line_block[-1]
        }

        line_block[1..-2].each do |line|
          parsed = parse_key_value_line(line)
          line_report[parsed[:key]] = parsed[:value] if parsed
        end

        line_report
      end

      def self.parse_first_line(first_line)
        elements = first_line.split(/\s/)
        element_names = %w[sha linenum_original linenum_final group_count]
        [element_names].zip(elements).to_h
      end

      def self.parse_key_value_line(line)
        line.match(/^(?<key>\S*) (?<value>.*)/)
      end
    end
  end
end
