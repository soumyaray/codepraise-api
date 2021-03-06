# frozen_string_literal: true

require 'dry/transaction'

module CodePraise
  # Transaction to summarize folder from local repo
  class SummarizeFolder
    include Dry::Transaction

    step :find_repo
    step :clone_repo
    step :summarize_folder

    def find_repo(input)
      input[:gitrepo] = GitRepo.new(input[:repo])
      Right(input)
    end

    def clone_repo(input)
      if input[:gitrepo].exists_locally?
        Right(input)
      else
        clone_request_msg = clone_request_json(input)
        notify_clone_listeners(clone_request_msg, input[:config])
        Left(Result.new(:processing, id: input[:id]))
      end
    rescue StandardError => error
      puts "ERROR: SummarizeFolder#clone_repo - #{error.inspect}"
      Left(Result.new(:internal_error, 'Could not clone repo'))
    end

    def summarize_folder(input)
      folder_summary = Blame::Summary
                       .new(input[:gitrepo])
                       .for_folder(input[:folder])
      Right(Result.new(:ok, folder_summary))
    rescue StandardError
      Left(Result.new(:internal_error, 'Could not summarize folder'))
    end

    private

    def clone_request_json(input)
      clone_request = CloneRequest.new(input[:repo], input[:id])
      CloneRequestRepresenter.new(clone_request).to_json
    end

    def notify_clone_listeners(message, config)
      config.CLONE_LISTENERS.split.each do |queue_name|
        queue_url = config.send(queue_name)
        report_queue = Messaging::Queue.new(queue_url)
        report_queue.send(message)
      end
    end
  end
end
