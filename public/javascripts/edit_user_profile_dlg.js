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

/*global Class, Ajax */
/*global GeneralDialog */
/*extern EditProfileDialog, editProfileDlg, stopUpload */

var editProfileDlg = null;
function stopUpload(){
	editProfileDlg.fileUploadFinished();
	return true;
}

var EditProfileDialog = Class.create({
	initialize: function (parent_div, ok_action, user_shell, curr_image_src) {
		// This puts up a modal dialog that allows the administrator to change information about a site or category.
		this.class_type = 'EditProfileDialog';	// for debugging

		// private variables
		var This = this;
		var user = user_shell.user;
		var dlg = null;

		// private functions

		// privileged functions
		this.cancel = function(event, params)
		{
			params.dlg.cancel();
		};

		this.sendWithAjax = function (event, params)
		{
			dlg = params.dlg;
			dlg.setFlash('Updating User Profile...', false);
			editProfileDlg = This;

			// This is complicated by the file upload. That can't be done in Ajax because security doesn't let javascript manipulate file data.
			// Therefore, we we submit the file with a normal html submit, then when that is completed, we do the ajax update.
			//var thumb = $('image');
			//var form = thumb.up('form');
			dlg.submitForm('layout', ok_action + "_upload");	// we have to submit the form normally to get the uploaded file to get transmitted.
		};

		this.fileUploadFinished = function() {
			var data = dlg.getAllData();
			new Ajax.Updater(parent_div, ok_action, {
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
				page: 'layout',
				rows: [
					[ { text: 'User Name:', klass: 'edit_facet_label' }, { text: user.username, klass: 'new_exhibit_label' } ],
					[ { text: 'Full Name:', klass: 'edit_facet_label' }, { input: 'fullname', value: user.fullname, klass: 'edit_facet_input' } ],
					[ { text: 'Email:', klass: 'edit_facet_label' }, { input: 'account_email', value: user.email, klass: 'edit_facet_input' } ],
					[ { text: 'Institution:', klass: 'edit_facet_label' }, { input: 'institution', value: user.institution, klass: 'edit_facet_input' } ],
					[ { text: 'Link:', klass: 'edit_facet_label' }, { input: 'link', value: user.link, klass: 'edit_facet_input' } ],
					[ { text: '(leave blank if not changing your password)', klass: 'login_instructions' } ],
					[ { text: 'Password:', klass: 'edit_facet_label' }, { password: 'account_password', klass: 'edit_facet_input' } ],
					[ { text: 'Re-type password:', klass: 'edit_facet_label' }, { password: 'account_password2', klass: 'edit_facet_input' } ],
					[ { text: 'About me:', klass: 'edit_facet_label' }, { textarea: 'aboutme', value: user.about_me, klass: 'edit_profile_textarea' } ],
					[ { text: 'Thumbnail:', klass: 'edit_facet_label' }, { image: 'image', klass: 'edit_profile_image', size: 35, value: curr_image_src } ],
					[ { rowClass: 'last_row' }, { button: 'Ok', url: ok_action, callback: this.sendWithAjax }, { button: 'Cancel', callback: this.cancel } ]
				]
			};

		var params = { this_id: "edit_profile_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Edit Profile" };
		dlg = new GeneralDialog(params);
		dlg.changePage('layout', null);
		dlg.center();
	}
});