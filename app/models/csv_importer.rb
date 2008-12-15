class CsvImporter

  attr_accessor :table_class

  require 'fastercsv'

  def initialize(filename)
    @filename = filename
    @table_columns = ['image_filename']
    puts "Parsing CSV file #{filename}"
    parse_file(@filename)
  end

  # Returns sanitized name from filename.
  # Replaces dashes with underscores, removes slashes, removes .csv extension and prepends 'csvimport_'
  # Appends '_query' if the filename holds the string 'query'
  def self.table_name(filename)
    basename = File.basename(filename.to_s).to_s
    table_name = "csvimport_#{basename.gsub(/\.csv/, '').gsub(/-/, '_').gsub(/\//, '')}"
    table_name << '_query' if basename.match(/(query)/)
    table_name
  end

  # Import CSV data into the database table using the ORM class
  def parse_file(filename)
    @parsed_file = FasterCSV.read(filename)
    analyze_header(@parsed_file.shift)
    create_table(CsvImporter.table_name(filename), @table_columns)
    n = 0
    @parsed_file.each do | row |
      hash = row2hash(row)
      unless @table_class.first(:image_filename => hash[:image_filename])
        instance = @table_class.new(hash)
        if instance.save
          n+=1
          GC.start if n%50 == 0
        end
      end
    end
  end

  # Converts a row of CSV data to a ruby Hash.
  def row2hash(row)
    hash = {}
    row.size.times do |i|
      unless row[i].nil?
        hash[ @table_columns[i].to_sym ] = row[i]
      end
    end
    hash
  end
    
  # Analyzes CSV header and adds fields to @table_columns array
  def analyze_header(header)
    header.each do | column |
      # strips digit prefixes from CSV header and adds the result to 
      # table columns
      if column
        #column = "token_#{column.to_s}" unless column.to_s[0].is_a?(Integer)
        @table_columns.push column.to_s.gsub(/^\d+: /,'')
      end
    end
  end

  # Automagically creates an ORM class for the import using @table_columns array
  def create_table(name, columns)
    # creates a new table class with an image_filename property
    @table_class = Class.new do
      include DataMapper::Resource
      property :id, DataMapper::Types::Serial
      property :updated_at, DateTime
      property :image_filename, String
    end
    # set table name
    @table_class.storage_names[:default] = name
    # shift first element off because it isnt a float
    filename = columns.shift
    columns.each do | column |
      @table_class.property column.to_sym, Float, :precision => 11
    end
    # unshift it back in place
    columns.unshift(filename)
    # dont destroy tables we already have
    unless @table_class.storage_exists?
      @table_class.auto_migrate!
    end
  end

  # Uses mysql DESC hack to reconstruct already imported table
  def self.load_class(name)
    @table_class = Class.new do
      include DataMapper::Resource
      property :id, DataMapper::Types::Serial
      property :updated_at, DateTime
    end
    @table_class.storage_names[:default] = name
    desc = Job.find_by_sql("desc #{name}")
    desc.each do |field|
      case field.created_at
      when /DateTime/i
        klass = DateTime
      when /Float/i
        klass = Float
      else
        klass = String
      end
      klass = DataMapper::Types::Serial if field.id == "id"
      if klass == Float
        @table_class.property field.id.to_sym, klass, :precision => 11
      else
        @table_class.property field.id.to_sym, klass
      end
      #puts "Created field with id #{field.id.to_sym}, class: #{klass}"
    end
    @table_class
  end

end
