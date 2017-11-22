require_relative 'spec_helper.rb'

describe 'Test Git Commands Mapper and Gateway' do
  CASSETTE_FILE = 'github_api'.freeze

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

  it 'HAPPY: should get blame summary for entire repo' do
    summary = @repo.folder_summary('')
    _(summary.subfolders.count).must_equal 10
    _(summary.base_files.count).must_equal 1
    _(summary.base_files.keys.first).must_equal 'init.rb'
    _(summary.subfolders.keys.first).must_equal 'views_objects'
  end

  it 'HAPPY: should get accurate blame summary for specific folder' do
    summary = @repo.folder_summary('forms');
    folder_summary = summary.subfolders
    files_summary = summary.base_files

    _(summary.subfolders.count).must_equal 2
    _(summary.subfolders['errors']['<b37582000@gmail.com>']).must_equal({name: "luyimin", count: 2})
    _(summary.subfolders['errors']['<orange6318@hotmail.com>']).must_equal({name: "SOA-KunLin", count: 1})

    _(summary.base_files.count).must_equal 2
    _(summary.base_files['url_request.rb']['<b37582000@gmail.com>']).must_equal({:count=>7, :name=>"luyimin"})
    _(summary.base_files['url_request.rb']['<orange6318@hotmail.com>']).must_equal({:count=>2, :name=>"SOA-KunLin"})
    _(summary.base_files['init.rb']['<b37582000@gmail.com>']).must_equal({:count=>6, :name=>"luyimin"})
  end
end
