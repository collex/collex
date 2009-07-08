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
	def self.get_js(page)
		prototype = [ 'prototype' ]
		prototype_most = [ 'effects', 'controls' ]
		prototype = prototype + prototype_most #if page != :about

		yui = [
			"/build/yahoo-dom-event/yahoo-dom-event",
			"/build/json/json",
			"/build/element/element",
			"/build/button/button",
			"/build/container/container",
			"/build/dragdrop/dragdrop"
		]
		yui_most = [
			"/build/connection/connection",
			"/build/menu/menu",
			"/build/editor/editor",
			"/build/resize/resize"
		]
		yui = yui + yui_most if page != :about && page != :news && page != :view_exhibit

		if page == :home
			yui = yui + [ "/build/animation/animation", "/build/carousel/carousel" ]
		end

		global = [ 'general_dialog', 'modal_dialog', 'login', 'nospam' ]
		global_most = [ 'rich_text_editor_wrapper', 'link_dlg', 'input_dialog', 'hide_spinner' ]
		global = global + global_most if page != :about && page != :news && page != :view_exhibit

		local = []
		case page
			when :search
				local = [ 'search_validation', 'resource_tree', 'saved_search', 'result_row_popup' ]
			when :tag
				local = [ 'sidebar_tag_cloud', 'tag_zoom', 'result_row_popup' ]
			when :my9s
				local = [ 'initialize_inplacericheditor', 'sidebar_tag_cloud', 'edit_exhibit', 'result_row_popup', 'thumbnail_resize', 'saved_search', 
					'border_dialog', 'edit_exhibit_object_list_dlg', 'set_author_alias_dlg', 'create_new_exhibit_dlg', 'edit_user_profile_dlg' ]
			when :discuss
				local = [ 'discussions', 'result_row_popup' ]
			when :admin
				local = [ 'admin', 'resource_tree' ]
			when :view_exhibit
				global = [ 'modal_dialog', 'hide_spinner' ]
			when :home
				local = [ 'get_news_feed' ]
			when :exhibits
				local = [ 'thumbnail_resize' ]
		end

		return { :prototype => prototype, :yui => yui, :local => global + local }
	end

	def self.get_css(page)
		yui = [
			"/build/reset-fonts-grids/reset-fonts-grids",
			"/build/base/base",
			"/build/button/assets/skins/sam/button",
			"/build/container/assets/skins/sam/container",
			"/build/assets/skins/sam/skin"
			]

		yui_most = [
			"/build/reset-fonts-grids/reset-fonts-grids",
			"/build/base/base",
			"/build/menu/assets/skins/sam/menu",
			"/build/button/assets/skins/sam/button",
			"/build/container/assets/skins/sam/container",
			"/build/editor/assets/skins/sam/editor",
			"/build/resize/assets/skins/sam/resize",
			"/build/assets/skins/sam/skin"
			]
		yui = yui_most if page != :about && page != :news && page != :view_exhibit

		global = [
			"main",
			"nav",
			"js_dialog"
		]

		local = []
		case page
			when :search
				local = [ "lvl2", "search", "right_column", "result_row" ]
			when :tag
				local = [ "lvl2", "tag", "result_row" ]
			when :my9s
				local = [ "lvl2", "right_column", "tag", "search", "my9s", "exhibit_list", "result_row", "exhibit", "edit_exhibit_outline" ]
			when :discuss
				local = [ "lvl2", "search", "result_row", "forum" ]
			when :home
				local = [ "index", "featured_exhibit" ]
			when :exhibits
				local = [ "lvl2", "featured_exhibit", "exhibit_list" ]
			when :admin
				local = [ "lvl2", "admin", "search", "right_column" ]
			when :about
				local = [ "lvl2", "about" ]
			when :view_exhibit
				local = [ "lvl3", "exhibit" ]
		end

		return { :yui => yui, :local => global + local }
	end
end
