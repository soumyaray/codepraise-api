# frozen_string_literal: true

module CodePraise
  # Maps over local and remote git repo infrastructure
  class GitRepo
    MAX_SIZE = 1000 # for cloning, analysis, summaries, etc.

    class Errors
      NoGitRepoFound = Class.new(StandardError)
      TooLargeToClone = Class.new(StandardError)
      CannotOverwriteLocalRepo = Class.new(StandardError)
    end

    def initialize(repo, config = CodePraise::Api.config)
      @repo = repo
      remote = Git::RemoteRepo.new(@repo.git_url)
      @local = Git::LocalRepo.new(remote, config.REPOSTORE_PATH)
    end

    def local
      raise Errors::NoGitRepoFound unless exists_locally?
      @local
    end

    def delete!
      @local.delete!
    end

    def too_large?
      @repo.size > MAX_SIZE
    end

    def exists_locally?
      @local.exists?
    end

    def clone!
      raise Errors::TooLargeToClone if too_large?
      raise Errors::CannotOverwriteLocalRepo if exists_locally?
      @local.clone_remote { |line| yield line if block_given? }
    end
  end
end
