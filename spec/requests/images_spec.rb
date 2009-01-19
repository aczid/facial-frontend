require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a image exists" do
  Image.all.destroy!
  request(resource(:images), :method => "POST", 
    :params => { :image => { :id => nil }})
end

describe "resource(:images)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:images))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of images" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a image exists" do
    before(:each) do
      @response = request(resource(:images))
    end
    
    it "has a list of images" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Image.all.destroy!
      @response = request(resource(:images), :method => "POST", 
        :params => { :image => { :id => nil }})
    end
    
    it "redirects to resource(:images)" do
      @response.should redirect_to(resource(Image.first), :message => {:notice => "image was successfully created"})
    end
    
  end
end

describe "resource(@image)" do 
  describe "a successful DELETE", :given => "a image exists" do
     before(:each) do
       @response = request(resource(Image.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:images))
     end

   end
end

describe "resource(:images, :new)" do
  before(:each) do
    @response = request(resource(:images, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@image, :edit)", :given => "a image exists" do
  before(:each) do
    @response = request(resource(Image.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@image)", :given => "a image exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Image.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @image = Image.first
      @response = request(resource(@image), :method => "PUT", 
        :params => { :image => {:id => @image.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@image))
    end
  end
  
end

