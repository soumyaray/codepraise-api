require 'http'
require 'yaml'

config = YAML.safe_load(File.read('config/secrets.yml'))

def gh_api_path(path)
  'https://api.github.com/repos/' + path
end

def call_gh_url(config, url)
  HTTP.headers('Accept' => 'application/vnd.github.v3+json',
               'Authorization' => "token #{config['gh_token']}").get(url)
end

gh_response = {}
gh_results = {}

gh_response['repo'] = call_gh_url(config, gh_api_path('soumyaray/YPBT-app'))
repo = gh_response['repo'].parse

gh_results['size'] = repo['size']
# should be 551

gh_results['owner'] = repo['owner']
# should have info about Soumya

gh_results['git_url'] = repo['git_url']
# should be "git://github.com/soumyaray/YPBT-app.git"

gh_results['contributors_url'] = repo['contributors_url']
# "should be https://api.github.com/repos/soumyaray/YPBT-app/contributors"

gh_response['contributors'] = call_gh_url(config, repo['contributors_url'])
contributors = gh_response['contributors'].parse

gh_results['contributors'] = contributors
contributors.count
# should be 3 contributors array

contributors.map { |c| c['login'] }
# should be ["Yuan-Yu", "SOA-KunLin", "luyimin"]

File.write('spec/fixtures/gh_response.yml', gh_response.to_yaml)
File.write('spec/fixtures/gh_results.yml', gh_results.to_yaml)
