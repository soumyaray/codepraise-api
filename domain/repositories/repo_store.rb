# frozen_string_literal: true

module CodePraise
  module Repository
    # Collection of all local git repo clones
    class RepoStore
      def self.all
        repos = Repository::Repos.all
        repos.map do |repo|
          gitrepo = GitRepo.new(repo)
          gitrepo.exists_locally? ? gitrepo : nil
        end.compact
      end

      def self.delete_all!
        all.each(&:delete!)
      end
    end
  end
end
