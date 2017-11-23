# frozen_string_literal: true

module CodePraise
  # Represents folder summary about repo's folder
  class FolderSummaryRepresenter < Roar::Decorator
    include Roar::JSON

    property :folder_name
    property :subfolders
    property :base_files
  end
end