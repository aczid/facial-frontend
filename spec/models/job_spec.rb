require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Job do

  it "should save itself to the database correctly"
    @job = Job.new({:filename => "c3a16-on-ref-f-300x400.csv", :tmp_file => "/home/aczid/workspace/nfi_data/c3a16-on-ref-f-300x400.csv"})
    @job.save
  end

end
