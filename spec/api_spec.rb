# frozen_string_literal: false

require_relative 'spec_helper.rb'

describe 'Tests Praise library' do
  API_VER = 'api/v0.1'.freeze
  CASSETTE_FILE = 'codepraise_api'.freeze

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Repo information' do
    before do
      # DatabaseCleaner.clean
      Rake::Task['db:reset'].invoke
    end

    it 'HAPPY: should retrieve and store repo and collaborators' do
      post "#{API_VER}/repo/#{USERNAME}/#{REPO_NAME}"
      _(last_response.status).must_equal 200
      repo_data = JSON.parse last_response.body
      _(repo_data.size).must_be :>, 0
    end

    it 'HAPPY: should find stored repo and collaborators' do
      post "#{API_VER}/repo/#{USERNAME}/#{REPO_NAME}"

      get "#{API_VER}/repo/#{USERNAME}/#{REPO_NAME}"
      _(last_response.status).must_equal 200
      repo_data = JSON.parse last_response.body
      _(repo_data.size).must_be :>, 0
    end
  end
end
