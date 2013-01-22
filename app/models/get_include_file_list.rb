##########################################################################
# Copyright 2009 Applied Research in Patacriticism and the University of Virginia
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

class GetIncludeFileList
	#def self.get_js(page)
	#	prototype = [ 'prototype' ]
	#	prototype_most = [ 'effects', 'controls', 'rails' ]
	#	prototype = prototype + prototype_most #if page != :about
	#
	#	yui = [
	#		"/build/yahoo-dom-event/yahoo-dom-event",
	#		"/build/json/json",
	#		"/build/element/element",
	#		"/build/button/button",
	#		"/build/container/container",
	#		"/build/dragdrop/dragdrop"
	#	]
	#	yui_most = [
	#		"/build/connection/connection",
	#		"/build/menu/menu",
	#		"/build/editor/editor",
	#		"/build/resize/resize",
	#		"/build/paginator/paginator",
	#		"/build/datasource/datasource",
	#		"/build/datatable/datatable"
	#	]
	#	yui = yui + yui_most if page != :about && page != :news && page != :view_exhibit
	#
	#	if page == :home
	#		yui = yui + [ "/build/animation/animation", "/build/carousel/carousel" ]
	#	end
	#
	#	global = [ 'general_dialog', 'server_wrapper', 'login', 'nospam' ]
	#	global_most = [ 'rich_text_editor_wrapper', 'link_dlg', 'hide_spinner', 'typewright' ]
	#	global = global + global_most if page != :about && page != :news && page != :view_exhibit && page != :print_exhibit
	#
	#	local = []
	#	case page
	#	  when :typewright
	#	    local = [ "search_validation_home", "result_row_popup", 'more', "typewright/features", 'cc_license']
	#		when :typewright_edit
	#			local = [ "typewright/diff_match_patch_uncompressed", "typewright/reparse_words", "typewright/line",
	#				"typewright/img_cursor", "typewright/change_line", "typewright/find_dlg", "typewright/select_page",
	#				"typewright/detailed_instructions", "typewright/report_this_page", "typewright/yui_dialog"]
	#		when :search
	#			local = [ 'search_validation', 'resource_tree', 'saved_search', 'result_row_popup', 'more', 'cc_license', 'search_name_facet', 'change_federation' ]
	#			if COLLEX_PLUGINS['typewright']
	#			  local.push("typewright/features")
	#			end
	#		when :tag
	#			local = [ 'sidebar_tag_cloud', 'tag_zoom', 'result_row_popup', 'more', 'cc_license' ]
	#			if COLLEX_PLUGINS['typewright']
	#			  local.push("typewright/features")
	#			end
	#		when :my_collex
	#			local = [ 'initialize_inplacericheditor', 'sidebar_tag_cloud', 'edit_exhibit', 'result_row_popup', 'more', 'thumbnail_resize', 'saved_search', 'cc_license',
	#				'border_dialog', 'edit_exhibit_object_list_dlg', 'set_author_alias_dlg', 'create_new_exhibit_dlg', 'edit_user_profile_dlg', 'footnotes', 'renumber_footnotes',
	#				'create_new_group_dlg', 'edit_fonts_dlg', 'exhibit_builder_outline', 'my_collex', 'exhibit_builder_profile', 'browse_groups' ]
	#			if COLLEX_PLUGINS['typewright']
	#			  local.push("typewright/features")
	#			end
	#		when :discuss
	#			local = [ 'discussions', 'result_row_popup', 'more', 'cc_license', 'flag_comment' ]
	#		when :admin
	#			local = [ 'admin', 'resource_tree', 'features', 'typewright/features', 'tree_control' ]
	#		when :view_exhibit
	#			global = [ 'hide_spinner', 'general_dialog', 'server_wrapper', 'renumber_footnotes', 'login', 'nospam' ]
	#		when :print_exhibit
	#			global = [ 'hide_spinner', 'renumber_footnotes' ]
	#		when :home
	#			local = [ 'get_news_feed', 'search_validation_home' ]
	#		when :shared
	#			local = [ 'thumbnail_resize', 'edit_exhibit_object_list_dlg', 'create_new_exhibit_dlg', 'cc_license', 'discussions', 'group_page',
	#			'create_new_group_dlg', 'edit_fonts_dlg', 'start_discussion_with_exhibit', 'ajax_pagination', 'resource_tree' ]
	#		when :exhibits
	#			local = [ 'thumbnail_resize', 'edit_exhibit_object_list_dlg', 'create_new_exhibit_dlg', 'cc_license', 'discussions', 'group_page',
	#			'create_new_group_dlg', 'edit_fonts_dlg', 'start_discussion_with_exhibit' ]
	#		when :about
	#			local = [ 'more' ]
	#	end
	#
	#	return { :prototype => prototype, :yui => yui, :local => global + local }
	#end
	#
	#def self.get_css(page)
	#	yui = [
	#		"/build/reset-fonts-grids/reset-fonts-grids",
	#		"/build/base/base",
	#		"/build/button/assets/skins/sam/button",
	#		"/build/container/assets/skins/sam/container",
	#		"/build/assets/skins/sam/skin"
	#		]
	#
	#	yui_most = [
	#		"/build/reset-fonts-grids/reset-fonts-grids",
	#		"/build/base/base",
	#		"/build/menu/assets/skins/sam/menu",
	#		"/build/button/assets/skins/sam/button",
	#		"/build/container/assets/skins/sam/container",
	#		"/build/editor/assets/skins/sam/editor",
	#		"/build/resize/assets/skins/sam/resize",
	#		"/build/assets/skins/sam/skin",
	#		"/build/paginator/assets/skins/sam/paginator",
	#		"/build/datatable/assets/skins/sam/datatable"
	#		]
	#	yui = yui_most if page != :about && page != :news && page != :view_exhibit && page != :print_exhibit
	#
	#	global = [
	#		"main",
	#		"nav",
	#		"#{SKIN}/main_skin",
	#		"js_dialog",
	#		"autocomplete"
	#	]
	#
	#	local = []
	#	case page
	#		when :typewright
	#			local = [ "#{SKIN}/lvl2_skin", "lvl2", "typewright/typewright", "community", "#{SKIN}/community_skin", "result_row" ]
	#		when :typewright_edit
	#			local =  [ "#{SKIN}/lvl3_skin", "lvl3", "typewright/typewright_edit" ]
	#		when :search
	#			local = [ "#{SKIN}/lvl2_skin", "lvl2", "search", "right_column", "result_row" ]
	#		when :tag
	#			local = [ "#{SKIN}/lvl2_skin", "lvl2", "tag", "result_row" ]
	#		when :my_collex
	#			local = [ "#{SKIN}/lvl2_skin", "lvl2", "right_column", "tag", "search", "my_collex", "exhibit_list", "result_row", "exhibit", "edit_exhibit_outline", "user_profile" ]
	#		when :discuss
	#			local = [ "#{SKIN}/lvl2_skin", "lvl2", "search", "result_row", "forum", "#{SKIN}/forum_skin", "user_profile" ]
	#		when :home
	#			local = [ "#{SKIN}/lvl1_skin", "index", "featured_exhibit" ]
	#		when :exhibits
	#			local = [ "#{SKIN}/lvl2_skin", "lvl2", "featured_exhibit", "exhibit_list", "user_profile", "right_column" ]
	#		when :shared
	#			local = [ "#{SKIN}/lvl2_skin", "lvl2", "search", "featured_exhibit", "community", "#{SKIN}/community_skin", "tag", "result_row", "user_profile", "right_column", "groups", "#{SKIN}/groups_skin" ]
	#		when :admin
	#			local = [ "#{SKIN}/lvl2_skin", "lvl2", "admin", "#{SKIN}/admin_skin", "search", "right_column" ]
	#		when :about
	#			local = [ "#{SKIN}/lvl2_skin", "lvl2", "#{SKIN}/about_skin" ]
	#		when :news
	#			local = [ "#{SKIN}/lvl2_skin", "lvl2", "#{SKIN}/about_skin" ]
	#		when :view_exhibit
	#			local = [ "#{SKIN}/lvl3_skin", "lvl3", "exhibit" ]
	#		when :print_exhibit
	#			local = [ "lvl4", "exhibit" ]
	#	end
	#
	#	return { :yui => yui, :local => global + local }
	#end
end
