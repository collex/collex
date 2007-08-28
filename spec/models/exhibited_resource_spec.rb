require File.dirname(__FILE__) + '/../spec_helper'

describe ExhibitedResource do
  before(:each) do
    @er = mock_model(ExhibitedResource)
  end

  it "'date_label_or_date' should return date_label if present, date otherwise" do
    @er = ExhibitedResource.new
    @er.properties << ExhibitedProperty.new(:name => "date", :value => "2007-01-01")
    @er.date_label_or_date.should == "2007-01-01"
    @er.properties << ExhibitedProperty.new(:name => "date_label", :value => "January 1, 2007")
    @er.date_label_or_date.should == "January 1, 2007"    
  end
  
  it "'resource' should return empty SolrResource if Solr returns null for the id" do
    er = ExhibitedResource.new
    er.resource.class.should eql SolrResource
  end
  
  it "'after_create' should copy the SolrResource properties into ExhibitedProperties" do
    @sr = SolrResource.new
    @sr.properties << SolrProperty.new(:name => "the name 1", :value => "the value 1")
    @sr.properties << SolrProperty.new(:name => "the name 2", :value => "the value 2")
    SolrResource.stub!(:find_by_uri).and_return(@sr)
    er = ExhibitedResource.create(:url => "http://fake.url.com", :exhibited_section_id => 1)
    er.resource.should == @sr
    
    er.properties.size.should == 2
    er.properties.size.should == @sr.properties.size
    er.properties.each { |prop| @sr.properties.include?(prop) }
  end
end
