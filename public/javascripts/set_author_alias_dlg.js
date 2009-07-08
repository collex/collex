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

/*global $$, Element, Class, Ajax */
/*global GeneralDialog, MessageBoxDlg */
/*extern SetExhibitAuthorAlias */

var SetExhibitAuthorAlias = Class.create({
	initialize: function (progress_img, url_get_users, url_update_alias, exhibit_id, page_id, page_num) {
		// This puts up a modal dialog that allows the user to select the objects to be in this exhibit.
		this.class_type = 'SetExhibitAuthorAlias';	// for debugging

		// private variables
		var This = this;
		var users = null;
		var dlg = null;

		// private functions
		var populate = function()
		{
			new Ajax.Request(url_get_users, { method: 'get', parameters: { },
				onSuccess : function(resp) {
					dlg.setFlash('', false);
					try {
						users = resp.responseText.evalJSON(true);
					} catch (e) {
						new MessageBoxDlg("Error", e);
					}
					// We got all the users. Now put it on the dialog
					var sel_arr = $$('.user_alias_select');
					var select = sel_arr[0];
					select.update('');
					users = users.sortBy(function(user) { return user.text; });
					users.each(function(user) {
						select.appendChild(new Element('option', { value: user.value }).update(user.text));
					});
				},
				onFailure : function(resp) {
					dlg.setFlash(resp.responseText, true);
				}
			});
		};

		// privileged functions
		this.cancel = function(event, params)
		{
			params.dlg.cancel();
		};

		this.sendWithAjax = function (event, params)
		{
			//var curr_page = params.curr_page;
			var url = params.destination;
			var dlg = params.dlg;

			dlg.setFlash('Updating Exhibit\'s Author...', false);
			var data = dlg.getAllData();
			data.exhibit_id = exhibit_id;
			data.page_num = page_num;

			new Ajax.Updater(page_id, url, {
				parameters : data,
				evalScripts : true,
				onSuccess : function(resp) {
					dlg.cancel();
				},
				onFailure : function(resp) {
					dlg.setFlash(resp.responseText, true);
				}
			});
		};

		var dlgLayout = {
				page: 'choose_objects',
				rows: [
					[ { text: 'Select the user that you wish to impersonate', klass: 'new_exhibit_instructions' } ],
					[ { select: 'user_id', klass: 'user_alias_select', options: [ { value: -1, text: 'Loading user names. Please Wait...' } ] } ],
					[ { button: 'Ok', url: url_update_alias, callback: this.sendWithAjax }, { button: 'Cancel', callback: this.cancel } ]
				]
			};

		var params = { this_id: "set_exhibit_author_alias_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Choose Objects for Exhibit" };
		dlg = new GeneralDialog(params);
		dlg.changePage('choose_objects', null);
		dlg.center();
		populate(dlg);
	}
});


