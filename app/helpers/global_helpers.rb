module Merb
  module GlobalHelpers
    # helpers defined here available to all views.  
    def strip_file_extension(filename)
      filename.gsub(/\..{3,4}$/,'')
    end 

    def images_per_row
      4
    end

  end
end
