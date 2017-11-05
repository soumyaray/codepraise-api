# frozen_string_literal: true

module Git
  # Blame output for a single file
  class RepoFile
    BLAME_CMD = 'git blame --line-porcelain'

    attr_reader :filename

    def initialize(filename)
      @filename = filename
    end

    def blame
      @blame_output ||= `#{BLAME_CMD} #{@filename}`
    end
  end
end
