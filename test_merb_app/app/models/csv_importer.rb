class CsvImporter

  attr_accessor :table_class

  require 'fastercsv'
  #require 'csv'

  def initialize(args = {})
    @filename = args.delete(:filename)
    @table_name = args.delete(:table_name)
    @table_columns = ['image_filename']
    auto_import if @filename
    load_table if @table_name
  end

  def self.table_name(filename)
    #filename.match(/(\w\d+\w\d+)/)[1]
    filename.gsub(/\.csv/, '').gsub(/-/, '_')
  end

  def auto_import
    basename = File.basename(@filename).to_s
    @table_name = "csvimport_#{@table_name || CsvImporter.table_name(basename)}"
    @table_name << '_query' if basename.match(/(query)/)
    parse_file(@filename)
  end

  def load_table
    @table_class = Class.new do
      include DataMapper::Resource
    end
    @table_class.storage_names[:default] = @table_name
    puts @table_class.inspect
  end

  def parse_file(filename)
    #@parsed_file = CSV::Reader.parse(File.open(filename, 'rb'))
    @parsed_file = FasterCSV.read(filename)
    analyze_header(@parsed_file.shift)
    create_table(@table_name, @table_columns)
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

  def row2hash(row)
    hash = {}
    row.size.times do |i|
      unless row[i].nil?
        hash[ @table_columns[i].to_sym ] = row[i]
      end
    end
    hash
  end
    
  def analyze_header(header)
    header.each do | column |
      # strips digit prefixes from CSV header and adds the result to 
      # table columns
      if column
        column = "token_#{column.to_s}" unless column.to_s.match(/token_/)
        @table_columns.push column.to_s.gsub(/\d+: /,'')
      end
    end
  end

  # Automagically creates a table class
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

end
