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

/*global $, Class */
/*global window */
/*global GeneralDialog, ObjectSelector, CreateListOfObjects, serverRequest, gotoPage */
/*extern CreateNewExhibitWizard */

var createNewExhibitDlg = null;
function stopCreateNewExhibitUpload(errMessage){
	if (errMessage.startsWith('OK:'))
		createNewExhibitDlg.fileUploadFinished(errMessage.substring(3));
	else
		createNewExhibitDlg.fileUploadError(errMessage);
	return true;
}

var CreateNewExhibitWizard = Class.create({
	initialize: function (params) {
		this.class_type = 'CreateNewExhibitWizard';	// for debugging
		var progress_img = params.progress_img;
		var url_get_objects = params.url_get_objects;
		var populate_collex_obj_url = params.populate_collex_obj_url;
		var group_id = params.group_id;
		var cluster_id = params.cluster_id;
		var import_url = params.import_url;
		var exhibit_label = params.exhibit_label ? params.exhibit_label : "Exhibit";

		// private variables
		var This = this;
		var obj_selector = new ObjectSelector(progress_img, url_get_objects, -1, exhibit_label);
		var dlg = null;

		// private functions

		this.changeView = function (event, param)
		{
			var curr_page = param.curr_page;
			var view = param.arg0;
			var dlg = param.dlg;

			// Validation
			dlg.setFlash("", false);
			if (curr_page === 'choose_title')	// We are on the first page. The user must enter a title before leaving the page.
			{
				var data = dlg.getAllData();
				if (data.exhibit_title.strip().length === 0) {
					dlg.setFlash("Please enter a name for this " + exhibit_label.toLowerCase() + " before continuing.", true);
					return false;
				}
				dlg.setFlash("Verifying title. Please wait...", false);
				var onSuccess = function(resp) {
					dlg.setFlash('', false);
					$('exhibit_url').value = resp.responseText;
					dlg.changePage(view, null);
				};
				serverRequest({ url: '/builder/verify_title', params: { title: data.exhibit_title.strip() }, onSuccess: onSuccess});
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

		this.fileUploadError = function(errMessage) {
			dlg.changePage('choose_title', 'document');
			dlg.setFlash(errMessage, true);
		};

		this.fileUploadFinished = function(url) {
			dlg.setFlash('', false);
			gotoPage(url);
		};

		this.sendWithAjax = function (event, params)
		{
			createNewExhibitDlg = This;
			//var curr_page = params.curr_page;
			var url = params.arg0;
			dlg = params.dlg;

			dlg.setFlash('Verifying ' + exhibit_label.toLowerCase() +' parameters...', false);
			var data = dlg.getAllData();
			data.objects = obj_selector.getSelectedObjects().join('\t');
			if (group_id)
				data.group_id = group_id;
			if (cluster_id)
				data.cluster_id = cluster_id;

			var onSuccess = function(resp) {
					dlg.setFlash('Creating ' + exhibit_label + '...', false);
					var elId = $('exhibit_id');
					elId.value = resp.responseText;
					submitForm('choose_title', import_url);	// we have to submit the form normally to get the uploaded file to get transmitted.
//					gotoPage("/builder/" + resp.responseText);
				};
			serverRequest({ url: url, params: data, onSuccess: onSuccess});
		};

		// privileged methods
		this.show = function () {
			var help = '<span class="tooltip"><img src="/assets/help_thumb.sm.gif" alt="help" /><span class="group_help_tooltip">This is the title that will show up in the '+exhibit_label.toLowerCase()+' list once you decide to share it with other users. You can edit this later by selecting Edit '+exhibit_label+' Profile at the top of your '+exhibit_label.toLowerCase()+' editing page.</span></span>';
			var choose_title = {
					page: 'choose_title',
					rows: [
						[ { text: 'Creating New '+exhibit_label, klass: 'new_exhibit_title' } ],
						[ { text: 'Step 1: Please choose a title for your new '+exhibit_label.toLowerCase()+'. ' + help, klass: 'new_exhibit_label' } ],
						[ { input: 'exhibit_title', klass: 'new_exhibit_input_long' } ],
						[ { text: 'Already have a working document?', klass: 'new_exhibit_title' } ],
						[ { text: 'Try out the new uploader for Microsoft Word (.docx) files.', klass: 'new_exhibit_label' } ],
						[ { file: 'document', size: 40}, { hidden: 'exhibit_id' } ],
						[ { rowClass: 'gd_last_row' }, { button: 'Next', arg0: 'choose_palette', callback: this.changeView, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
					]
				};

			var choose_palette = {
					page: 'choose_palette',
					rows: [
						[ { text: 'Creating New '+exhibit_label, klass: 'new_exhibit_title' } ],
						[ { text: 'Step 2: Add objects to your '+exhibit_label.toLowerCase()+'.  (optional)', klass: 'new_exhibit_label' } ],
						[ { text: 'Choose resources from your collected objects to add to this new '+exhibit_label.toLowerCase()+'.', klass: 'new_exhibit_instructions' } ],
						[ { custom: obj_selector } ],
						[ { text: 'Any object you have collected is available for use in your '+exhibit_label.toLowerCase()+'. You may add or remove objects from this list at any time.', klass: 'new_exhibit_instructions' } ],
						[ { rowClass: 'gd_last_row' }, { button: 'Next', arg0: 'choose_other_options', callback: this.changeView, isDefault: true }, { button: 'Previous', arg0: 'choose_title', callback: this.changeView }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
					]
				};

			// Get the current server location.
			var server = window.location;
			server = 'http://' + server.host;

			var choose_other_options = {
					page: 'choose_other_options',
					rows: [
						[ { text: 'Creating New '+exhibit_label, klass: 'new_exhibit_title' } ],
						[ { text: 'Step 3: Additional options', klass: 'new_exhibit_label' } ],
						[ { text: 'Choose a url for your '+exhibit_label.toLowerCase()+':', klass: 'new_exhibit_label' } ],
						[ { text: server + '/exhibits/&nbsp;', klass: 'new_exhibit_label' }, { input: 'exhibit_url', klass: 'new_exhibit_input' } ],
						[ { text: 'Paste a link to a thumbnail image:', klass: 'new_exhibit_label' } ],
						[ { input: 'exhibit_thumbnail', klass: 'new_exhibit_input_long' } ],
						[ { link: '[Choose thumbnail from collected objects]', klass: 'nav_link', callback: this.changeView, arg0: 'choose_thumbnail' }],
						[ { text: 'The thumbnail image will appear next to your '+exhibit_label.toLowerCase()+' in the exhibit list once you decide to share it with other users. Please use an image that is small, so that the pages doesn\'t take too long to load. These items are optional and can be entered at any time.', klass: 'new_exhibit_instructions' } ],
						[ { rowClass: 'gd_last_row' }, { button: 'Create '+exhibit_label, arg0: '/builder', callback: this.sendWithAjax, isDefault: true }, { button: 'Previous', arg0: 'choose_palette', callback: this.changeView }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
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
						[ { text: 'Creating New '+exhibit_label, klass: 'new_exhibit_title' } ],
						[ { text: 'Sort objects by:', klass: 'forum_reply_label' },
							{ select: 'sort_by', callback: objlist.sortby, klass: 'link_dlg_select', value: 'date_collected', options: [{ text:  'Date Collected', value:  'date_collected' }, { text:  'Title', value:  'title' }, { text:  'Author', value:  'author' }] },
							{ text: 'and', klass: 'link_dlg_label_and' }, { inputFilter: 'filterObjects', klass: '', prompt: 'type to filter objects', callback: objlist.filter } ],
						[ { custom: objlist, klass: 'new_exhibit_label' } ],
						[ { rowClass: 'gd_last_row' }, { button: 'Ok', arg0: 'choose_other_options', callback: this.changeView, isDefault: true }, { button: 'Cancel', arg0: 'choose_other_options', callback: cancelThumbnail } ]
					]
				};

			var pages = [ choose_title, choose_palette, choose_other_options, choose_thumbnail ];

			var params = { this_id: "new_exhibit_wizard", pages: pages, body_style: "new_exhibit_div", row_style: "new_exhibit_row", title: "New " +exhibit_label+" Wizard" };
			var dlg = new GeneralDialog(params);
			this.changeView(null, { curr_page: '', arg0: 'choose_title', dlg: dlg });
			dlg.center();
			obj_selector.populate(dlg);
			objlist.populate(dlg, false, 'thumb');
		};
	}
});

/*function importExhibit(url) {

	var onOk = function(event, params) {
		var ok_action = params.arg0;
		var dlg = params.dlg;

		dlg.setFlash("Importing file...", false);

		submitForm('layout', ok_action);	// we have to submit the form normally to get the uploaded file to get transmitted.
	};

	this.fileUploadError = function(errMessage) {
		dlg.setFlash(errMessage, true);
	};

	this.fileUploadFinished = function() {
		dlg.cancel();
	};

	var layout = {
			page: 'layout',
			rows: [
				[ { text: 'Import Exhibit From Word File (.docx)', klass: 'new_exhibit_title' } ],
				[ { text: 'Title of Exhibit:', klass: 'new_exhibit_label' }, { input: 'exhibit_title', klass: 'new_exhibit_input_long' } ],
				[ { text: 'This is the title that will show up in the exhibit list once you decide to share it with other users. You can edit this later by selecting Edit Exhibit Profile at the top of your exhibit editing page.', klass: 'new_exhibit_instructions' } ],
				[ { file: 'document', size: 40, no_iframe: true } ],
				[ { rowClass: 'gd_last_row' }, { button: 'Import', arg0: url, callback: onOk, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
			]
		};
	var params = { this_id: "new_exhibit_wizard", pages: [ layout ], body_style: "new_exhibit_div", row_style: "new_exhibit_row", title: "Import Exhibit" };
	var dlg = new GeneralDialog(params);
	dlg.center();
}*/

