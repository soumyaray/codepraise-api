# frozen_string_literal: true

require 'rake/testtask'

task :default do
  puts `rake -T`
end

# Configuration only -- not for direct calls
task :config do
  require_relative 'config/environment.rb' # load config info
  @app = CodePraise::Api
  @config = @app.config
end

desc 'run tests'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
  t.warning = false
end

desc 'rerun tests'
task :respec => :config do
  puts 'REMEMBER: need to run `rake run:[dev|test]:worker` in another process'
  sh "rerun -c 'rake spec' --ignore 'coverage/*' --ignore '#{@config.REPOSTORE_PATH}/*'"
end

desc 'run application console (pry)'
task :console do
  sh 'pry -r ./spec/test_load_all'
end

namespace :run do
  namespace :api do
    task :dev => :config do
      puts 'REMEMBER: need to run `rake run:dev:worker` in another process'
      sh "rerun -c 'rackup -p 3030' --ignore 'coverage/*' --ignore '#{@config.REPOSTORE_PATH}/*'"
    end

    task :test => :config do
      puts 'REMEMBER: need to run `rake run:test:worker` in another process'
      sh "rerun -c 'RACK_ENV=test rackup -p 3000' --ignore 'coverage/*' --ignore '#{@config.REPOSTORE_PATH}/*'"
    end
  end

  namespace :worker do
    task :dev => :config do
      sh 'bundle exec shoryuken -r ./workers/clone_repo_worker.rb -C ./workers/shoryuken.yml'
    end

    task :test => :config do
      sh 'RACK_ENV=test bundle exec shoryuken -r ./workers/clone_repo_worker.rb -C ./workers/shoryuken_test.yml'
    end
  end
end

namespace :ls do
  desc 'list cloned repos in repo store'
  task :repostore => :config do
    puts `ls #{@config.REPOSTORE_PATH}`
  end
end

namespace :rm do
  desc 'delete cassette fixtures'
  task :vcr do
    sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
      puts(ok ? 'Cassettes deleted' : 'No cassettes found')
    end
  end

  desc 'delete cloned repos in repo store'
  task :repostore => :config do
    sh "rm -rf #{@config.REPOSTORE_PATH}/*" do |ok, _|
      puts(ok ? 'Cloned repos deleted' : "Could not delete cloned repos")
    end
  end
end

namespace :quality do
  CODE = '**/*.rb'

  desc 'run all quality checks'
  task all: %i[rubocop reek flog]

  task :rubocop do
    sh "rubocop #{CODE}"
  end

  task :reek do
    sh "reek #{CODE}"
  end

  task :flog do
    sh "flog #{CODE}"
  end
end

namespace :db do
  require_relative 'config/environment.rb' # load config info
  require 'sequel' # TODO: remove after create orm

  Sequel.extension :migration
  app = CodePraise::Api

  desc 'Run migrations'
  task :migrate do
    puts "Migrating #{app.environment} database to latest"
    Sequel::Migrator.run(app.DB, 'infrastructure/database/migrations')
  end

  desc 'Drop all tables'
  task :drop do
    require_relative 'config/environment.rb'
    # drop according to dependencies
    app.DB.drop_table :repos_contributors
    app.DB.drop_table :repos
    app.DB.drop_table :collaborators
    app.DB.drop_table :schema_info
  end

  desc 'Reset all database tables'
  task reset: [:drop, :migrate]

  desc 'Delete dev or test database file'
  task :wipe do
    if app.environment == :production
      puts 'Cannot wipe production database!'
      return
    end

    FileUtils.rm(app.config.DB_FILENAME)
    puts "Deleted #{app.config.DB_FILENAME}"
  end
end

namespace :queue do
  require 'aws-sdk-sqs'

  desc "Create SQS queue for Shoryuken"
  task :create => :config do
    sqs = Aws::SQS::Client.new(region: @config.AWS_REGION)

    begin
      queue = sqs.create_queue(
        queue_name: @config.CLONE_QUEUE,
        attributes: {
          FifoQueue: 'true',
          ContentBasedDeduplication: 'true'
        }
      )

      q_url = sqs.get_queue_url(queue_name: @config.CLONE_QUEUE)
      puts "Queue created:"
      puts "Name: #{@config.CLONE_QUEUE}"
      puts "Region: #{@config.AWS_REGION}"
      puts "URL: #{q_url.queue_url}"
      puts "Environment: #{@app.environment}"
    rescue => e
      puts "Error creating queue: #{e}"
    end
  end

  task :purge => :config do
    sqs = Aws::SQS::Client.new(region: @config.AWS_REGION)

    begin
      queue = sqs.purge_queue(queue_url: @config.CLONE_QUEUE_URL)
      puts "Queue #{@config.CLONE_QUEUE} purged"
    rescue => e
      puts "Error purging queue: #{e}"
    end
  end
end
