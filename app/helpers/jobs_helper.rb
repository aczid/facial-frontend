module Merb
  module JobsHelper

    def images_per_row
      4
    end

    def strip_file_extension(filename)
      filename.gsub(/\..{3,4}$/,'')
    end 

  end
  end
end # Merb
