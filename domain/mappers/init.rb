# frozen_string_literal: true

folders = %w[github_mappers git_mappers blame_mappers]

folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
