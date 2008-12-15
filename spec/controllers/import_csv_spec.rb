require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe ImportCsv, "index action" do
  before(:each) do
    dispatch_to(ImportCsv, :index)
  end

  it "should display an upload form" do
    
  end
end

describe ImportCsv, "new action" do
  before(:each) do
    dispatch_to(ImportCsv, :new)
  end
  it "should import CSV files into the database" do
    
  end

  it "should create appropriate table columns for the CSV header" do
    
  end
end
