module ExhibitedPagesHelper
  def exhibited_pages_links(exhibited_page, edit = false)
    exhibit = exhibited_page.exhibit
    position = exhibited_page.position
    index = position - 1
    max_index = exhibit.pages.size - 1
    
    route_method = edit ? :edit_page_path : :page_path
    puts "route_method: #{route_method}"
    links = ""
    links << link_to(h("<"), __send__(route_method, :id => exhibit.pages[index - 1].id, :exhibit_id => exhibit.id)) + "&nbsp;" unless index < 1
    links << "#{position}"
    links << "&nbsp;" + link_to(h(">"), __send__(route_method, :id => exhibit.pages[index + 1].id, :exhibit_id => exhibit.id)) unless index >= max_index
    links
  end
end
