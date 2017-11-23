# frozen_string_literal: true

module CodePraise
  # Web API
  class Api < Roda
    route('summary') do |routing|
      # #{API_ROOT}/summary index request
      routing.is do
        routing.get do
        end
      end
    end
  end
end