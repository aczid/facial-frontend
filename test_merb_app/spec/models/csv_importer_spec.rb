require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe CsvImporter do
  before(:each) do
    filename = "#{File.join(Merb.root, '../data_samples/c3a16-on-ref-f-300x400.csv')}"
    @m = CsvImporter.new({:filename => filename })
  end

  it "should create a new instance of a CvsImporter" do
    @m.should be_kind_of(CsvImporter)
  end

  it "should determine the table name based on the supplied filename" do
    CsvImporter.table_name('abcd123.csv').should == 'abcd123'
  end

  describe "supplied with a reference file" do
    it "should parse the file" do
      #parsed_file = @m.instance_variable_get(:@parsed_file)
    end

    it "should create a table named like the supplied file with a prefix" do
      @m.table_class.storage_names[:default].should == 'csvimport_c3a16-on-ref-f-300x400'
      @m.table_class.storage_exists?.should == true
    end
  end

  describe "supplied with a query" do
    before(:each) do
      filename = "#{File.join(Merb.root, '../data_samples/query-on-c4a16.csv')}"
      @m = CsvImporter.new({:filename => filename })
    end
    
    it "should parse the file" do
      #parsed_file = @m.instance_variable_get(:@parsed_file)
    end
    
  end
end
