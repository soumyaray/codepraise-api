# frozen_string_literal: false

folders = %w[github database/orm gitrepo messaging]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
