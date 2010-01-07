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

/*global Class, Element, Ajax, $ */
/*global GeneralDialog, CreateListOfObjects, MessageBoxDlg */
/*extern BrowseGroupsDlg */


var BrowseGroupsDlg = Class.create({
	initialize: function (progress_img, url_get_objects, el_id) {
		// This puts up a modal dialog that allows the user to select the objects to be in this exhibit.
		this.class_type = 'BrowseGroupsDlg';	// for debugging

		var dlg = null;
		var selectionCallBack = function(selection) {
			dlg.setFlash("Fetching group. Please wait...", false);
			var arr = selection.split('_');
			window.location = '/groups/'+arr[1];
		};

		// private variables
		//var This = this;
		var oGroups = new CreateListOfObjects(url_get_objects, null, 'all_groups', progress_img, selectionCallBack);

		// private functions

		// privileged functions

		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { text: 'Select a group to get more information.', klass: 'new_exhibit_instructions' } ],
					[ { custom: oGroups } ],
					[ { rowClass: 'last_row' }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
				]
			};

		var params = { this_id: "group_list_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Go To Group" };
		dlg = new GeneralDialog(params);
		dlg.changePage('layout', null);
		dlg.center();
		oGroups.populate(dlg);
	}
});
