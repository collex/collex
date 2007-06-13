require File.dirname(__FILE__) + '/../../spec_helper'

describe "/exhibited_pages/new" do
  before do
    render 'exhibited_pages/new'
  end
  
  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', 'Find me in app/views/exhibited_pages/new.rhtml')
  end
end
