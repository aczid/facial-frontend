class Images < Application
  # provides :xml, :yaml, :js
  before :find_job

  def index
    @images = @job.images
    #render_text "woot"
    display @images
  end

  def show(id)
    @image = Image.get(id)
    raise NotFound unless @image
    display @image
  end

  def new
    only_provides :html
    @image = Image.new
    display @image
  end

  def edit(id)
    only_provides :html
    @image = Image.get(id)
    raise NotFound unless @image
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

  def update(id, image)
    @image = Image.get(id)
    raise NotFound unless @image
    if @image.update_attributes(image)
       redirect resource(@image)
    else
      display @image, :edit
    end
  end

  def destroy(id)
    @image = Image.get(id)
    raise NotFound unless @image
    if @image.destroy
      redirect resource(:images)
    else
      raise InternalServerError
    end
  end
 
  private

    def find_job
      @job = session.user.jobs.get(params[:job_id])
      raise NotFound unless @job
      @job.prepare
    end

end # Images
