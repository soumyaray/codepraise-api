# frozen_string_literal: true

require 'roda'
require_relative 'route_helpers'

module CodePraise
  # Web API
  class Api < Roda
    plugin :all_verbs
    plugin :multi_route

    require_relative 'repo_controller'
    require_relative 'summary_controller'

    route do |routing|
      response['Content-Type'] = 'application/json'

      # GET / request
      routing.root do
        message = "CodePraise API v0.1 up in #{Api.environment} mode"
        HttpResponseRepresenter.new(Result.new(:ok, message)).to_json
      end

      routing.on 'api' do
        # /api/v0.1 branch
        routing.on 'v0.1' do
          @api_root = '/api/v0.1'
          routing.multi_route
        end
      end
    end
  end
end
