# frozen_string_literal: true

module Git
  # Produces blame report for an entire remote repo
  class RepoBlame
    def initialize(config, git_url)
      @config = config
      @git_url = git_url
      @local = prepare_local_repo
    end

    def call
      @local.in_repo do
        @local.files.map do |filename|
          [file_name, Blame::FileBlame.new(filename).report]
        end.to_h
      end
    end

    private

    def prepare_local_repo
      origin = Git::RemoteRepo.new(@git_url)
      local = Git::LocalRepo.new(origin, @config.repostore_path)
      local.tap { |gitrepo| gitrepo.clone_remote unless gitrepo.exists? }
    end
  end
end
