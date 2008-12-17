# Finds our images from partial filenames
require 'find'

# Number of potential hits returned in the list of matches
NUM_MATCHES = 8

# Holds logic to process pass an uploaded CSV file to the CSV Importer.
# Holds a reference to a virtual ORM model that can be used to manipulate the imported data.
# This enables the use of Job as a database-backed model (see http://www.datamapper.org/)
class Job 
  include DataMapper::Resource
  # Properties set here are accesable instance variables that can be saved to the database
  property :id, Serial
  property :created_at, DateTime
  property :filename, String
  property :images, Object
  property :matches, Object
  property :missing_images, Object
  property :missing_reference_images, Object

  # Constructs a database-backed Job object
  def initialize(args = {:filename => nil, :tempfile => nil})
    @filename = args[:filename]
    @images = []
    @missing_images = []
    @reference_images = []
    @missing_reference_images = []
    @matches = {}
    if(@filename)
      import_file = File.join(absolute_import_dir, @filename)
      if File.exists?(import_file)
        @table_class = InverseCsvImporter.load_class(InverseCsvImporter.table_name(@filename))
      else
        FileUtils.mkdir absolute_import_dir unless File.directory?(absolute_import_dir)
        FileUtils.mv args[:tempfile].path, import_file
        @table_class = InverseCsvImporter.new(import_file).table_class
      end
      find_images
    else
      @filename = ""
    end
  end

  # Returns absolute path to directory where data files will be imported to
  def absolute_import_dir
    File.join(Merb.root, File.join("public", relative_import_dir))
  end

  # Returns relative path to directory where data files will be imported to
  def relative_import_dir
    "/uploads/#{InverseCsvImporter.table_name(@filename)}"
  end

  # Collects:
  # * compared images on the filesystem into @images
  # * compared images not found on the filesystem into @missing_images
  # * reference images on the filesystem into @reference_images
  # * reference images not found on the filesystem into @missing_reference_images
  def find_images
    rows = @table_class.all
    rows.each do |row|
      filename = locate_image(row.image_filename)
      if image_exists?(filename)
        @reference_images << filename
      else
        @missing_reference_images << filename
      end
      # Collects each column name (image to compare to)
      if(row == rows.last)
        row.instance_variables.each do | column |
          # Filter out the intance variables we set up ourselves
          unless ['@id', '@repository','@image_filename','@original_values', '@new_record','@collection', '@updated_at'].include? column
            filename = locate_image(column.gsub(/@/,''))
            if image_exists?(filename)
              @images << filename
            else
              @missing_images << filename
            end
          end
        end
      end
    end
    @images.sort!
  end

  def locate_image(partial_filename)
    partial_filename = partial_filename.gsub(/integerprefix_/,'').gsub(/\//,'')
    return partial_filename if File.exists?(File.join(absolute_images_path, partial_filename))
    Find.find(absolute_images_path) do |f|
      filename = f.gsub(absolute_images_path, '')
      unless filename.nil? || filename.match(/^\..*$/)
        if filename.match(/\.(jpg|jpeg|png|JPG|JPEG|PNG)$/)
          if filename.match(partial_filename)
            return filename.gsub(/\//,'')
          end
        end
      end
    end
    return partial_filename
  end

  def calculate_matches_for(selected_image)
    img_sym = selected_image.to_sym
    @matches[img_sym] = @table_class.all(:order => [InverseCsvImporter.cleanup_filename(selected_image).to_sym.desc])
    @matches[img_sym] = @matches[img_sym][0..NUM_MATCHES-1]
    @matches
  end

  # Returns absolute path for uploaded images, derived from @filename
  def absolute_images_path
    File.join(absolute_import_dir, "images")
  end

  # Returns relative path for uploaded images, derived from @filename
  def relative_images_path
    File.join(relative_import_dir, "images")
  end

  # Returns true if filename exists in folder pointed to by images_path
  def image_exists?(filename)
    File.exists?(File.join(absolute_images_path, filename))
  end

  # Returns true if all images are present at the correct location. Otherwise, returns false.
  def all_images_exist?
    return false if @missing_images.size > 0
    return false if @missing_reference_images.size > 0
    return true
  end

  def friendly_name(filename)
    filename.gsub(/integerprefix_/,'').gsub(/\//,'')
    unless filename.match(/\..{3,4}$/)
      filename = locate_image(filename)
    end
    filename
  end

end
