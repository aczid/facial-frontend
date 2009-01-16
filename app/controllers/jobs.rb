class Jobs < Application
  before :ensure_authenticated
  # provides :xml, :yaml, :js

  def index
    @jobs = session.user.jobs
    @job = Job.new
    display @jobs
  end

  def show(id)
    @job = session.user.jobs.get(id)
    raise NotFound unless @job
    display @job
  end

  def new
    only_provides :html
    @job = Job.new
    display @job
  end

  # dont need to edit jobs
=begin
  def edit(id)
    only_provides :html
    @job = Job.get(id)
    raise NotFound unless @job
    display @job
  end
=end

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
    if @job.save
      if @job.all_images_exist?
        @job.calculate_matches_for(@job.selected_image)
        redirect resource(@job), :message => {:notice => "Some images are missing!"}
      else
        redirect resource(@job), :message => {:notice => "All images found. Ready to compare."}
      end
    else
      message[:error] = "Job failed to be created"
      render :new
    end
  end

  # dont need to update jobs
=begin
  def update(id, job)
    @job = Job.get(id)
    raise NotFound unless @job
    if @job.update_attributes(job)
       redirect resource(@job)
    else
      display @job, :edit
    end
  end
=end

  def destroy(id)
    @job = Job.get(id)
    raise NotFound unless @job
    if @job.destroy
      redirect resource(:jobs)
    else
      raise InternalServerError
    end
  end

end # Jobs
