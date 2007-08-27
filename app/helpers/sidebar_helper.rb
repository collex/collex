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
    if(object.kind_of?(SolrResource))
      object.title.blank? ? "<untitled>" : object.title
    else
      object['title'].blank? ? "<untitled>" : object['title']
    end
  end
  
  def sb_link_to_remote(type, value, label=nil)
    label ||= value
    link_to_remote label, :update=>"sidebar", :url => {:controller=>"sidebar", :action => 'list', :type => type, :value => value}
  end
  
  def cloud_object(count, value, username=nil, css_class="cloud_object")
    xm = Builder::XmlMarkup.new
    xm.div(:class => css_class) do
      xm.text! "#{username}'s " if username
      xm.text! "#{count.to_i} "
      xm.span(value, :class => "emph2")
      xm.text! count.to_i != 1 ? " objects" : " object"
    end
  end
  
  def tag_cloud(list, type, bucket_size)
    xm = Builder::XmlMarkup.new(:indent => 2)
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
  
  # build a table of items for the sidebar list of items
  def items_list(list)
    xm = Builder::XmlMarkup.new(:indent => 2)
    xm.table :cellspacing => "0" do
      list.each do |item|
        xm.tr do
          xm.td :align => "center" do
            xm << thumbnail_image_tag(item, :class => 'image')
            xm << draggable_element("thumbnail_#{item['uri']}", :revert => true)
          end
          xm.td do
            xm.span do 
              xm << link_to_remote( h(item['title'] ? item['title'] : "<untitled>"), :update => "sidebar", :url => {:controller=>"sidebar", :action => 'detail', :objid => item['uri']}, :complete => "window.scrollTo(0,0);", :class => "title")
            end
            xm.br
            xm.text(comma_separate(item['date_label']))
            xm.br
            xm.text(comma_separate(item['agent_facet']))
            xm.br
            xm.text(comma_separate(item['genre']))
            xm.br
            if site(item[:archive])
              xm.a(site(item['archive'])['description'], :href => site(item['archive'])['url'])
            else
              xm.text(item[:archive])
            end
          end
        end
      end
    end
    xm
  end
  
  def tags_list_link_to(tag_type, tag_value, user)
    view_all_users_tags_link = "view #{link_to_remote_for_list_tags('all users\'', tag_type, tag_value, nil)} #{tag_value} objects"
    
    view_my_tags_link = "view #{link_to_remote_for_list_tags('only my', tag_type, tag_value, username || '<mine>')} #{tag_value} objects"

    result = case 
      when me?
        view_all_users_tags_link
      when user.blank?
        view_my_tags_link
      when !user.blank? && !me?
        view_my_tags_link + "<br/>" + view_all_users_tags_link
      end
      span result, :class => 'tags_list_link_to'
  end
  
  private
    def link_to_remote_for_list_tags(label, tag_type, tag_value, user)
      link_to_remote(label, {:update => "sidebar", :url => {:controller=>"sidebar", :action=>"list", :user => user, :type => tag_type, :value => tag_value}})
    end
  

end
