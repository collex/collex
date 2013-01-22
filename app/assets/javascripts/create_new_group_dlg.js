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

/*global $, $$, Class */
/*global GeneralDialog, serverRequest, submitForm, gotoPage */
/*global LinkDlgHandler */
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
	initialize: function (auto_complete_url, owner_id, url_verify_group, create_url, destination_url, types, permissions, visibility, defaultType, siteName, populate_urls, progress_img, start_university, start_name, membershipExample) {
		this.class_type = 'CreateGroupWizardDlg';	// for debugging
		
		// private variables
		var This = this;
		var dlg = null;

		// private functions

		var changeView = function (event, param)
		{
			var curr_page = param.curr_page;
			var view = param.arg0;

			// Validation
			dlg.setFlash("", false);
			if (curr_page === 'group_properties')	// We are on the first page. The user must enter a title before leaving the page.
			{
				var data = dlg.getAllData();
				if (data['group[name]'].strip().length === 0) {
					dlg.setFlash("Please enter a name for this group before continuing.", true);
					return false;
				}
				if (data['group[group_type]'] === 'classroom') {
					// There are required fields for classroom groups
					if (data['group[university]'].strip().length === 0) {
						dlg.setFlash("Please enter a university for this classroom group before continuing.", true);
						return false;
					}
					if (data['group[course_name]'].strip().length === 0) {
						dlg.setFlash("Please enter a course name for this classroom group before continuing.", true);
						return false;
					}
					if (data['group[course_mnemonic]'].strip().length === 0) {
						dlg.setFlash("Please enter a course mnemonic for this classroom group before continuing.", true);
						return false;
					}
				}
				data['group[owner]'] = owner_id;
				dlg.setFlash("Verifying title. Please wait...", false);
				var onSuccess = function(resp) {
						dlg.setFlash('', false);
						dlg.changePage(view, null);
					};
				serverRequest({ url: url_verify_group, params: { name: data['group[name]'].strip() }, onSuccess: onSuccess});
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

		var toggle = function(els, show) {
			if (show) {
				els.each(function(el) { el.removeClassName('hidden'); });
			} else {
				els.each(function(el) { el.addClassName('hidden'); });
			}
		};

		var typeSelect = function(id, currSelection) {
			// Automatically set the class name to the group name if this is a classroom group.
			// But don't overwrite the user's typing, so be sure it's empty first.
			if (currSelection === 'classroom') {
				var elGroup = $('group_course_name');
				if (elGroup.value.length === 0) {
					var elTitle = $('group_name');
					var title = elTitle.value;
					elGroup.value = title;
				}
			}
			var els = $$('.community_only');
			toggle(els, currSelection === 'community');
			els = $$('.classroom_only');
			toggle(els, currSelection === 'classroom');
			els = $$('.publication_only');
			toggle(els, currSelection === 'peer-reviewed');
		};

		var sendWithAjax = function (event, params)
		{
			newGroupDlg = This;
			//var curr_page = params.curr_page;
			var url = params.arg0;

			dlg.setFlash('Verifying group creation...', false);
			var data = dlg.getAllData();
			$('emails').value = data.emails_entry;
			$('usernames').value = data.usernames_entry;
			
			submitForm('group_properties', url);	// we have to submit the form normally to get the uploaded file transmitted.
		};

		this.fileUploadError = function(errMessage) {
			dlg.setFlash(errMessage, true);
		};

		this.fileUploadFinished = function(id) {
			dlg.setFlash('Group created...', false);
			gotoPage(destination_url + id);
		};

		// privileged methods
		var show = function () {
		   
			var group_properties = {
					page: 'group_properties',
					rows: [
						[ { text: 'Creating New Group', klass: 'new_exhibit_title' }, { hidden: 'group[owner]', value: owner_id }, { hidden: 'emails', value: '' }, { hidden: 'usernames', value: '' } ],
						[ { text: 'Step 1: Group Information', klass: 'new_exhibit_label' } ],
						[ { text: 'Title:', klass: 'groups_label' }, { input: 'group[name]', klass: 'new_exhibit_input_long' } ],
						[ { text: 'Description:', klass: '' } ],
						[ { textarea: 'group[description]', klass: 'description groups_textarea' } ],
						[ { picture: membershipExample, klass: 'new_group_membership_pic' }, { text: 'Show Membership:', klass: 'groups_label' }, { select: 'group[show_membership]', options: [ { text: "To All", value: 'Yes'}, { text: "To Admins", value: 'No'}] },
							{ text: "Choose whether visitors to your group will be able to see the membership list displayed at the upper-right of your group page.", klass: 'new_group_membership_explanation'}],
						[ { rowClass: 'clear_both' }, { text: 'Type:', klass: 'new_group_type_label' }, { select: 'group[group_type]', klass: 'new_group_type', options: types, value: defaultType, callback: typeSelect },
							{ text: 'The ' + siteName + ' default group type, useful for sharing objects and forum threads.', klass: 'new_group_membership_explanation community_only'},
							{ text: 'Groups for using ' + siteName + ' in the classroom.', klass: 'new_group_membership_explanation hidden classroom_only'},
							{ text: '&nbsp;', klass: 'new_group_membership_explanation hidden publication_only'}
						],
						[ { rowClass: 'clear_both' }, { text: 'Thumbnail:', klass: 'groups_label hidden xcommunity_only' },  { image: 'image', size: '37', removeButton: 'Remove Thumbnail', klass: 'hidden xcommunity_only' },
							{ text: 'Publication groups work closely with the ' + siteName + ' staff to vet their content. If you select this option a notification will be sent to the ' + siteName + ' staff, and someone will be in contact with you soon.', klass: 'new_group_membership_explanation publication_only hidden'},
							{ text: 'Course Mnemonic:', klass: 'groups_label classroom_only hidden' }, { text: 'For easy browsing, use this field to share the course number or mnemonic associated with this class (e.g. ENNC 448).', klass: 'groups_explanation classroom_only hidden' },
							{ input: 'group[course_mnemonic]', klass: 'new_exhibit_input_long classroom_only hidden' }
						],
						[ { text: 'Course Name (if different from Group Title):', klass: 'classroom_only hidden' }, { input: 'group[course_name]', klass: 'new_exhibit_input_long classroom_only hidden' } ],
						[ { text: 'University:', klass: 'groups_label classroom_only hidden' }, { autocomplete: 'group[university]', klass: 'new_exhibit_autocomplete classroom_only hidden', url: auto_complete_url } ],
						[ { rowClass: 'gd_last_row' }, { button: 'Next', arg0: 'invite_members', callback: changeView}, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
					] 
				};

			var invite_members = {
					page: 'invite_members',
					rows: [
						[ { text: 'Creating New Group', klass: 'new_exhibit_title' } ],
						[ { text: 'Step 2: Invite people to your group.', klass: 'new_exhibit_label' } ],
						[ { text: 'There are two ways to invite people to join your group in ' + siteName +
							': email address or username. If you know the participants\' usernames, list them in the blank below, one per line.', klass: 'invite_users_instructions' } ],
						[ { text: 'By Username:', klass: 'invite_users_label' }, { textarea: 'usernames_entry', klass: 'groups_textarea' } ],
						[ { text: "Don't know any usernames? Add email addresses of users you want to invite in the blank below, one per line.", klass: 'invite_users_instructions' } ],
						[ { text: 'By Email Address:', klass: 'invite_users_label' }, { textarea: 'emails_entry', klass: 'groups_textarea' } ],
						[ { rowClass: 'gd_last_row' }, { button: 'Create Group', arg0: create_url, callback: sendWithAjax }, { button: 'Previous', arg0: 'group_properties', callback: changeView }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
					]
				};
			var pages = [ group_properties, invite_members ];

			var params = { this_id: "invite_users_dlg", pages: pages, body_style: "invite_users_div", row_style: "new_exhibit_row", title: "New Group Wizard" };
			dlg = new GeneralDialog(params);
			changeView(null, { curr_page: '', arg0: 'group_properties', dlg: dlg });
			dlg.initTextAreas({ onlyClass: 'description', toolbarGroups: [ 'fontstyle', 'link' ], linkDlgHandler: new LinkDlgHandler([populate_urls], progress_img) });
			typeSelect('group[group_type]', defaultType);
			dlg.center();
		};
		
		show();
	}
});



