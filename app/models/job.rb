# Finds our images from partial filenames
require 'find'

# Number of potential hits returned in the list of matches
NUM_MATCHES = 8

# Holds logic to process pass an uploaded CSV file to the CSV Importer.
# Loads a reference to a virtual ORM model that can be used to manipulate the imported data.
class Job 
  # This enables the use of Job as a database-backed model (see http://www.datamapper.org/)
  include DataMapper::Resource
  include DataMapper::Validate
  include Paperclip::Resource 
  include Paperclip::Validate

  # Properties set here are accesable instance variables that can be saved to the database
  # You should access them via 'self.' rather than '@' to make sure they will be marked as 'tainted' and will be saved to the database
  property :id, Serial
  property :created_at, DateTime
  has_attached_file :csv, :nullable => false
  validates_present :csv
  # unfortunately this field is not sane coming from windows
  #validates_attachment_content_type :csv, :content_type => "text/csv"

  # Several arrays to save associated images
  property :images, Object
  property :reference_images, Object
  property :missing_images, Object
  property :missing_reference_images, Object

  # Jobs belong to users
  belongs_to :user
  validates_present :user

  # Provides getters/setters for instance variables (makes them public)
  attr_accessor :matches
  attr_accessor :num_matches
  attr_accessor :selected_image

  # This method is private, so we can't add a hook :(
  # Workaround is to call prepare on found Job objects
  #after :load, :prepare
  # Normally we would call before :destroy here, but dm-paperclip uses that hook to delete its files (and associated instance methods, which we rely on in the drop_table method.
  before :destroy_attached_files, :drop_table

  # Constructs a new database-backed Job object
  def initialize(args = {})
    self.csv = args[:csv]
    self.images = []
    self.missing_images = []
    self.reference_images = []
    self.missing_reference_images = []
    @matches = Hash.new
    if self.valid?
      import_csv_and_find_images
    end
  end

  def prepare
    load_table_class if @table_class.nil?
  end

  def import_csv_and_find_images
    import_file
    find_images
  end

  # Imports attached CSV using InverseCsvImporter
  def import_file
    @table_class = InverseCsvImporter.new(self.csv.path, self.user.login).table_class
  end

  # Loads table class from existing table
  def load_table_class
    @table_class = InverseCsvImporter.load_class(self.table_name)
  end

  # Name of associated table
  def table_name
    InverseCsvImporter.table_name(self.csv_file_name, self.user.login)
  end

  # Drops associated table
  def drop_table
    InverseCsvImporter.drop_table(self.table_name)
  end

  # Returns absolute path to directory where data files will be imported to
  def absolute_import_dir
    File.join(Merb.root, "public#{relative_import_dir}")
  end

  # Returns relative path to directory where data files will be imported to
  def relative_import_dir
    "/uploads/#{InverseCsvImporter.table_name(self.csv_file_name, self.user.login)}"
  end

  # Collects:
  # * compared images on the filesystem into self.images
  # * compared images not found on the filesystem into self.missing_images
  # * reference images on the filesystem into self.reference_images
  # * reference images not found on the filesystem into self.missing_reference_images
  def find_images
    self.images = []
    self.missing_images = []
    self.reference_images = []
    self.missing_reference_images = []
    rows = @table_class.all
    rows.each do |row|
      filename = locate_image(row.image_filename)
      if image_exists?(filename)
        self.reference_images << filename
      else
        self.missing_reference_images << filename
      end
      # Collects each column name
      if(row == rows.last)
        row.instance_variables.each do | column |
          # Filter out the intance variables we set up ourselves
          unless ['@id', '@repository','@image_filename','@original_values', '@new_record','@collection', '@updated_at', '@child_associations', '@parent_associations', '@errors'].include? column
            filename = locate_image(column.gsub(/@/,''))
            if image_exists?(filename)
              self.images << filename
            else
              self.missing_images << filename
            end
          end
        end
      end
    end
    self.images.sort!
  end

  def strip_prefix_and_slashes(string)
    strip_prefix(strip_slashes(string))
  end

  def strip_slashes(string)
    string.gsub(/\//,'')
  end

  def strip_prefix(string)
    string.gsub(/integerprefix_/,'')
  end

  # Locates an image on the disk from a partial filename.
  def locate_image(partial_filename, path = absolute_images_path)
    # Strips integerprefix_es and slashes
    partial_filename = strip_prefix_and_slashes(partial_filename)
    return partial_filename if File.exists?(File.join(path, partial_filename))
    Find.find(path) do |f|
      # Strip search path from file path to get file
      filename = f.gsub(path, '')
      unless filename.nil? || filename.match(/^\..*$/)
        if filename.match(/\.(jpg|jpeg|png|gif|JPG|JPEG|PNG|GIF)$/)
          if filename.match(partial_filename)
            # Strip slashes
            return filename.gsub(/\//,'')
          end
        end
      end
    end
    return partial_filename
  end

  def calculate_matches_for(selected_image)
    self.matches = Hash.new unless self.matches.is_a? Hash
    @num_matches = NUM_MATCHES unless @num_matches
    self.matches[sane_name(selected_image).to_sym] = @table_class.all(:order => [InverseCsvImporter.cleanup_filename(selected_image).to_sym.desc])[0..@num_matches.to_i-1]
  end

  # Returns absolute path for uploaded images, derived from self.file
  def absolute_images_path
    File.join(absolute_import_dir, "images")
  end

  # Returns relative path for uploaded images, derived from self.file
  def relative_images_path
    File.join(relative_import_dir, "images")
  end

  # Returns true if filename exists in folder pointed to by images_path
  def image_exists?(filename)
    File.exists?(File.join(absolute_images_path, filename))
  end

  # Returns currently selected image, or first
  def selected_image
    @selected_image || self.images[0]
  end

  def selected_image=(image)
    @selected_image=image
  end

  # Returns true if all images are present at the correct location. Otherwise, returns false.
  def all_images_exist?
    return false if self.missing_images.size > 0
    return false if self.missing_reference_images.size > 0
    return true
  end

  def sane_name(filename)
    filename = File.basename(filename)
    unless filename.match(/\..{3,4}$/)
      filename = locate_image(filename)
    end
    filename
  end

  def relative_path_to(file)
    File.join(relative_images_path, strip_prefix_and_slashes(file))
  end

  # Relative path to selected image
  def relative_path_to_selected_image
    relative_path_to(self.selected_image)
  end

  # Relative path to match
  def relative_path_to_image_for_match(match)
    relative_path_to(image_filename_for_match(match))
  end

  # Image filename for match
  def image_filename_for_match(match)
    sane_name(match.image_filename)
  end

  # Returns match value for selected image from match
  def match_accuracy(match)
    match.instance_variable_get("@#{InverseCsvImporter.cleanup_filename(self.selected_image)}")
  end

end
