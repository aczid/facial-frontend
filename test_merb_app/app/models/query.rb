class Query
  include DataMapper::Resource
  storage_names[:default] = 'queries'

  property :id, Serial
  property :created_at, DateTime
  property :filename, String
  property :table_class, Class
  attr_accessor :images

  def initialize(args = {})
    self.filename = args.delete(:filename)
    self.images = {}
    if(self.filename)
      directory = CsvImporter.table_name(@filename)
      import_dir = File.join(Merb.root, "uploads/#{directory}")
      import_file = File.join(import_dir, @filename)
      if q = Query.first(:filename => self.filename)
		self.table_class = q.table_class
      else
        FileUtils.mkdir import_dir unless File.directory?(import_dir)
        FileUtils.mv args[:tempfile].path, import_file
        self.table_class = CsvImporter.new({:filename => import_file}).table_class
      end
    end
  end

  def find_images
    @table_class.all do | row |
      @images << row[:image_filename]
      if(row == @table_class.last)
        row.each do | column |
          if column.match(/token/)
            @images << column
          end
        end
      end
    end
    @images 
  end

end
