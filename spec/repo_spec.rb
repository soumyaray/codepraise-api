# frozen_string_literal: false

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require_relative '../lib/github_api.rb'

describe 'Tests Praise library' do
  USERNAME = 'soumyaray'.freeze
  REPO_NAME = 'YPBT-app'.freeze
  CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
  GH_TOKEN = CONFIG['gh_token']
  CORRECT = YAML.safe_load(File.read('spec/fixtures/gh_results.yml'))
  RESPONSE = YAML.load(File.read('spec/fixtures/gh_response.yml'))

  describe 'Repo information' do
    it 'HAPPY: should provide correct repo attributes' do
      repo = RepoPraise::GithubAPI.new(GH_TOKEN, cache: RESPONSE)
                                  .repo(USERNAME, REPO_NAME)
      _(repo.size).must_equal CORRECT['size']
      _(repo.git_url).must_equal CORRECT['git_url']
    end

    it 'SAD: should raise exception on incorrect repo' do
      proc do
        RepoPraise::GithubAPI.new(GH_TOKEN, cache: RESPONSE).repo('soumyaray', 'foobar')
      end.must_raise RepoPraise::GithubAPI::Errors::NotFound
    end

    # it 'SAD: should raise exception when unauthorized' do
    #   proc do
    #     RepoPraise::Repo.from_github('bad_token', 'soumyaray', 'foobar')
    #   end.must_raise RepoPraise::GithubAPI::Errors::Unauthorized
    # end
  end

  describe 'Contributor information' do
    before do
      @repo = RepoPraise::GithubAPI.new(GH_TOKEN, cache: RESPONSE).repo(USERNAME, REPO_NAME)
    end

    it 'HAPPY: should recognize owner' do
      _(@repo.owner).must_be_kind_of RepoPraise::Contributor
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
