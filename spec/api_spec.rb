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
      app.DB[:repos_contributors].delete
      app.DB[:repos].delete
      app.DB[:collaborators].delete
    end

    describe 'POSTting to create entities from Github' do
      it 'HAPPY: should retrieve and store repo and collaborators' do
        post "#{API_VER}/repo/#{USERNAME}/#{REPO_NAME}"
        _(last_response.status).must_equal 201
        _(last_response.header['Location'].size).must_be :>, 0
        repo_data = JSON.parse last_response.body
        _(repo_data.size).must_be :>, 0
      end

      it 'SAD: should report error if no Github repo found' do
        post "#{API_VER}/repo/#{USERNAME}/sad_repo_name"
        _(last_response.status).must_equal 404
      end

      it 'BAD: should report error if duplicate Github repo found' do
        post "#{API_VER}/repo/#{USERNAME}/#{REPO_NAME}"
        _(last_response.status).must_equal 201
        post "#{API_VER}/repo/#{USERNAME}/#{REPO_NAME}"
        _(last_response.status).must_equal 409
      end
    end

    describe 'GETing database entities' do
      before do
        post "#{API_VER}/repo/#{USERNAME}/#{REPO_NAME}"
      end

      it 'HAPPY: should find stored repo and collaborators' do
        get "#{API_VER}/repo/#{USERNAME}/#{REPO_NAME}"
        _(last_response.status).must_equal 200
        repo_data = JSON.parse last_response.body
        _(repo_data.size).must_be :>, 0
      end

      it 'SAD: should report error if no database repo entity found' do
        get "#{API_VER}/repo/#{USERNAME}/sad_repo_name"
        _(last_response.status).must_equal 404
      end
    end
  end
end
