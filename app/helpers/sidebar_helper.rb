module SidebarHelper
  def search_form
    xm = Builder::XmlMarkup.new
    xm.div(:class => "search") do
      xm.form(:method => "post", :action => url_for(:controller => "search", :action => "new_expression")) do
        xm << "&nbsp;"
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
  
  def cloud_object(count, value, css_class="cloud_object")
    xm = Builder::XmlMarkup.new
    xm.div(:class => css_class) do
      xm.span(pluralize(count, "#{value} object", "#{value} objects"), :class => "emph2")
    end
  end
  
  def tag_cloud(list, type, bucket_size)
    xm = Builder::XmlMarkup.new
    list.each do |item|
      xm.span :class => "cloud#{item.last.quo(bucket_size).ceil}" do
         if type == "username"
           xm << link_to_peer(item.first, item.last)
         else
           xm << link_to_list(type, item.first, item.last)
         end
      end
    end
    xm
  end
  
  def tags_list_link_to(tag_type, tag_value, user)
    view_all_users_tags_label = "view all users' #{tag_value} objects"
    view_all_users_tags_link = link_to_remote_for_list_tags(view_all_users_tags_label, tag_type, tag_value, nil)
    
    view_my_tags_label = "view only my #{tag_value} objects"
    view_my_tags_link = link_to_remote_for_list_tags(view_my_tags_label, tag_type, tag_value, username || "<mine>")

    result = case 
      when me?
        view_all_users_tags_link
      when user.blank?
        view_my_tags_link
      when !user.blank? && !me?
        view_my_tags_link + "<br/>" + view_all_users_tags_link
      end
      result
  end
  
  private
    def link_to_remote_for_list_tags(label, tag_type, tag_value, user)
      link_to_remote(label, {:update => "sidebar", :url => {:controller=>"sidebar", :action=>"list", :user => user, :type => tag_type, :value => tag_value}}, {:class => 'tags_list_link_to'})
    end
  

end
