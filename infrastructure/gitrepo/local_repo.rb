# frozen_string_literal: true

require 'fileutils'
require_relative 'remote_repo.rb'

module Git
  module Errors
    # Local repo not setup or invalid
    InvalidLocalRepo = Class.new(StandardError)
  end

  # Manage local Git repository
  class LocalRepo
    ONLY_FOLDERS = '**/'
    FILES_AND_FOLDERS = '**/*'
    CODE_FILENAME_MATCH = /\.(rb|js|html|css|yml|json|txt)$/

    attr_reader :repo_path

    def initialize(remote, repostore_path)
      @remote = remote
      @repo_path = [repostore_path, @remote.unique_id].join('/')
    end

    def clone_remote
      @remote.local_clone(@repo_path) { |line| yield line if block_given? }
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
        Dir.glob(FILES_AND_FOLDERS).select do |path|
          File.file?(path) && (path =~ CODE_FILENAME_MATCH)
        end
      end
    end

    def in_repo(&block)
      raise_unless_setup
      Dir.chdir(@repo_path) { yield block }
    end

    def exists?
      Dir.exist? @repo_path
    end

    def delete!
      FileUtils.rm_rf(@repo_path)
    end

    private

    def raise_unless_setup
      raise Errors::InvalidLocalRepo unless exists?
    end

    def wipe
      FileUtils.rm_rf @repo_path
    end
  end
end
