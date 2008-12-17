class Browse < Application
  provides :html

  # ...and remember, everything returned from an action
  # goes to the client...
  def index
    # empty job to base form on
    @job = Job.new
    render
  end

  def benchmark
    @job = Job.new({:filename => "c3a16-on-ref-f-300x400.csv", :tmp_file => "/home/aczid/workspace/nfi_data/c3a16-on-ref-f-300x400.csv"})
    @selected_image = @job.images[0]
    @job.calculate_matches_for(@selected_image)
    render(:upload_file)
  end

  def upload_file(job)
    if job[:filename][:filename].match(/\.csv$/)
      @job = Job.new(job[:filename])
      if @job.all_images_exist?
        @selected_image = @job.images[0]
        @job.calculate_matches_for(@selected_image)
      end
      @job.save
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
