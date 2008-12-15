require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Search, "index action" do
  before(:each) do
    dispatch_to(Search, :index)
  end
end