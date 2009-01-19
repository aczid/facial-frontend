require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a job exists" do
  Job.all.destroy!
  request(resource(:jobs), :method => "POST", 
    :params => { :job => { :id => nil }})
end

describe "resource(:jobs)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:jobs))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of jobs" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a job exists" do
    before(:each) do
      @response = request(resource(:jobs))
    end
    
    it "has a list of jobs" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Job.all.destroy!
      @response = request(resource(:jobs), :method => "POST", 
        :params => { :job => { :id => nil }})
    end
    
    it "redirects to resource(:jobs)" do
      @response.should redirect_to(resource(Job.first), :message => {:notice => "job was successfully created"})
    end
    
  end
end

describe "resource(@job)" do 
  describe "a successful DELETE", :given => "a job exists" do
     before(:each) do
       @response = request(resource(Job.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:jobs))
     end

   end
end

describe "resource(:jobs, :new)" do
  before(:each) do
    @response = request(resource(:jobs, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@job, :edit)", :given => "a job exists" do
  before(:each) do
    @response = request(resource(Job.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@job)", :given => "a job exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Job.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @job = Job.first
      @response = request(resource(@job), :method => "PUT", 
        :params => { :job => {:id => @job.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@job))
    end
  end
  
end

