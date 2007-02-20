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

  map.connect 'atom/:type/:value/:user', :controller => 'sidebar', :action => 'atom'
  map.connect 'atom/:type/:value', :controller => 'sidebar', :action => 'atom'
  
  map.resources :exhibits
  
  map.sidebar_list "sidebar/list/:type/:value/:user",
                   :controller => "sidebar",
                   :action => "list",
                   :type => nil,
                   :value => nil,
                   :user => nil  
                   
  map.sidebar_cloud "sidebar/cloud/:type//:user",
                   :controller => "sidebar",
                   :action => "cloud",
                   :type => nil,
                   :value => nil,
                   :user => nil
  
  map.permalink 'permalink/list/:type/:value/:user', :controller => 'sidebar', :action => 'permalink', :view => 'list'
  map.permalink 'permalink/list/:type/:value', :controller => 'sidebar', :action => 'permalink', :view => 'list'
  map.permalink 'permalink/cloud/:type/:user', :controller => 'sidebar', :action => 'permalink', :view => 'cloud'
  map.permalink 'permalink/cloud/:type', :controller => 'sidebar', :action => 'permalink', :view => 'cloud'
  map.permalink 'permalink/detail', :controller => 'sidebar', :action => 'permalink', :view => 'detail'

  map.connect 'collex/:action', :controller => 'search'
  map.connect 'admin', :controller => 'admin/default'
  
  # /solr/update is mapped here to allow RdfFileIndexer2 to post here without change
  map.connect 'solr/update', :controller => 'resource', :action => 'post'
  
# Install the default route as the lowest priority.
  map.connect ':controller/:action'
end
