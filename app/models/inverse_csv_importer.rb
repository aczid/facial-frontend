class InverseCsvImporter

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
    find_first_columns(@parsed_file)
    create_table(InverseCsvImporter.table_name(filename), @table_columns)
    values = {}
    @parsed_file[0].enum_with_index.map do |filename, idx|
      if filename
        @parsed_file.collect do |row|
          if row[0]
            values[InverseCsvImporter.cleanup_filename(filename).to_sym] = {} unless values[InverseCsvImporter.cleanup_filename(filename).to_sym].is_a?(Hash)
            values[InverseCsvImporter.cleanup_filename(filename).to_sym][InverseCsvImporter.cleanup_filename(row[0]).to_sym] = row[idx] if filename
          end
        end
      end 
    end
    n = 0
    values.keys.each do |image|
      if values[image.to_sym]
        unless @table_class.first(:image_filename => image.to_s)
          instance = @table_class.new(values[image])
          instance.image_filename = image
          if instance.save
            n+=1
            GC.start if n%50 == 0
          end
        end
      end
    end
  end

  def find_first_columns(rows)
    rows.each do | row |
      if row[0]
        @table_columns.push InverseCsvImporter.cleanup_filename(row[0])
      end
    end
  end

  def self.cleanup_filename(name)
    name = name.to_s.gsub(/^\d+: /,'').gsub(/\..{3,4}$/, '').gsub(/\//,'')
    name = "integerprefix_#{name}" if name[0].to_s.to_i == name[0]
    name
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
    #if @table_class.storage_exists?
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
    #end
    @table_class
  end

end
