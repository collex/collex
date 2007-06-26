ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
#  map.connect ':controller/service.wsdl', :action => 'wsdl'

  map.atom_feed 'atom/:type/:value/:user', 
                    :controller => 'sidebar',
                    :action => 'atom',
                    :value => /[^\/]+/,
                    :user => nil

  map.resources :exhibits, 
                :member => { :add_resource      => :post, 
                             :update_title      => :post, 
                             :share             => :post, 
                             :unshare           => :post, 
                             :publish           => :post, 
                             :update_annotation => :post } do |exhibit|
    exhibit.resources :pages, 
                      :controller => :exhibited_pages,
                      :member => { :update_title      => :post, 
                                   :update_annotation => :post,
                                   :move_higher       => :post, 
                                   :move_lower        => :post, 
                                   :move_to_top       => :post, 
                                   :move_to_bottom    => :post } do |page|
      page.resources :exhibited_sections, 
                        :member => { :update_title      => :post, 
                                     :update_annotation => :post,
                                     :move_higher       => :post, 
                                     :move_lower        => :post, 
                                     :move_to_top       => :post, 
                                     :move_to_bottom    => :post } do |section|
        section.resources :exhibited_texts, 
                          :member => { :update_annotation => :post}
        section.resources :exhibited_resources, 
                          :member => { :update_annotation => :post}
        section.resources :exhibited_items, 
                          :member => { :update_annotation => :post, 
                                       :move_higher       => :post, 
                                       :move_lower        => :post, 
                                       :move_to_top       => :post, 
                                       :move_to_bottom    => :post }
      end
    end
  end
  
  # sidebar_list and permalink_list define :value to take any char but newline and / 
  map.sidebar_list  "sidebar/list/:type/:value/:user",
                    :controller => "sidebar",
                    :action => "list",
                    :type => /\w+/,
                    :value => /[^\/]+/,
                    :user => nil  
                   
  map.sidebar_cloud "sidebar/cloud/:type/:user",
                    :controller => "sidebar",
                    :action => "cloud",
                    :type => /\w+/,
                    :user => nil
  
  map.permalink_list 'permalink/list/:type/:value/:user', 
                    :controller => 'sidebar', 
                    :action => 'permalink_list',
                    :value => /[^\/]+/,
                    :user => nil
  map.permalink_cloud 'permalink/cloud/:type/:user', 
                    :controller => 'sidebar', 
                    :action => 'permalink_cloud',
                    :user => nil
  map.permalink_detail 'permalink/detail', 
                    :controller => 'sidebar', 
                    :action => 'permalink_detail'

  map.connect 'collex/:action', :controller => 'search'
  map.connect 'browse/saved/:username/:name', :controller => 'search', :action => 'saved_permalink'
  map.connect 'admin', :controller => 'admin/default'
  
# Install the default route as the lowest priority.
  map.connect ':controller/:action'
end
