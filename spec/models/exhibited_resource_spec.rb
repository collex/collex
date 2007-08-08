require File.dirname(__FILE__) + '/../spec_helper'

describe ExhibitedResource do
  before(:each) do
    @er = mock_model(ExhibitedResource)
  end

  it "'date_label_or_date' should return date_label if present, date otherwise" do
    
  end
  
  it "'resource' should return empty SolrResource if Solr returns null for the id" do
    er = ExhibitedResource.new
    er.resource.class.should equal(SolrResource)
  end
end
