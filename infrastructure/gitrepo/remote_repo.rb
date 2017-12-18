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

    def unique_id
      Base64.urlsafe_encode64(Digest::SHA256.digest(@git_url))
    end

    def local_clone(path)
      command = "git clone --progress #{@git_url} #{path} 2>&1"

      IO.popen(command).each do |line|
        yield line if block_given?
      end
    end
  end
end
