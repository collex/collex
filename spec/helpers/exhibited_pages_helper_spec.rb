require File.dirname(__FILE__) + '/../spec_helper'

describe ExhibitedPagesHelper do
  
  #Delete this example and add some real ones or delete this file
  it "should include the ExhibitedPagesHelper" do
    included_modules = self.metaclass.send :included_modules
    included_modules.should include(ExhibitedPagesHelper)
  end
  
  it "'exhibited_pages_links' should return show links in non-edit mode and edit links in edit mode" do
    page_1 = mock_model(ExhibitedPage, :null_object => true)
    page_2 = mock_model(ExhibitedPage, :null_object => true)
    page_3 = mock_model(ExhibitedPage, :null_object => true)
    pages = [page_1, page_2, page_3]
    
    exhibit = mock_model(Exhibit)
    exhibit.stub!(:pages).and_return(pages)
    pages.each_with_index do |page, index|
      page.stub!(:position).and_return(index + 1)
      page.stub!(:exhibit).and_return(exhibit)
    end
#     puts h exhibited_pages_links(page_3)
#     puts exhibited_pages_links(page_2)
    # non-edit mode
    exhibited_pages_links(page_1).should == "1&nbsp;" + link_to("&gt;", page_path(exhibit, page_2)) + "&nbsp;" + link_to("3", page_path(exhibit, page_3))
    exhibited_pages_links(page_2).should == link_to("1&nbsp;", page_path(exhibit, page_1)) + link_to("&lt;", page_path(exhibit, page_1)) + "&nbsp;2&nbsp;" + link_to("&gt;", page_path(exhibit, page_3)) + "&nbsp;" + link_to("3", page_path(exhibit, page_3))
    exhibited_pages_links(page_3).should == link_to("1&nbsp;", page_path(exhibit, page_1)) + link_to("&lt;", page_path(exhibit, page_2)) + "&nbsp;3"
    
    # edit mode
    exhibited_pages_links(page_1, true).should == "1&nbsp;" + link_to("&gt;", edit_page_path(exhibit, page_2)) + "&nbsp;" + link_to("3", edit_page_path(exhibit, page_3))
    exhibited_pages_links(page_2, true).should == link_to("1&nbsp;", edit_page_path(exhibit, page_1)) + link_to("&lt;", edit_page_path(exhibit, page_1)) + "&nbsp;2&nbsp;" + link_to("&gt;", edit_page_path(exhibit, page_3)) + "&nbsp;" + link_to("3", edit_page_path(exhibit, page_3))
    exhibited_pages_links(page_3, true).should == link_to("1&nbsp;", edit_page_path(exhibit, page_1)) + link_to("&lt;", edit_page_path(exhibit, page_2)) + "&nbsp;3"
    
  end
end
