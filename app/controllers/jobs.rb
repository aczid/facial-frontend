class Jobs < Application
  before :ensure_authenticated
  provides :xml, :html #, :yaml, :js

  def index
    @jobs = session.user.jobs
    @job = Job.new # empty job to build form on
    display @jobs
  end

  def show(id)
    @job = session.user.jobs.get(id)
    raise NotFound unless @job
    if @job.all_images_exist?
      #@job.selected_image = @job.sane_name(job[:selected_image])
      @job.prepare
      @job.calculate_matches_for(@job.selected_image)
      display @job
    else
      redirect url(:job_images, @job)
    end
  end

  def new
    only_provides :html
    @job = Job.new
    display @job
  end

  def delete(id)
    @job = session.user.jobs.get(id)
    render
  end

  def create(job)
    @job = session.user.jobs.first(:csv_file_name => job[:csv][:filename])
    # new import
    if @job.nil?
      # creates new job and imports table
      @job = Job.new(job)
      @job.user = session.user
      # need to save here to write CSV file to disk
      if @job.save
        @job.import_csv_and_find_images
      end
    # existing import
    else
      # loads table
      @job.prepare
    end
    # Saving again to cache images arrays
    if @job.save && @job.all_images_exist?
      @job.calculate_matches_for(@job.selected_image)
      redirect resource(@job)
    else
      message[:error] = "Job failed to be created"
      redirect url(:action => :index)
    end
  end

  def destroy(id)
    @job = session.user.jobs.get(id)
    raise NotFound unless @job
    if @job.destroy
      redirect resource(:jobs)
    else
      raise InternalServerError
    end
  end

end # Jobs
