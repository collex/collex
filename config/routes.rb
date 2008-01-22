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
                             :unpublish           => :post, 
                             :collect           => :post, 
                             :update_annotation => :post } do |exhibit|
    exhibit.resources :pages, 
                      :controller => :exhibited_pages,
                      :member => { :update_title      => :post, 
                                   :update_annotation => :post,
                                   :move_higher       => :post, 
                                   :move_lower        => :post, 
                                   :move_to_top       => :post, 
                                   :move_to_bottom    => :post } do |page|
      page.resources   :sections, 
                       :controller => :exhibited_sections,
                       :member => { :update_title      => :post, 
                                    :update_annotation => :post,
                                    :move_higher       => :post, 
                                    :move_lower        => :post, 
                                    :move_to_top       => :post, 
                                    :move_to_bottom    => :post } do |section|
        section.resources :texts, 
                          :controller => :exhibited_texts,
                          :member => { :update_annotation => :post}
        section.resources :resources, 
                          :controller => :exhibited_resources,
                          :member => { :update_annotation => :post}
        section.resources :items, 
                          :controller => :exhibited_items,
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

  map.connect 'redirect/ravon-nowviskie1.html', 
    :controller =>'sidebar',
    :action => 'permalink_list',
    :value => 'collex',
    :user => 'nowviskie',
    :type => 'tag'

  map.connect 'redirect/ravon-nowviskie2.html', 
    :controller =>'search',
    :action => 'saved_permalink',
    :name => 'ravon-article',
    :username => 'nowviskie'

  map.connect 'collex/:action', :controller => 'search'
  map.connect 'browse/saved/:username/:name', :controller => 'search', :action => 'saved_permalink'
  map.connect 'admin', :controller => 'admin/default'
  
# Install the default route as the lowest priority.
  map.connect ':controller/:action'
end
