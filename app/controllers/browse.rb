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
    @job = Job.first({:file => "c3a16-on-ref-f-300x400.csv"})
    @job.prepare
    render(:main)
  end

  def upload_csv(job)
    if job[:file][:filename].match(/\.csv$/)
      @job = Job.first(:file => job[:file][:filename])
      if @job.nil?
        @job = Job.new(job[:file])
        @job.save
      else
        @job.prepare
      end
      session[:csv_file] = job[:file][:filename]
    end
    render(:main)
  end

  def compare_image(job)
    @job = Job.first({:file => session[:csv_file]})
    @job.selected_image = @job.sane_name(job[:selected_image])
    @job.prepare
    render(:main)
  end

end
