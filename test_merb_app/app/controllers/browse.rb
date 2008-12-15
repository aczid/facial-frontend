class Browse < Application
  provides :html

  # ...and remember, everything returned from an action
  # goes to the client...
  def index
    # empty job to base form on
    @job = Job.new
    render
  end

  def upload_file(job)
    if job[:filename][:filename].match(/\.csv$/)
      @job = Job.new(job[:filename])
      @job.save
      @selected_image = @job.images[0]
      @job.calculate_matches_for(@selected_image)
      session[:csv_file] = job[:filename][:filename]
    else
      # Unpack and move images into place
    end
    render
  end

  def select_image(selected_image)
    @job = Job.new({:filename => session[:csv_file]})
    @selected_image = selected_image
    @job.calculate_matches_for(@selected_image)
    render(:upload_file)
  end

end
