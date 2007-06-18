require File.dirname(__FILE__) + '/../spec_helper'

describe ExhibitedPagesHelper do
  
  #Delete this example and add some real ones or delete this file
  it "should include the ExhibitedPagesHelper" do
    included_modules = self.metaclass.send :included_modules
    included_modules.should include(ExhibitedPagesHelper)
  end
  
  it "'exhibited_pages_links' should return show links in non-edit mode and edit links in edit mode" do
    page_1 = mock("page_1", :null_object => true)
    page_2 = mock("page_2", :null_object => true)
    page_3 = mock("page_3", :null_object => true)
    pages = [page_1, page_2, page_3]
    
    exhibit = mock("exhibit")
    exhibit.stub!(:id).and_return(1)
    exhibit.stub!(:pages).and_return(pages)
    pages.each_with_index do |page, index|
      page.stub!(:id).and_return(index + 1)
      page.stub!(:position).and_return(index + 1)
      page.stub!(:exhibit).and_return(exhibit)
    end
#     puts h exhibited_pages_links(page_3)
#     puts exhibited_pages_links(page_2)
    # non-edit mode
    exhibited_pages_links(page_1).should == %q{1&nbsp;<a href="/exhibits/1/pages/2">&gt;</a>}
    exhibited_pages_links(page_2).should == %q{<a href="/exhibits/1/pages/1">&lt;</a>&nbsp;2&nbsp;<a href="/exhibits/1/pages/3">&gt;</a>}
    exhibited_pages_links(page_3).should == %q{<a href="/exhibits/1/pages/2">&lt;</a>&nbsp;3}
    
    # edit mode
    exhibited_pages_links(page_1, true).should == %q{1&nbsp;<a href="/exhibits/1/pages/2;edit">&gt;</a>}
    exhibited_pages_links(page_2, true).should == %q{<a href="/exhibits/1/pages/1;edit">&lt;</a>&nbsp;2&nbsp;<a href="/exhibits/1/pages/3;edit">&gt;</a>}
    exhibited_pages_links(page_3, true).should == %q{<a href="/exhibits/1/pages/2;edit">&lt;</a>&nbsp;3}
    
  end
end
