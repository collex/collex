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

Collex::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
	# for transmitting the theme to wordpress
	get "/wrapper" => "home#wrapper"
  get "/login_slider" => "home#login_slider"

	get "test_js/general_dialog"

    get '/search/add_tw_constraint' => 'search#add_tw_constraint'
	match '/search/list_name_facet_all' => 'search#list_name_facet_all'
	post '/search/remove_constraint' => 'search#remove_constraint'
	post '/search/add_federation_constraint' => 'search#add_federation_constraint'
	post '/search/constrain_resource' => 'search#constrain_resource'
	post '/search/add_facet' => 'search#add_facet'
	post '/search/constrain_freeculture' => 'search#constrain_freeculture'
  post '/search/constrain_fulltext' => 'search#constrain_fulltext'
  post '/search/constrain_typewright' => 'search#constrain_typewright'
	post '/search/invert_constraint' => 'search#invert_constraint'
	post '/search/sort_by' => 'search#sort_by'
	post '/search/remove_genre' => 'search#remove_genre'
	match '/search/remember_resource_toggle' => 'search#remember_resource_toggle'
	match '/search/saved' => 'search#saved'
	match '/search/save_search' => 'search#save_search'
	post '/search/remove_saved_search' => 'search#remove_saved_search'
	match '/search/browse' => 'search#browse'
	
	post '/search/auto_complete_for_search_university' => 'search#auto_complete_for_search_university'

	post '/results/add_object_to_exhibit' => 'results#add_object_to_exhibit'
	post '/results/add_tag' => 'results#add_tag'
	post '/results/bulk_add_tag' => 'results#bulk_add_tag'
	post '/results/bulk_collect' => 'results#bulk_collect'
	post '/results/bulk_uncollect' => 'results#bulk_uncollect'
	post '/results/collect' => 'results#collect'
	post '/results/edit_tag' => 'results#edit_tag'
	match '/results/redraw_result_row_for_popup_buttons' => 'results#redraw_result_row_for_popup_buttons'
	post '/results/remove_all_tags' => 'results#remove_all_tags'
	post '/results/remove_tag' => 'results#remove_tag'
	post '/results/set_annotation' => 'results#set_annotation'
	post '/results/uncollect' => 'results#uncollect'
	post '/results/resend_exhibited_objects' => 'results#resend_exhibited_objects'

	match '/help/resources' => 'help#resources'
	match '/help/sites' => 'help#sites'

	post '/communities/view_by' => 'communities#view_by'
	post '/communities/sort_by' => 'communities#sort_by'
	post '/communities/search' => 'communities#search'
	post "/communities/page" => "communities#page"

	post '/builder/add_additional_author' => 'builder#add_additional_author'
	post '/builder/change_exhibits_group' => 'builder#change_exhibits_group'
	post '/builder/change_exhibits_cluster' => 'builder#change_exhibits_cluster'
	post '/builder/change_sharing' => 'builder#change_sharing'
	post '/builder/change_img_width' => 'builder#change_img_width'
	post '/builder/change_element_type' => 'builder#change_element_type'
	get '/builder/change_page' => 'builder#change_page'
	post '/builder/edit_exhibit_overview' => 'builder#edit_exhibit_overview'
	post '/builder/edit_text' => 'builder#edit_text'
	post '/builder/edit_header' => 'builder#edit_header'
	post '/builder/edit_element' => 'builder#edit_element'
	post '/builder/edit_illustration' => 'builder#edit_illustration'
	post '/builder/find_page_containing_element' => 'builder#find_page_containing_element'
	post '/builder/get_all_collected_objects' => 'builder#get_all_collected_objects'
	post '/builder/get_alias_users' => 'builder#get_alias_users'
	post '/builder/modify_outline' => 'builder#modify_outline'
	post '/builder/modify_outline_page' => 'builder#modify_outline_page'
	post '/builder/modify_border' => 'builder#modify_border'
	post '/builder/remove_additional_author' => 'builder#remove_additional_author'
	post '/builder/remove_exhibited_object' => 'builder#remove_exhibited_object'
	post '/builder/redraw_exhibit_page' => 'builder#redraw_exhibit_page'
	post '/builder/refresh_outline' => 'builder#refresh_outline'
	post '/builder/reset_exhibit_page_from_outline' => 'builder#reset_exhibit_page_from_outline'
	post '/builder/set_exhibit_author_alias' => 'builder#set_exhibit_author_alias'
	post '/builder/publish_exhibit' => 'builder#publish_exhibit'
	post '/builder/update_fonts' => 'builder#update_fonts'
	post '/builder/update_objects_in_exhibits' => 'builder#update_objects_in_exhibits'
	post '/builder/update_title' => 'builder#update_title'
	post '/builder/verify_title' => 'builder#verify_title'
	post '/builder/change_illustration_justification'
	post '/builder/insert_illustration'
	post '/builder/edit_row_of_illustrations'
	post '/builder/import_exhibit'
	post '/builder/modify_outline_add_first_element'

	# This gets called before environment.rb, so the constant we need isn't loaded yet. We'll load it here.
	config_file = File.join(Rails.root, "config", "site.yml")
	my_collex = 'my_collex'
	plugins = {}
	if File.exists?(config_file)
		site_specific = YAML.load_file(config_file)
		my_collex = site_specific['my_collex_url']
		plugins = site_specific['plugins'] || {}
		plugins.delete_if { |key, value| value != true }
	end
	get "/#{my_collex}" => 'my_collex#index'
	get "/#{my_collex}/results" => 'my_collex#results'
	post "/my_collex/results" => 'my_collex#results'

	post '/my_collex/remove_profile_picture' => 'my_collex#remove_profile_picture'
	post '/my_collex/show_profile' => 'my_collex#show_profile'
	post '/my_collex/sort_by' => 'my_collex#sort_by'
	post '/my_collex/update_profile_upload' => 'my_collex#update_profile_upload'
	post '/my_collex/update_profile' => 'my_collex#update_profile'

	if plugins['typewright']
		get "typewright/edit"
		post "typewright/remove_doc"

		namespace :typewright do
			get 'documents/not_available'
			get 'documents/not_signed_in'
			post 'documents/instructions'
			post 'documents/:id/report' => 'documents#report'
			resources :admin do
				collection do
					get 'stats'
				end
			end
			resources :documents
			resources :lines
			resources :document_users
    end

    get "typewright" => 'typewright/documents#index'

	end

	get "/login/logout" => "login#logout"
	post "/login/verify_login" => "login#verify_login"
	post "/login/submit_signup" => "login#submit_signup"
	post "/login/recover_username" => "login#recover_username"
	post "/login/reset_password" => "login#reset_password"
	get "/login/login_controls" => "login#login_controls"

	match "/forum/view_thread" => "forum#view_thread"
	match "/forum/view_topic" => "forum#view_topic"
	match "/forum/get_nines_obj_list_with_image" => "forum#get_nines_obj_list_with_image"
	match "/forum/get_exhibit_list" => "forum#get_exhibit_list"
	match "/forum/get_nines_obj_list" => "forum#get_nines_obj_list"
	post "/forum/post_comment_to_existing_thread" => "forum#post_comment_to_existing_thread"
	match "/forum/result_count" => "forum#result_count"
	post "/forum/edit_existing_comment" => "forum#edit_existing_comment"
	post "/forum/delete_comment" => "forum#delete_comment"
	post "/forum/post_comment_to_new_thread" => "forum#post_comment_to_new_thread"
	match "/forum/get_all_topics" => "forum#get_all_topics"
	post "/forum/post_object_to_new_thread" => "forum#post_object_to_new_thread"
	post "/forum/report_comment" => "forum#report_comment"
	post '/forum/get_object_details' => 'forum#get_object_details'

	post "/classroom/facet_on_group" => "classroom#facet_on_group"
	post "/classroom/search" => "classroom#search"
	post "/classroom/sort_by" => "classroom#sort_by"
	post "/classroom/view_by" => "classroom#view_by"
	post "/classroom/page" => "classroom#page"

#  match '/vic_conference/create' => 'vic_conference#create', :as => :vic_conference
#  match '/vic_conference/auth' => 'vic_conference#auth', :as => :vic_conference_auth

	post "/groups/remove_profile_picture/:id" => "groups#remove_profile_picture"
	get '/groups/stale_request' => 'groups#stale_request', :as => :stale_request
	get '/groups/accept_request' => 'groups#accept_request', :as => :accept_request
	get '/groups/decline_request' => 'groups#decline_request', :as => :decline_request
	match '/groups/decline_invitation' => 'groups#decline_invitation', :as => :decline_invitation
	match '/groups/accept_invitation' => 'groups#accept_invitation', :as => :accept_invitation
	get '/groups/acknowledge_notification' => 'groups#acknowledge_notification', :as => :acknowledge_notification
	match '/groups/create_login' => 'groups#create_login', :as => :create_login
	match 'groups/create_login_create' => 'groups#create_login_create'
	get '/groups/:group/:cluster' => 'clusters#show'
	post "/groups/limit_exhibit" => "groups#limit_exhibit"
	post "/groups/unlimit_exhibit" => "groups#unlimit_exhibit"
	post "/groups/sort_exhibits" => "groups#sort_exhibits"
	post "/groups/unpublish_exhibit" => "groups#unpublish_exhibit"
	post "/groups/group_exhibits_list" => "groups#group_exhibits_list"
	post "/groups/notifications" => "groups#notifications"
	post "/groups/edit_membership" => "groups#edit_membership"
	post "/groups/render_license" => "groups#render_license"
	post "/groups/check_url" => "groups#check_url"
	post "/groups/edit_thumbnail" => "groups#edit_thumbnail"
	post "/groups/sort_cluster" => "groups#sort_cluster"
	post "/groups/leave_group" => "groups#leave_group"
	post "/groups/request_join" => "groups#request_join"
	post "/groups/verify_group_title" => "groups#verify_group_title"
	post '/groups/get_all_groups' => 'groups#get_all_groups'
	post '/groups/accept_as_peer_reviewed' => 'groups#accept_as_peer_reviewed'
	post '/groups/reject_as_peer_reviewed' => 'groups#reject_as_peer_reviewed'
	post '/groups/pending_requests' => 'groups#pending_requests'

	post "/clusters/remove_profile_picture" => "clusters#remove_profile_picture"
	post "/clusters/move_exhibit" => "clusters#move_exhibit"
	post "/clusters/edit_thumbnail" => "clusters#edit_thumbnail"
	post "/clusters/check_url" => "clusters#check_url"

	post "/admin/default/refresh_cached_objects" => "admin/default#refresh_cached_objects"
	get "/admin/facet_tree/index" => "admin/facet_tree#index"
	get "/admin/features/index" => "admin/features#index"
	get "/admin/user_roles/index" => "admin/user_roles#index"
	get "/admin/discussion_topics/index" => "admin/discussion_topics#index"
	get "/admin/default/forum_pending_reports" => "admin/default#forum_pending_reports"
	get "/admin/default/stats" => "admin/default#stats"
	get "/admin/default/groups" => "admin/default#groups"
	get "/admin/default/user_content" => "admin/default#user_content"
#	get "/admin/default/vic_conference" => "admin/default#vic_conference"
	get "/admin/default/use_test_index" => "admin/default#use_test_index"
	get "/admin/default/reload_facet_tree" => "admin/default#reload_facet_tree"
	get "/admin/default/stats_show_all" => "admin/default#stats_show_all"

	post "/admin/default/change_group_type" => "admin/default#change_group_type"
	post "/admin/default/add_badge" => "admin/default#add_badge"
	post "/admin/default/add_publication_image" => "admin/default#add_publication_image"
	post "/admin/default/delete_comment" => "admin/default#delete_comment"
	post "/admin/default/remove_abuse_report" => "admin/default#remove_abuse_report"
	post "/admin/facet_tree/remove_site" => "admin/facet_tree#remove_site"
	post "/admin/facet_tree/get_categories" => "admin/facet_tree#get_categories"
	post "/admin/facet_tree/add_category" => "admin/facet_tree#add_category"
	post "/admin/facet_tree/get_categories_and_details" => "admin/facet_tree#get_categories_and_details"
	post "/admin/facet_tree/edit_facet" => "admin/facet_tree#edit_facet"
	post "/admin/facet_tree/edit_facet_upload" => "admin/facet_tree#edit_facet_upload"
	post "/admin/facet_tree/delete_facet" => "admin/facet_tree#delete_facet"
	post "/admin/facet_tree/add_site" => "admin/facet_tree#add_site"
	post "/admin/discussion_topics/move_down" => "admin/discussion_topics#move_down"
	post "/admin/discussion_topics/move_up" => "admin/discussion_topics#move_up"
	post "/admin/impersonate_user" => "admin/default#impersonate_user"
	post "/admin/get_user_list" => "admin/default#get_user_list"

	post '/exhibits/get_licenses' => 'exhibits#get_licenses'

	get '/home/get_footer_data' => 'home#get_footer_data'

	post '/tag/set_zoom' => 'tag#set_zoom'

	resources :builder
	resources :clusters
	resources :groups
	resources :publications
	resources :communities
	resources :classroom

	namespace :admin do
		resources :features
		resources :user_roles
		resources :discussion_topics
		resources :setups, :only => [ :index, :update ]
	end

  match '/forum/rss/:thread.xml' => 'forum#rss', :as => :discussion_thread_rss
  resources :exhibit_illustrations
  resources :exhibit_elements
  resources :exhibit_pages
  match '/exhibits/:id' => 'exhibits#view', :as => :exhibits_display
  resources :exhibits
  resources :tagassigns
  resources :collected_items
  #match 'atom/:type/:value/:user' => 'home#atom', :as => :atom_feed, :user => , :value => /[^\/]+/
  match 'collex' => 'home#redirect_to_index'
  match 'sidebar/list/:type/:value/:user' => 'home#redirect_to_index', :as => :sidebar_list
  match 'sidebar/cloud/:type/:user' => 'home#redirect_to_index', :as => :sidebar_cloud
  match 'permalink/list/:type/:value/:user' => 'home#redirect_to_index', :as => :permalink_list
  match 'permalink/cloud/:type/:user' => 'home#redirect_to_tag_cloud_update', :as => :permalink_cloud
  match 'permalink/detail' => 'home#redirect_to_index', :as => :permalink_detail
  match 'redirect/ravon-nowviskie1.html' => 'search#saved', :user => 'nowviskie', :name => 'ravon-article'
  match 'redirect/ravon-nowviskie2.html' => 'tag#results', :view => 'tag', :tag => 'collex'
  match 'permalink/cloud/:type' => 'home#redirect_to_tag_cloud_update', :as => :cloud1
  match 'collex/:action' => 'search#index'
  match 'browse/saved/:username/:name' => 'search#saved_permalink'
  match 'admin' => 'admin/default#index'
  match '/tags.xml' => 'tag#list', :as => :tag_xml, :format => 'xml'
  match '/tags/rss/:tag.xml' => 'tag#rss'
  match '/tags/object' => 'tag#object'
	match '/tags/results' => 'tag#results'
  match '/tag/results' => 'tag#results'
  match '/tag/sort_by' => 'tag#sort_by'
  match '/tag/tag_name_autocomplete' => 'tag#tag_name_autocomplete'
	get '/news' => 'home#news'
	get '/home/news' => 'home#news'
  match '/search' => 'search#browse'
  match '/tags' => 'tag#list'
	match '/tag/update_tag_cloud' => 'tag#update_tag_cloud'
  match '/forum' => 'forum#index'
  match '/print_exhibit/:id' => 'exhibits#print_exhibit'
  match '/exhibit_list' => 'communities#index'
  match '/exhibits/view/(:id)' => 'exhibits#view'
  match '/test_exception_notifier' => 'application#test_exception_notifier'
  post '/test_error_response' => 'application#test_error_response'
	root :to => "home#index"
end
