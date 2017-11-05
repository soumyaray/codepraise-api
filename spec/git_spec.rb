require_relative 'spec_helper.rb'

describe 'Test Git Commands Mapper and Gateway' do
  before do
    git_url = 'git://github.com/soumyaray/YPBT-app.git'
    origin = Git::RemoteRepo.new(git_url)
    @local_repo = Git::LocalRepo.new(origin, app.config.repostore_path)
    @local_repo.clone_remote unless @local_repo.exists?
  end

  it 'HAPPY: should get blame summary for a remote repo' do
    # post "#{API_VER}/repo/#{USERNAME}/#{REPO_NAME}"
    # puts "#{API_VER}/repo/#{USERNAME}/#{REPO_NAME}"
    # _(last_response.status).must_equal 200
    report = CodePraise::Entity::BlameSummary.new(@local_repo)
    # _(report.local.files.count).must_be :>, 0
    # all_report = report.file_summaries
    report.summarize_folder('')
  end
end