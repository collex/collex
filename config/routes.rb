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
	map.stale_request '/groups/stale_request', :controller => 'groups', :action => 'stale_request'
	map.accept_request '/groups/accept_request', :controller => 'groups', :action => 'accept_request'
  map.decline_request '/groups/decline_request', :controller => 'groups', :action => 'decline_request'
  map.decline_invitaion '/groups/decline_invitation', :controller => 'groups', :action => 'decline_invitation'
  map.accept_invitation '/groups/accept_invitation', :controller => 'groups', :action => 'accept_invitation'
	map.acknowledge_notification '/groups/acknowledge_notification', :controller => 'groups', :action => 'acknowledge_notification'
	map.create_login '/groups/create_login', :controller => 'groups', :action => 'create_login'
	map.show_clusters '/groups/:group/:cluster', :controller => 'clusters', :action => 'show'

  map.resources :clusters
  map.resources :groups

  map.discussion_thread_rss '/forum/rss/:thread.xml', :controller => 'forum', :action => 'rss'

  map.resources :exhibit_illustrations

  map.resources :exhibit_elements

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

  # All the old links just go to the main page now.
  map.connect 'collex', :controller => 'home', :action => 'redirect_to_index'
  map.sidebar_list  "sidebar/list/:type/:value/:user", :controller => "home", :action => "redirect_to_index"
  map.sidebar_cloud "sidebar/cloud/:type/:user", :controller => "home", :action => "redirect_to_index"
  map.permalink_list 'permalink/list/:type/:value/:user', :controller => "home", :action => "redirect_to_index"
  map.permalink_cloud 'permalink/cloud/:type/:user', :controller => "home", :action => "redirect_to_tag_cloud_update"
  map.permalink_detail 'permalink/detail', :controller => "home", :action => "redirect_to_index"
  map.connect 'redirect/ravon-nowviskie1.html', :controller => "search", :action => "saved", :user => "nowviskie", :name => "ravon-article"
  map.connect 'redirect/ravon-nowviskie2.html', :controller => "tag", :action => "results", :tag => "collex", :view => 'tag'

  # here are some permalinks that got moved
  map.cloud1 'permalink/cloud/:type', :controller => "home", :action => "redirect_to_tag_cloud_update"

  # All the old about pages
  map.about_software '/software/:page.html', :controller => 'about', :action => 'software', :ext => 'html'
  map.about_software2 '/software/:page.pdf', :controller => 'about', :action => 'software', :ext => 'pdf'
  map.about_software3 '/software/:page.doc', :controller => 'about', :action => 'software', :ext => 'doc'
  map.about_software4 '/software/:page', :controller => 'about', :action => 'software', :ext => 'html'
  map.about_software5 '/software', :controller => 'about', :action => 'software', :ext => 'html'
  map.about_community '/community/:page.html', :controller => 'about', :action => 'community', :ext => 'html'
  map.about_community2 '/community/:page.pdf', :controller => 'about', :action => 'community', :ext => 'pdf'
  map.about_community3 '/community/:page.doc', :controller => 'about', :action => 'community', :ext => 'doc'
  map.about_community4 '/community/:page', :controller => 'about', :action => 'community', :ext => 'html'
  map.about_community5 '/community', :controller => 'about', :action => 'community', :ext => 'html'
  map.about_scholarship '/scholarship/:page.html', :controller => 'about', :action => 'scholarship', :ext => 'html'
  map.about_scholarship2 '/scholarship/:page.pdf', :controller => 'about', :action => 'scholarship', :ext => 'pdf'
  map.about_scholarship3 '/scholarship/:page.doc', :controller => 'about', :action => 'scholarship', :ext => 'doc'
  map.about_scholarship4 '/scholarship/:page', :controller => 'about', :action => 'scholarship', :ext => 'html'
  map.about_scholarship5 '/scholarship', :controller => 'about', :action => 'scholarship', :ext => 'html'

  map.connect 'collex/:action', :controller => 'search'
  map.connect 'browse/saved/:username/:name', :controller => 'search', :action => 'saved_permalink'
  map.connect 'admin', :controller => 'admin/default'

  map.tag_xml '/tags.xml', :controller => 'tag', :action => 'list', :format => 'xml'
  map.tag_rss '/tags/rss/:tag.xml', :controller => 'tag', :action => 'rss'
  map.tag_obj '/tags/object', :controller => 'tag', :action => 'object'
  map.tag_res '/tags/results', :controller => 'tag', :action => 'results'

  map.news '/news', :controller => 'about', :action => 'news'
  map.search '/search', :controller => 'search', :action => 'browse'
  map.about '/about', :controller => 'about', :action => 'index'
  map.tags '/tags', :controller => 'tag', :action => 'list'

	# This gets called before environment.rb, so the constant we need isn't loaded yet. We'll load it here.
  config_file = File.join(RAILS_ROOT, "config", "site.yml")
  if File.exists?(config_file)
	  site_specific = YAML.load_file(config_file)
    map.my_collex '/'+site_specific['my_collex_url'], :controller => 'my_collex', :action => 'index'
    map.my_collex '/'+site_specific['my_collex_url'] + '/:action', :controller => 'my_collex'
  else
    map.my_collex '/my_collex', :controller => 'my_collex', :action => 'index'
  end
  map.forum '/forum', :controller => 'forum', :action => 'index'
  map.print_exhibit '/print_exhibit/:id', :controller => 'exhibits', :action => 'print_exhibit'
  map.exhibit_list '/exhibit_list', :controller => 'communities', :action => 'index'
  map.exhibits_view '/exhibits/view/:id', :controller => 'exhibits', :action => 'view'

  map.root :controller => "home", :action => "index"
#	map.cluster_url '/:group/:cluster', :controller=>"clusters",:action=>"show"

# Install the default route as the lowest priority.
  map.connect ':controller/:action'
end
