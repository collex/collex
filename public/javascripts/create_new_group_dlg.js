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
/*global GeneralDialog */
/*global window */
/*extern CreateGroupWizardDlg, newGroupDlg, stopNewGroupUpload */

var newGroupDlg = null;
function stopNewGroupUpload(errMessage){
	if (errMessage.startsWith('OK:'))
		newGroupDlg.fileUploadFinished(errMessage.substring(3));
	else
		newGroupDlg.fileUploadError(errMessage);
	return true;
}

var CreateGroupWizardDlg = Class.create({
	initialize: function (owner_id, url_verify_group, create_url, destination_url, types, permissions, defaultType) {
		this.class_type = 'CreateGroupWizardDlg';	// for debugging

		// private variables
		var This = this;
		var dlg = null;

		// private functions

		var changeView = function (event, param)
		{
			var curr_page = param.curr_page;
			var view = param.destination;

			// Validation
			dlg.setFlash("", false);
			if (curr_page === 'group_properties')	// We are on the first page. The user must enter a title before leaving the page.
			{
				var data = dlg.getAllData();
				if (data['group[name]'].strip().length === 0) {
					dlg.setFlash("Please enter a name for this group before continuing.", true);
					return false;
				}
				data['group[owner]'] = owner_id;
				dlg.setFlash("Verifying title. Please wait...", false);
				new Ajax.Request(url_verify_group, { method: 'get', parameters: { name: data['group[name]'].strip() },
					onSuccess : function(resp) {
						dlg.setFlash('', false);
						dlg.changePage(view, null);
					},
					onFailure : function(resp) {
						dlg.setFlash(resp.responseText, true);
					}
				});
				return false;
			}

			var focus_el = null;
			switch (view)
			{
				case 'group_properties': focus_el = 'group_name'; break;
				case 'invite_members': focus_el = 'emails'; break;
			}
			dlg.changePage(view, focus_el);

			return false;
		};

		var sendWithAjax = function (event, params)
		{
			newGroupDlg = This;
			//var curr_page = params.curr_page;
			var url = params.destination;

			dlg.setFlash('Verifying group creation...', false);
			var data = dlg.getAllData();
			$('emails').value = data.emails_entry;
			
			dlg.submitForm('group_properties', url);	// we have to submit the form normally to get the uploaded file transmitted.
		};

		this.fileUploadError = function(errMessage) {
			dlg.setFlash(errMessage, true);
		};

		this.fileUploadFinished = function(id) {
			dlg.setFlash('Group created...', false);
			window.location = destination_url + id;
		};

		// privileged methods
		var show = function () {
			var group_properties = {
					page: 'group_properties',
					rows: [
						[ { text: 'Creating New Group', klass: 'new_exhibit_title' }, { hidden: 'group[owner]', value: owner_id }, { hidden: 'emails', value: '' } ],
						[ { text: 'Step 1: Group Information', klass: 'new_exhibit_label' } ],
						[ { text: 'Title:', klass: 'groups_label' }, { input: 'group[name]', klass: 'new_exhibit_input_long' } ],
						[ { text: 'Description:', klass: 'groups_label' }, { textarea: 'group[description]', klass: 'groups_textarea' } ],
						[ { text: 'Thumbnail:', klass: 'groups_label' }, { image: 'image', size: '37' } ],
						[ { text: 'Type:', klass: 'groups_label' }, { select: 'group[group_type]', options: types, value: defaultType } ],
						[ { text: 'Permissions:', klass: 'groups_label' }, { select: 'group[forum_permissions]', options: permissions } ],
						[ { rowClass: 'last_row' }, { button: 'Next', url: 'invite_members', callback: changeView}, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
					]
				};

			var invite_members = {
					page: 'invite_members',
					rows: [
						[ { text: 'Creating New Group', klass: 'new_exhibit_title' } ],
						[ { text: 'Step 2: Invite people to your group.', klass: 'new_exhibit_label' } ],
						[ { text: 'Users:', klass: 'groups_label' }, { textarea: 'emails_entry', klass: 'groups_textarea' } ],
						[ { rowClass: 'last_row' }, { button: 'Create Group', url: create_url, callback: sendWithAjax }, { button: 'Previous', url: 'group_properties', callback: changeView }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
					]
				};

			var pages = [ group_properties, invite_members ];

			var params = { this_id: "new_group_wizard", pages: pages, body_style: "new_group_div", row_style: "new_exhibit_row", title: "New Group Wizard" };
			dlg = new GeneralDialog(params);
			changeView(null, { curr_page: '', destination: 'group_properties', dlg: dlg });
			dlg.center();

			return;
		};
		
		show();
	}
});



