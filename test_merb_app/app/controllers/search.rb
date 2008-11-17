class Search < Application

  # ...and remember, everything returned from an action
  # goes to the client...
  def index
    render
  end

  def new(csv_file)
    @query = Query.new(csv_file)
    #@results = @query.table_class.all
    @query.find_images
    @query.save
    debugger
    #@images = @query.images
    display @query
    #render
  end
end
