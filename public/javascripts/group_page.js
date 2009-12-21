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
/*global GeneralDialog, TextAreaInputDlg, SelectInputDlg */
/*global window */
/*global ForumReplyDlg */
/*extern EditGroupThumbnailDlg, EditMembershipDlg, GroupNewPost, InviteMembersDlg, editDescription, editGroupThumbnailDlg, editLicense, editPermissions, editType, stopEditGroupThumbnailUpload */

var editGroupThumbnailDlg = null;
function stopEditGroupThumbnailUpload(errMessage){
	if (errMessage.startsWith('OK:'))
		editGroupThumbnailDlg.fileUploadFinished(errMessage.substring(3));
	else
		editGroupThumbnailDlg.fileUploadError(errMessage);
	return true;
}

var EditGroupThumbnailDlg = Class.create({
	initialize: function (group_id, current_url) {
		this.class_type = 'EditGroupThumbnailDlg';	// for debugging
		var This = this;
		var dlg = null;
		
		var sendWithAjax = function (event, params)
		{
			editGroupThumbnailDlg = This;
			//var curr_page = params.curr_page;
			var url = params.destination;

			dlg.setFlash('Editing group thumbnail...', false);

			dlg.submitForm('layout', url);	// we have to submit the form normally to get the uploaded file transmitted.
		};

		this.fileUploadError = function(errMessage) {
			dlg.setFlash(errMessage, true);
		};

		this.fileUploadFinished = function(id) {
			dlg.setFlash('Group thumbnail updated...', false);
			window.location.reload(true);
		};
		var show = function () {
			var layout = {
					page: 'layout',
					rows: [
						[ { text: 'Thumbnail:', klass: 'groups_label' }, { image: 'image', size: '37', value: current_url }, { hidden: 'id', value: group_id } ],
						[ { rowClass: 'last_row' }, { button: 'Update Thumbnail', url: "/groups/edit_thumbnail", callback: sendWithAjax }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
					]
				};

			var params = { this_id: "edit_group_thumbnail", pages: [ layout ], body_style: "new_group_div", row_style: "new_exhibit_row", title: "Edit Group Thumbnail" };
			dlg = new GeneralDialog(params);
			dlg.changePage('layout', null);
			dlg.center();

			return;
		};

		show();
	}
});

var GroupNewPost = Class.create({
	initialize: function (progress_img, group_id, group_name, is_logged_in) {

		new ForumReplyDlg({ group_id: group_id, group_name: group_name,
			submit_url: '/forum/post_comment_to_new_thread',
			populate_exhibit_url: '/forum/get_exhibit_list',
			populate_nines_obj_url: '/forum/get_nines_obj_list',
			populate_topics_url: '/forum/get_all_topics',
			progress_img: progress_img,
			logged_in: is_logged_in,
			addTopicToLoginRedirect: false,
			redirect: '/groups/' + group_id
		});
	}
});

var EditMembershipDlg = Class.create({
	initialize: function (group_id, membership) {
		this.class_type = 'EditMembershipDlg';	// for debugging

		var initDataGrid = function(params) {
			var element_id = params.element_id;
			var parent = $(element_id).up();
			$(element_id).remove();
			parent.appendChild(new Element('div', { id: element_id }));

			var fields = params.fields;
			var data = params.data;
			var paginator_id = params.paginator_id;
			parent = $(paginator_id).up();
			$(paginator_id).remove();
			parent.appendChild(new Element('div', { id: paginator_id }));
			var highlight = params.highlight;
			var initialPage = parseInt("" + (highlight/10+1));

			var columnDefs = [];
			fields.each(function(field) {
				columnDefs.push({ key: field, sortable: false, resizable: true });
			});

			var dataSource = new YAHOO.util.DataSource(data);
			dataSource.responseType = YAHOO.util.DataSource.TYPE_JSARRAY;
			dataSource.responseSchema = { fields: fields };
			var oConfigs = {  };
			if (data.length > 10) {
				oConfigs.paginator = new YAHOO.widget.Paginator({
					rowsPerPage: 10,
					containers: paginator_id,
					template : "{PreviousPageLink} <strong>{CurrentPageReport}</strong> {NextPageLink}"
				});
			}
			var dataTable = new YAHOO.widget.DataTable(element_id,
					columnDefs, dataSource, oConfigs);
			if (oConfigs.paginator && highlight)
				oConfigs.paginator.setPage(initialPage, false);
			if (highlight)
				dataTable.selectRow(highlight);

			return {
				oDS: dataSource,
				oDT: dataTable
			};
		};

		var dlg = null;

		var sendWithAjax = function (event, params)
		{
			var onSuccess = function(resp) {
					dlg.cancel();
			};
			var onFailure = function(resp) {
				dlg.setFlash(resp.responseText, true);
			};
			var data = dlg.getAllData();
			var url = params.destination;
			recurseUpdateWithAjax([url], ['group_details'], onSuccess, onFailure, data);
		};

		var show = function () {
			var layout = {
					page: 'layout',
					rows: [
						[ { text: "paginator", id: "membership_pagination", klass: "pagination"} ],
						[ { text: 'grid', id: 'membership_data_grid' }, { hidden: 'id', value: group_id } ]
					]
				};

			var membership2 = [];

			membership.each(function(member) {
				var checked = member.role === 'editor' ? ' checked="true"' : '';
				membership2.push({ Name: member.name,
					"Editor?": '<input id="group_'+member.id+'_editor" type="checkbox" value="1" name="group['+member.id+'[editor]]"'+checked+'/>',
					Delete: '<input id="group_'+member.id+'_editor" type="checkbox" value="1" name="group['+member.id+'[delete]]"/>'
				});
			});
			layout.rows.push([{ rowClass: 'last_row' }, { button: 'Save', url: 'edit_membership', callback: sendWithAjax, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback }]);

			var params = { this_id: "new_group_wizard", pages: [ layout ], body_style: "edit_group_membership_div", row_style: "new_exhibit_row", title: "Change Membership" };
			dlg = new GeneralDialog(params);
			dlg.changePage('layout', null);
			initDataGrid({ element_id: "membership_data_grid", paginator_id: "membership_pagination", fields: ["Name","Editor?", "Delete"], data: membership2 });
			dlg.center();

			return;
		};

		show();
	}
});

var InviteMembersDlg = Class.create({
	initialize: function (group_id) {
		this.class_type = 'InviteMembersDlg';	// for debugging

		var failureMsg = function(resp) {
			var str = "Some or all of your invitees have not been invited. Please check their email address and try again.<br />" + resp.responseText;
			new MessageBoxDlg("Members Not Invited", str);
		};

		new TextAreaInputDlg({
			title: 'Invite Users to Join',
			prompt: 'Invite new people to join this group.<br />(Enter a list of email addresses, one per line.)',
			pleaseWaitMsg: 'Sending email to invitees. Please wait...',
			id: 'emails',
			okStr: 'Save',
			extraParams: { id: group_id },
			onFailure: failureMsg,
			actions: [ '/groups/update' ],
			target_els: [ 'group_details' ] });	}
});

var editDescription = function(id, value) {
	new TextAreaInputDlg({
		title: 'Edit Description',
		prompt: 'Description',
		id: 'group[description]',
		okStr: 'Save',
		value: value,
		extraParams: { id: id },
		actions: [ '/groups/update' ],
		target_els: [ 'group_details' ] });
};

var editPermissions = function(id, value, groupForumPermissionsOptions, groupForumPermissionsExplanations) {
	new SelectInputDlg({
		title: 'Change Forum Permissions',
		prompt: 'Permissions',
		id: 'group[forum_permissions]',
		options: groupForumPermissionsOptions,
		explanation: groupForumPermissionsExplanations,
		okStr: 'Save',
		value: value,
		extraParams: { id: id },
		actions: [ '/groups/update' ],
		target_els: [ 'group_details' ] });
};

var editShowMembership = function(id, value) {
	new SelectInputDlg({
		title: 'Change Member\'s Visibility',
		prompt: 'Visibility',
		id: 'group[show_membership]',
		options:  [ { text: "Yes", value: "Yes"}, { text: "No", value: "No"}],
		explanation: [ "The profiles of members of this group will be visible to other members of this group", "The profiles of members of this group will only be visible to the editors of this group"],
		okStr: 'Save',
		value: value,
		extraParams: { id: id },
		actions: [ '/groups/update' ],
		target_els: [ 'group_details' ] });
};

var editType = function(id, value, groupTypeOptions) {
	new SelectInputDlg({
		title: 'Edit Group Type',
		prompt: 'Type',
		id: 'group[group_type]',
		options: groupTypeOptions,
		explanation: [ 'This group is being used for scholarly collaboration. File this group under the "Community" section.',
			'This group is being used to teach. File this group under the "Classroom" section.' ],
		okStr: 'Save',
		value: value,
		extraParams: { id: id },
		actions: [ '/groups/update' ],
		target_els: [ 'group_details' ] });
};

var editTitle = function(id, value) {
	new TextInputDlg({
		title: 'Edit Title',
		prompt: 'Group Title',
		id: 'group[name]',
		okStr: 'Save',
		value: value,
		extraParams: { id: id },
		actions: [ '/groups/update' ],
		target_els: [ 'group_details' ] });
};

var request_to_join = function(group_id, user_id) {
	ajaxWithProgressDlg(['/groups/request_join'], ['group_details'],
		{ title: "Request To Join Group", waitMessage: "Please wait...", completeMessage: 'A request to join this group is pending acceptance by the moderator.' },
		{group_id: group_id, user_id: user_id });
};

var accept_request = function(id) {
	ajaxWithProgressDlg(['/groups/accept_request'], ['group_details'],
		{ title: "Updating Group Membership", waitMessage: "Please wait...", completeMessage: 'The user is now a member of the group.' },
		{id: id });
};

var decline_request = function(id) {
	ajaxWithProgressDlg(['/groups/decline_request'], ['group_details'],
		{ title: "Updating Group Membership", waitMessage: "Please wait...", completeMessage: 'The user\'s request to join the group has been denied.' },
		{id: id });
};

var accept_invitation = function(pending_id) {
	ajaxWithProgressDlg(['/groups/accept_invitation'], ['group_details'],
		{ title: "Updating Group Membership", waitMessage: "Please wait...", completeMessage: 'You are now a member of this group.' },
		{id: pending_id });
};

var decline_invitation = function(pending_id) {
	ajaxWithProgressDlg(['/groups/decline_invitation'], ['group_details'],
		{ title: "Updating Group Membership", waitMessage: "Please wait...", completeMessage: 'You have been removed from this group.' },
		{id: pending_id });
};
