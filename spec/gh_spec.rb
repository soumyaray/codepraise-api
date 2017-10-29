# frozen_string_literal: false

require_relative 'spec_helper.rb'
require 'econfig'

describe 'Tests Praise library' do
  extend Econfig::Shortcut
  Econfig.env = 'development'
  Econfig.root = '.'

  # GH_TOKEN = config.gh_token
  CORRECT = YAML.safe_load(File.read('spec/fixtures/gh_results.yml'))
  CASSETTE_FILE = 'github_api'.freeze

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Repo information' do
    it 'HAPPY: should provide correct repo attributes' do
      repo_mapper = CodePraise::Github::RepoMapper.new(app.config)
      repo = repo_mapper.load(USERNAME, REPO_NAME)
      _(repo.size).must_equal CORRECT['size']
      _(repo.git_url).must_equal CORRECT['git_url']
    end

    it 'SAD: should raise exception on incorrect repo' do
      proc do
        repo_mapper = CodePraise::Github::RepoMapper.new(app.config)
        repo_mapper.load(USERNAME, 'sad_repo_name')
      end.must_raise CodePraise::Github::Api::Errors::NotFound
    end

    it 'SAD: should raise exception when unauthorized' do
      proc do
        require 'ostruct'
        sad_config = OpenStruct.new(gh_token: 'sad_token')
        repo_mapper = CodePraise::Github::RepoMapper.new(sad_config)
        repo_mapper.load(USERNAME, REPO_NAME)
      end.must_raise CodePraise::Github::Api::Errors::Unauthorized
    end
  end

  describe 'Collaborator information' do
    before do
      repo_mapper = CodePraise::Github::RepoMapper.new(app.config)
      @repo = repo_mapper.load(USERNAME, REPO_NAME)
    end

    it 'HAPPY: should recognize owner' do
      _(@repo.owner).must_be_kind_of CodePraise::Entity::Collaborator
    end

    it 'HAPPY: should identify owner' do
      _(@repo.owner.username).wont_be_nil
      _(@repo.owner.username).must_equal CORRECT['owner']['login']
    end

    it 'HAPPY: should identify contributors' do
      contributors = @repo.contributors
      _(contributors.count).must_equal CORRECT['contributors'].count

      usernames = contributors.map(&:username)
      correct_usernames = CORRECT['contributors'].map { |c| c['login'] }
      _(usernames).must_equal correct_usernames
    end
  end
end
