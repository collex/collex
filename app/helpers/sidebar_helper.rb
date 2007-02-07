module SidebarHelper
  def search_form
    xm = Builder::XmlMarkup.new
    xm.div(:class => "search") do
      xm.form(:method => "post", :action => url_for(:controller => "search", :action => "new_expression")) do
        xm << text_field_tag("field[content]", "new search", :onFocus => "this.value=''")
        xm << "&nbsp;"
      end
    end
  end
  
  def title_for(object)
    object['title'].blank? ? "<untitled>" : object['title']
  end
  
  def sb_link_to_remote(type, value, label=nil)
    label ||= value
    link_to_remote label, :update=>"sidebar", :url => {:controller=>"sidebar", :action => 'list', :type => type, :value => value}
  end
  
  def cloud_header_footer(count, value, css_class="cloudheader")
    xm = Builder::XmlMarkup.new
    xm.div(:class => css_class) do
      xm.span(:class => "emph2") do 
        xm << pluralize(count, "#{value} object", "#{value} objects") 
      end
    end
  end

end
