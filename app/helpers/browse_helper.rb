module Merb
  module BrowseHelper

    def images_per_row
      4
    end

    def friendly_name(string)
      @job.friendly_name(string)
    end

    def cleanup_filename(string)
      InverseCsvImporter.cleanup_filename(string)
    end

    def relative_images_path(str)
      File.join(@job.relative_images_path, str)
    end
  end
end # Merb
