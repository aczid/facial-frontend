class Images < Application
  # provides :xml, :yaml, :js
  before :find_job

  def index
    @job.selected_image = @job.sane_name(@job.images[0])
    @job.prepare
    @job.calculate_matches_for(@job.selected_image)
    display @images
  end

  def show(selected_image)
    @job.selected_image = @job.sane_name(selected_image)
    @job.prepare
    @job.calculate_matches_for(@job.selected_image)
    display @image
  end

  def create(image_or_archive)
    @image = Image.new(image_or_archive)
    @image.job=@job
    @image.process
    @job.find_images
    @job.save
    redirect resource(@job)
  end

  private

    def find_job
      @job = session.user.jobs.get(params[:job_id])
      raise NotFound unless @job
      @job.prepare
      params[:selected_image] = params[:id] if !params[:selected_image]
    end

end # Images
