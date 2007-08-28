require File.dirname(__FILE__) + '/../spec_helper'

describe ExhibitedProperty do
  before(:each) do
    @exhibited_property = ExhibitedProperty.new
  end

  it "== should evaluate equality of name and value" do
    ep1 = ExhibitedProperty.new(:name => "name 1", :value => "value 1")
    ep2 = ExhibitedProperty.new(:name => "name 1", :value => "value 1")
    ep3 = ExhibitedProperty.new(:name => "name 1", :value => "value 3")
    ep4 = ExhibitedProperty.new(:name => "name 4", :value => "value 4")
    ep1.should == ep2
    ep1.should_not == ep3
    ep1.should_not == ep4
  end
  
  it "== should be false if other is nil" do
    ep1 = ExhibitedProperty.new(:name => "name 1", :value => "value 1")
    ep1.should_not == nil
  end
  
  it "== should evaluate equality of name and value with SolrProperty" do
    ep1 = ExhibitedProperty.new(:name => "name 1", :value => "value 1")
    ep2 = SolrProperty.new(:name => "name 1", :value => "value 1")
    ep1.should == ep2
  end
end
