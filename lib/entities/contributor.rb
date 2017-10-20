# frozen_string_literal: false

module RepoPraise
  module Entity
    # Domain entity object for any git repos
    class Contributor
      attr_accessor :username, :email

      def initialize(username: nil, email: nil)
        @username = username
        @email = email
      end
    end
  end
end