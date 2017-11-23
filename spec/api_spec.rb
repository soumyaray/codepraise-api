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
        _(last_response.status).must_equal 400
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
        CodePraise::LoadFromGithub.new.call(
          config: app.config,
          ownername: USERNAME,
          reponame: REPO_NAME
        )
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

    describe 'GETting blame summary pages' do
      before do
        CodePraise::LoadFromGithub.new.call(
          config: app.config,
          ownername: USERNAME,
          reponame: REPO_NAME
        )
      end

      it '(HAPPY) should get blame summary for root of loaded repo' do
        get "#{API_VER}/summary/#{USERNAME}/#{REPO_NAME}"
        summary = JSON.parse last_response.body
        _(last_response.status).must_equal 200
        _(summary['folder_name']).must_equal ''
        _(summary['base_files'].keys.count).must_equal 1
        _(summary['subfolders'].keys.count).must_equal 10
      end

      it '(HAPPY) should get blame summary for any folder of loaded repo' do
        get "#{API_VER}/summary/#{USERNAME}/#{REPO_NAME}/forms"
        _(last_response.status).must_equal 200
        summary = JSON.parse last_response.body
        _(summary.keys).must_equal %w(folder_name subfolders base_files)
        _(summary['folder_name']).must_equal 'forms'
        _(summary['base_files'].keys).must_equal %w(url_request.rb init.rb)
        _(summary['subfolders'].keys).must_equal %W(#{''} errors)
      end

      it '(SAD) should report error for repos not loaded' do
        get "#{API_VER}/summary/#{USERNAME}/bad_repo"
        _(last_response.status).must_equal 404
      end

      it '(SAD) should report error for subfolders if repos not loaded' do
        get "#{API_VER}/summary/#{USERNAME}/bad_repo/bad_folder"
        _(last_response.status).must_equal 404
      end
    end
  end
end
