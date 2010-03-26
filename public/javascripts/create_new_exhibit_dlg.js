// ------------------------------------------------------------------------
//     Copyright 2009 Applied Research in Patacriticism and the University of Virginia
// 
//     Licensed under the Apache License, Version 2.0 (the "License");
//     you may not use this file except in compliance with the License.
//     You may obtain a copy of the License at
// 
//         http://www.apache.org/licenses/LICENSE-2.0
// 
//     Unless required by applicable law or agreed to in writing, software
//     distributed under the License is distributed on an "AS IS" BASIS,
//     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//     See the License for the specific language governing permissions and
//     limitations under the License.
// ----------------------------------------------------------------------------

/*global $, Class, Ajax */
/*global window */
/*global GeneralDialog, ObjectSelector, CreateListOfObjects, genericAjaxFail */
/*extern CreateNewExhibitWizard */

var CreateNewExhibitWizard = Class.create({
	initialize: function (params) {
		this.class_type = 'CreateNewExhibitWizard';	// for debugging
		var progress_img = params.progress_img;
		var url_get_objects = params.url_get_objects;
		var populate_collex_obj_url = params.populate_collex_obj_url;
		var group_id = params.group_id;
		var cluster_id = params.cluster_id;

		// private variables
		var This = this;
		var obj_selector = new ObjectSelector(progress_img, url_get_objects, -1);

		// private functions

		this.changeView = function (event, param)
		{
			var curr_page = param.curr_page;
			var view = param.destination;
			var dlg = param.dlg;

			// Validation
			dlg.setFlash("", false);
			if (curr_page === 'choose_title')	// We are on the first page. The user must enter a title before leaving the page.
			{
				var data = dlg.getAllData();
				if (data.exhibit_title.strip().length === 0) {
					dlg.setFlash("Please enter a name for this exhibit before continuing.", true);
					return false;
				}
				dlg.setFlash("Verifying title. Please wait...", false);
				new Ajax.Request('/my_collex/verify_title', { method: 'get', parameters: { title: data.exhibit_title.strip() },
					onSuccess : function(resp) {
						dlg.setFlash('', false);
						$('exhibit_url').value = resp.responseText;
						dlg.changePage(view, null);
					},
					onFailure : function(resp) {
						genericAjaxFail(dlg, resp);
					}
				});
				return false;
			}

			var focus_el = null;
			switch (view)
			{
				case 'choose_title': focus_el = 'exhibit_title'; break;
				case 'choose_other_options': focus_el = 'exhibit_thumbnail'; break;
				case 'choose_palette': break;
			}
			dlg.changePage(view, focus_el);

			return false;
		};

		this.sendWithAjax = function (event, params)
		{
			//var curr_page = params.curr_page;
			var url = params.destination;
			var dlg = params.dlg;

			dlg.setFlash('Verifying exhibit parameters...', false);
			var data = dlg.getAllData();
			data.objects = obj_selector.getSelectedObjects().join('\t');
			data.group_id = group_id;
			data.cluster_id = cluster_id;

			new Ajax.Request(url, {
				parameters : data,
				onSuccess : function(resp) {
					dlg.setFlash('Creating exhibit...', false);
					window.location = "/my_collex/edit_exhibit?id=" + resp.responseText;
				},
				onFailure : function(resp) {
					genericAjaxFail(dlg, resp);
				}
			});
		};

		// privileged methods
		this.show = function () {
			var choose_title = {
					page: 'choose_title',
					rows: [
						[ { text: 'Creating New Exhibit', klass: 'new_exhibit_title' } ],
						[ { text: 'Step 1: Please choose a title for your new exhibit.', klass: 'new_exhibit_label' } ],
						[ { input: 'exhibit_title', klass: 'new_exhibit_input_long' } ],
						[ { text: 'This is the title that will show up in the exhibit list once you decide to share it with other users. You can edit this later by selecting Edit Exhibit Profile at the top of your exhibit editing page.', klass: 'new_exhibit_instructions' } ],
						[ { rowClass: 'last_row' }, { button: 'Next', url: 'choose_palette', callback: this.changeView, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
					]
				};

			var choose_palette = {
					page: 'choose_palette',
					rows: [
						[ { text: 'Creating New Exhibit', klass: 'new_exhibit_title' } ],
						[ { text: 'Step 2: Add objects to your exhibit.', klass: 'new_exhibit_label' } ],
						[ { text: 'Choose resources from your collected objects to add to this new exhibit.', klass: 'new_exhibit_instructions' } ],
						[ { custom: obj_selector } ],
						[ { text: 'Any object you have collected is available for use in your exhibit. You may add or remove objects from this list at any time.', klass: 'new_exhibit_instructions' } ],
						[ { rowClass: 'last_row' }, { button: 'Next', url: 'choose_other_options', callback: this.changeView, isDefault: true }, { button: 'Previous', url: 'choose_title', callback: this.changeView }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
					]
				};

			// Get the current server location.
			var server = window.location;
			server = 'http://' + server.host;

			var choose_other_options = {
					page: 'choose_other_options',
					rows: [
						[ { text: 'Creating New Exhibit', klass: 'new_exhibit_title' } ],
						[ { text: 'Step 3: Additional options', klass: 'new_exhibit_label' } ],
						[ { text: 'Choose a url for your exhibit:', klass: 'new_exhibit_label' } ],
						[ { text: server + '/exhibits/&nbsp;', klass: 'new_exhibit_label' }, { input: 'exhibit_url', klass: 'new_exhibit_input' } ],
						[ { text: 'Paste a link to a thumbnail image:', klass: 'new_exhibit_label' } ],
						[ { input: 'exhibit_thumbnail', klass: 'new_exhibit_input_long' } ],
						[ { page_link: '[Choose thumbnail from collected objects]', callback: this.changeView, new_page: 'choose_thumbnail' }],
						[ { text: 'The thumbnail image will appear next to your exhibit in the exhibit list once you decide to share it with other users. Please use an image that is small, so that the pages doesn\'t take too long to load. These items are optional and can be entered at any time.', klass: 'new_exhibit_instructions' } ],
						[ { rowClass: 'last_row' }, { button: 'Create Exhibit', url: '/my_collex/create_exhibit', callback: this.sendWithAjax, isDefault: true }, { button: 'Previous', url: 'choose_palette', callback: this.changeView }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
					]
				};

			var origValue = "";
			var selectObject = function(id) {
				// This is a callback that is called when the user selects a NINES Object.
				var thumbnail = $('exhibit_thumbnail');
				var selection = $(id + '_img');
				origValue = thumbnail.value;
				thumbnail.value = selection.src;
			};

			var objlist = new CreateListOfObjects(populate_collex_obj_url, null, 'nines_object', progress_img, selectObject);

			var cancelThumbnail = function(event, params) {
				objlist.clearSelection();
				var thumbnail = $('exhibit_thumbnail');
				thumbnail.value = origValue;
				This.changeView(event, params);
			};

			var choose_thumbnail = {
					page: 'choose_thumbnail',
					rows: [
						[ { text: 'Creating New Exhibit', klass: 'new_exhibit_title' } ],
						[ { text: 'Sort objects by:', klass: 'forum_reply_label' },
							{ select: 'sort_by', change: objlist.sortby, klass: 'link_dlg_select', value: 'date_collected', options: [{ text:  'Date Collected', value:  'date_collected' }, { text:  'Title', value:  'title' }, { text:  'Author', value:  'author' }] },
							{ text: 'and', klass: 'link_dlg_label_and' }, { inputFilter: 'filterObjects', klass: '', prompt: 'type to filter objects', callback: objlist.filter } ],
						[ { custom: objlist, klass: 'new_exhibit_label' } ],
						[ { rowClass: 'last_row' }, { button: 'Ok', url: 'choose_other_options', callback: this.changeView, isDefault: true }, { button: 'Cancel', url: 'choose_other_options', callback: cancelThumbnail } ]
					]
				};

			var pages = [ choose_title, choose_palette, choose_other_options, choose_thumbnail ];

			var params = { this_id: "new_exhibit_wizard", pages: pages, body_style: "new_exhibit_div", row_style: "new_exhibit_row", title: "New Exhibit Wizard" };
			var dlg = new GeneralDialog(params);
			this.changeView(null, { curr_page: '', destination: 'choose_title', dlg: dlg });
			dlg.center();
			obj_selector.populate(dlg);
			objlist.populate(dlg, false, 'thumb');

			return;
		};
	}
});



