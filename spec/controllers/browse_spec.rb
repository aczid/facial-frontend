require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Browse, "index action" do
  before(:each) do
    dispatch_to(Browse, :index)
  end
end
