# frozen_string_literal: true

require_relative 'load_all'
require 'http'
require 'econfig'
require 'shoryuken'

# Shoryuken worker class to clone repos in parallel
class CloneRepoWorker
  extend Econfig::Shortcut
  Econfig.env = ENV['RACK_ENV'] || 'development'
  Econfig.root = File.expand_path('..', File.dirname(__FILE__))

  require_relative 'test_helper' if ENV['RACK_ENV'] == 'test'

  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: config.AWS_ACCESS_KEY_ID,
    secret_access_key: config.AWS_SECRET_ACCESS_KEY,
    region: config.AWS_REGION
  )

  include Shoryuken::Worker
  shoryuken_options queue: config.CLONE_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, request_json)
    clone_request = CodePraise::CloneRequestRepresenter
                    .new(CodePraise::CloneRequest.new)
                    .from_json(request_json)
    gitrepo = CodePraise::GitRepo.new(clone_request.repo)
    return if gitrepo.exists_locally?
    gitrepo.clone! { |line| update_progress(clone_request.id, line) }
  end

  private

  CLONE_PROGRESS = {
    'START'     =>  15,
    'Cloning'   =>  30,
    'remote'    =>  70,
    'Receiving' =>  85,
    'Resolving' =>  95,
    'Checking'  => 100
  }.freeze

  def update_progress(channel_id, line)
    percent = progress(line).to_s
    publish(channel_id, percent)
  end

  def publish(channel, message)
    puts "Posting progress: #{message}"
    HTTP.headers(content_type: 'application/json')
        .post(
          "#{CloneRepoWorker.config.API_URL}/faye",
          body: {
            channel: "/#{channel}",
            data: message
          }.to_json
        )
  end

  def progress(line)
    CLONE_PROGRESS[first_word_of(line)]
  end

  def first_word_of(line)
    line.match(/^[A-Za-z]+/).to_s
  end
end
