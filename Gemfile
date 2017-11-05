# frozen_string_literal: false

source 'https://rubygems.org'

# Networking gems
gem 'http'

# Web app related
gem 'econfig'
gem 'puma'
gem 'roda'

# Database related
gem 'hirb'
gem 'sequel'

# Data gems
gem 'dry-struct'
gem 'dry-types'

# Representers
gem 'roar'
gem 'multi_json'

# Services
gem 'dry-monads'
gem 'dry-transaction'

group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'rack-test'
  gem 'rake'
  gem 'simplecov'
  gem 'vcr'
  gem 'webmock'
end

group :development, :test do
  gem 'sqlite3'

  gem 'database_cleaner'

  gem 'pry'
  gem 'rerun'

  gem 'flog'
  gem 'reek'
  gem 'rubocop'
end
