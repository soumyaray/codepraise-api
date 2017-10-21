# frozen_string_literal: false

require_relative 'spec_helper.rb'

describe 'Tests Praise library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<GITHUB_TOKEN>') { GH_TOKEN }
    c.filter_sensitive_data('<GITHUB_TOKEN_ESC>') { CGI.escape(GH_TOKEN) }
  end

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
      api = RepoPraise::Github::Api.new(GH_TOKEN)
      repo_mapper = RepoPraise::Github::RepoMapper.new(api)
      repo = repo_mapper.load(USERNAME, REPO_NAME)
      _(repo.size).must_equal CORRECT['size']
      _(repo.git_url).must_equal CORRECT['git_url']
    end

    it 'SAD: should raise exception on incorrect repo' do
      proc do
        api = RepoPraise::Github::Api.new(GH_TOKEN)
        repo_mapper = RepoPraise::Github::RepoMapper.new(api)
        repo_mapper.load(USERNAME, 'sad_repo_name')
      end.must_raise RepoPraise::Github::Api::Errors::NotFound
    end

    it 'SAD: should raise exception when unauthorized' do
      proc do
        sad_api = RepoPraise::Github::Api.new('sad_token')
        repo_mapper = RepoPraise::Github::RepoMapper.new(sad_api)
        repo_mapper.load(USERNAME, REPO_NAME)
      end.must_raise RepoPraise::Github::Api::Errors::Unauthorized
    end
  end

  describe 'Contributor information' do
    before do
      api = RepoPraise::Github::Api.new(GH_TOKEN)
      repo_mapper = RepoPraise::Github::RepoMapper.new(api)
      @repo = repo_mapper.load(USERNAME, REPO_NAME)
    end

    it 'HAPPY: should recognize owner' do
      _(@repo.owner).must_be_kind_of RepoPraise::Entity::Contributor
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
