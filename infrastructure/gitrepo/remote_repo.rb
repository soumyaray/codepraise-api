# frozen_string_literal: true

require 'base64'

module Git
  # USAGE:
  #   load 'infrastructure/gitrepo/gitrepo.rb'
  #   origin = Git::RemoteRepo.new('git@github.com:soumyaray/YPBT-app.git')
  #   local = Git::LocalRepo.new(origin, 'infrastructure/gitrepo/repostore')

  # Manage remote Git repository for cloning
  class RemoteRepo
    attr_reader :git_url

    def initialize(git_url)
      @git_url = git_url
    end

    def local_clone(path)
      `git clone --progress #{@git_url} #{path} 2>&1`

      # Cloning into 'infrastructure/gitrepo/repostore/test_cmdline'...
      # remote: Counting objects: 860, done.
      # remote: Total 860 (delta 0), reused 0 (delta 0), pack-reused 860
      # Receiving objects: 100% (860/860), 543.83 KiB | 0 bytes/s, done.
      # Resolving deltas: 100% (516/516), done.
      # Checking connectivity... done.
    end

    def unique_id
      Base64.urlsafe_encode64(Digest::SHA256.digest(@git_url))
    end
  end
end
