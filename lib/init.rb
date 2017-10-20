# frozen_string_literal: false

require_relative 'github_api.rb'

folders = %w(entities mappers)
folders.each do |folder|
  puts "#{folder}/init.rb"
  require_relative "#{folder}/init.rb"
end
