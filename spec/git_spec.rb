require_relative 'spec_helper.rb'

describe 'Test Git Commands Mapper and Gateway' do
  CASSETTE_FILE = 'codepraise_api'.freeze

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]

    app.DB[:repos_contributors].delete
    app.DB[:repos].delete
    app.DB[:collaborators].delete

    CodePraise::LoadFromGithub.new.call(
      config: app.config,
      ownername: USERNAME,
      reponame: REPO_NAME
    )

    @repo = CodePraise::Repository::Repos.find_full_name(USERNAME, REPO_NAME)
  end

  after do
    VCR.eject_cassette
  end

  it 'HAPPY: should get blame summary for a remote repo' do
    summary = CodePraise::Blame::Summary.new(@repo)
    full_repo_summary = summary.for_folder('')
    _(full_repo_summary.contributions.count).must_equal 3

    first_collab = full_repo_summary.contributions['<tearsgundam@gmail.com>']
    _(first_collab[:count]).must_equal 657
    _(first_collab[:name]).must_equal 'Yuan Yu'
  end
end
