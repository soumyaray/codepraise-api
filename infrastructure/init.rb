# frozen_string_literal: false

folders = %w[github database/orm gitrepo]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
