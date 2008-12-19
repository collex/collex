##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

ActionController::Routing::Routes.draw do |map|
  #map.resources :exhibit_objects

  map.resources :exhibit_illustrations

  map.resources :exhibit_elements

  #map.resources :exhibit_sections

  map.resources :exhibit_pages

  map.exhibits_display '/exhibits/:id', :controller => 'exhibits', :action => 'view'
  map.resources :exhibits

  map.resources :tagassigns


  map.resources :collected_items

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
                    :controller => 'home',
                    :action => 'atom',
                    :value => /[^\/]+/,
                    :user => nil

  # sidebar_list and permalink_list define :value to take any char but newline and / 
#  map.sidebar_list  "sidebar/list/:type/:value/:user",
#                    :controller => "sidebar",
#                    :action => "list",
#                    :type => /\w+/,
#                    :value => /[^\/]+/,
#                    :user => nil  
#                   
#  map.sidebar_cloud "sidebar/cloud/:type/:user",
#                    :controller => "sidebar",
#                    :action => "cloud",
#                    :type => /\w+/,
#                    :user => nil
#  
#  map.permalink_list 'permalink/list/:type/:value/:user', 
#                    :controller => 'sidebar', 
#                    :action => 'permalink_list',
#                    :value => /[^\/]+/,
#                    :user => nil
#  map.permalink_cloud 'permalink/cloud/:type/:user', 
#                    :controller => 'sidebar', 
#                    :action => 'permalink_cloud',
#                    :user => nil
#  map.permalink_detail 'permalink/detail', 
#                    :controller => 'sidebar', 
#                    :action => 'permalink_detail'
#
#  map.connect 'redirect/ravon-nowviskie1.html', 
#    :controller =>'sidebar',
#    :action => 'permalink_list',
#    :value => 'collex',
#    :user => 'nowviskie',
#    :type => 'tag'
#
#  map.connect 'redirect/ravon-nowviskie2.html', 
#    :controller =>'search',
#    :action => 'saved_permalink',
#    :name => 'ravon-article',
#    :username => 'nowviskie'

  # All the old links just go to the main page now.
  map.connect 'collex', :controller => 'home', :action => 'redirect_to_index'
  map.sidebar_list  "sidebar/list/:type/:value/:user", :controller => "home", :action => "redirect_to_index"
  map.sidebar_cloud "sidebar/cloud/:type/:user", :controller => "home", :action => "redirect_to_index"
  map.permalink_list 'permalink/list/:type/:value/:user', :controller => "home", :action => "redirect_to_index"
  map.permalink_cloud 'permalink/cloud/:type/:user', :controller => "home", :action => "redirect_to_index"
  map.permalink_detail 'permalink/detail', :controller => "home", :action => "redirect_to_index"
  map.connect 'redirect/ravon-nowviskie1.html', :controller => "home", :action => "redirect_to_index"
  map.connect 'redirect/ravon-nowviskie2.html', :controller => "home", :action => "redirect_to_index"


  map.connect 'collex/:action', :controller => 'search'
  map.connect 'browse/saved/:username/:name', :controller => 'search', :action => 'saved_permalink'
  map.connect 'admin', :controller => 'admin/default'
  
  map.news '/news', :controller => 'home', :action => 'news'
  map.search '/search', :controller => 'search', :action => 'browse'
  map.tab_about '/tab_about', :controller => 'about', :action => 'index'
  map.tags '/tags', :controller => 'tag', :action => 'list'
  map.login '/login', :controller => 'login', :action => 'login'
  map.my9s '/my9s', :controller => 'my9s', :action => 'index'
  map.exhibit_list '/exhibit_list', :controller => 'exhibits', :action => 'list'
  map.exhibits_view '/exhibits/view/:id', :controller => 'exhibits', :action => 'view'

  map.root :controller => "home", :action => "index"

# Install the default route as the lowest priority.
  map.connect ':controller/:action'
end
