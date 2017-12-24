# frozen_string_literal: true

require 'rake/testtask'

desc 'Print all rake commands'
task :default do
  puts `rake -T`
end

# Configuration only -- not for direct calls
task :config do
  require_relative 'config/environment.rb' # load config info
  @app = CodePraise::Api
  @config = @app.config
end

desc 'Run tests once'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
  t.warning = false
end

desc 'Keep rerunning tests upon changes'
task :respec => :config do
  puts 'REMEMBER: need to run `rake run:[dev|test]:worker` in another process'
  sh "rerun -c 'rake spec' --ignore 'coverage/*' --ignore '#{@config.REPOSTORE_PATH}/*'"
end

desc 'Run application console (pry)'
task :console do
  sh 'pry -r ./spec/test_load_all'
end

namespace :api do
  namespace :run do
    desc 'Rerun the API server in development mode'
    task :development => :config do
      puts 'REMEMBER: need to run `rake worker:run:development` in another process'
      sh "rerun -c 'rackup -p 3030' --ignore '#{@config.REPOSTORE_PATH}/*'"
    end

    desc 'Rerun the API server in test mode'
    task :test => :config do
      puts 'REMEMBER: need to run `rake worker:run:test` in another process'
      sh "rerun -c 'RACK_ENV=test rackup -p 3000' --ignore 'coverage/*' --ignore '#{@config.REPOSTORE_PATH}/*'"
    end

    desc 'Run the API server to test the client app'
    task :app_test => :config do
      puts 'REMEMBER: need to run `rake worker:run:app_test` in another process'
      sh 'RACK_ENV=test rackup -p 3000'
    end
  end
end

namespace :worker do
  namespace :run do
    desc 'Run the background cloning worker in development mode'
    task :development => :config do
      sh 'RACK_ENV=development bundle exec shoryuken -r ./workers/clone_repo_worker.rb -C ./workers/shoryuken_dev.yml'
    end

    desc 'Run the background cloning worker in testing mode'
    task :test => :config do
      sh 'RACK_ENV=test bundle exec shoryuken -r ./workers/clone_repo_worker.rb -C ./workers/shoryuken_test.yml'
    end

    desc 'Run the background cloning worker in testing mode'
    task :app_test => :config do
      sh 'RACK_ENV=app_test bundle exec shoryuken -r ./workers/clone_repo_worker.rb -C ./workers/shoryuken_test.yml'
    end

    desc 'Run the background cloning worker in production mode'
    task :production => :config do
      sh 'RACK_ENV=production bundle exec shoryuken -r ./workers/clone_repo_worker.rb -C ./workers/shoryuken.yml'
    end
  end
end

namespace :vcr do
  desc 'Delete cassette fixtures'
  task :delete do
    sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
      puts(ok ? 'Cassettes deleted' : 'No cassettes found')
    end
  end
end

namespace :repostore do
  desc 'List cloned repos in repo store'
  task :create => :config do
    puts `mkdir #{@config.REPOSTORE_PATH}`
  end

  desc 'Delete cloned repos in repo store'
  task :delete => :config do
    sh "rm -rf #{@config.REPOSTORE_PATH}/*" do |ok, _|
      puts(ok ? 'Cloned repos deleted' : "Could not delete cloned repos")
    end
  end

  desc 'List cloned repos in repo store'
  task :list => :config do
    puts `ls #{@config.REPOSTORE_PATH}`
  end
end

namespace :quality do
  CODE = '**/*.rb'

  desc 'Run all quality checks'
  task all: %i[rubocop reek flog]

  desc 'Run Rubocop quality checks'
  task :rubocop do
    sh "rubocop #{CODE}"
  end

  desc 'Run Reek quality checks'
  task :reek do
    sh "reek #{CODE}"
  end

  desc 'Run Flog quality checks'
  task :flog do
    sh "flog #{CODE}"
  end
end

namespace :queues do
  require 'aws-sdk-sqs'

  desc 'Create SQS queue for Shoryuken'
  task :create => :config do
    sqs = Aws::SQS::Client.new(region: @config.AWS_REGION)

    puts "Environment: #{@app.environment}"
    [@config.CLONE_QUEUE, @config.REPORT_QUEUE].each do |queue_name|
      begin
        sqs.create_queue(
          queue_name: queue_name,
          attributes: {
            FifoQueue: 'true',
            ContentBasedDeduplication: 'true'
          }
        )

        q_url = sqs.get_queue_url(queue_name: queue_name).queue_url
        puts 'Queue created:'
        puts "  Name: #{queue_name}"
        puts "  Region: #{@config.AWS_REGION}"
        puts "  URL: #{q_url}"
      rescue StandardError => error
        puts "Error creating queue: #{error}"
      end
    end
  end

  desc 'Purge messages in SQS queue for Shoryuken'
  task :purge => :config do
    sqs = Aws::SQS::Client.new(region: @config.AWS_REGION)

    [@config.CLONE_QUEUE, @config.REPORT_QUEUE].each do |queue_name|
      begin
        q_url = sqs.get_queue_url(queue_name: queue_name).queue_url
        sqs.purge_queue(queue_url: q_url)
        puts "Queue #{queue_name} purged"
      rescue StandardError => error
        puts "Error purging queue: #{error}"
      end
    end
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
