# frozen_string_literal: true

require 'fileutils'
require 'base64'

module Git
  module Errors
    # Local repo not setup or invalid
    InvalidLocalRepo = Class.new(StandardError)
  end

  # Manage remote Git repository for cloning
  class RemoteRepo
    attr_reader :git_url

    def initialize(git_url)
      @git_url = git_url
    end

    def local_clone(path)
      `git clone #{@git_url} #{path}`
    end

    def unique_id
      Base64.urlsafe_encode64(Digest::SHA256.digest @git_url)
    end
  end

  # Manage local Git repository
  class LocalRepo
    ONLY_FOLDERS = '**/'
    FILES_AND_FOLDERS = '**/*'

    def initialize(remote, repostore_path)
      @remote = remote
      @repo_path = [repostore_path, @remote.unique_id].join('/')
    end

    def clone_remote
      @remote.local_clone(@repo_path)
      self
    end

    def folder_structure
      raise_unless_setup
      return @folder_structure if @folder_structure
      @folder_structure = { '/' => [] }

      in_repo do
        all_folders = Dir.glob(ONLY_FOLDERS)
        all_folders.each do |full_path|
          parts = full_path.split('/')
          parent = (parts.length == 1) ? '/' : parts[0..-2].join('/')
          (@folder_structure[parent] ||= []).push(full_path)
        end
      end

      @folder_structure
    end

    def files
      raise_unless_setup
      return @files if @files

      @files = in_repo do
        Dir.glob(FILES_AND_FOLDERS)
           .select { |disk_entity| File.file? disk_entity }
      end
    end

    def in_repo(&block)
      Dir.chdir @repo_path { yield block }
    end

    def exists?
      Dir.exist? @repo_path
    end

    private

    def blame_file(filename)
      BlameFile.new(filename)
    end

    def raise_unless_setup
      raise Errors::InvalidLocalRepo unless exists?
    end

    def wipe
      FileUtils.rm_rf @repo_path
    end
  end
end

# load 'infrastructure/gitrepo/gitrepo.rb'
# origin = Git::RemoteRepo.new('git@github.com:soumyaray/YPBT-app.git')
# local = Git::LocalRepo.new(origin, 'infrastructure/gitrepo/repostore')
