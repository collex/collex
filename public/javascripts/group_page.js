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
	initialize: function (group_id, current_url, controller) {
		this.class_type = 'EditGroupThumbnailDlg';	// for debugging
		var This = this;
		var dlg = null;
		
		var sendWithAjax = function (event, params)
		{
			editGroupThumbnailDlg = This;
			//var curr_page = params.curr_page;
			var url = params.destination;

			dlg.setFlash('Editing ' + controller.toLowerCase() + ' thumbnail...', false);

			dlg.submitForm('layout', url);	// we have to submit the form normally to get the uploaded file transmitted.
		};

		this.fileUploadError = function(errMessage) {
			dlg.setFlash(errMessage, true);
		};

		this.fileUploadFinished = function(id) {
			dlg.setFlash(controller + ' thumbnail updated...', false);
			window.location.reload(true);
		};
		var show = function () {
			var layout = {
					page: 'layout',
					rows: [
						[ { text: 'Thumbnail:', klass: 'groups_label' }, { image: 'image', size: '37', value: current_url }, { hidden: 'id', value: group_id } ],
						[ { rowClass: 'last_row' }, { button: 'Update Thumbnail', url: "/" + controller.toLowerCase() + "s/edit_thumbnail", callback: sendWithAjax }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
					]
				};

			var params = { this_id: "edit_group_thumbnail", pages: [ layout ], body_style: "new_group_div", row_style: "new_exhibit_row", title: "Edit " + controller + " Thumbnail" };
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

var ClusterNewPost = Class.create({
	initialize: function (progress_img, group_id, group_name, cluster_id, cluster_name, is_logged_in) {

		new ForumReplyDlg({ group_id: group_id, group_name: group_name,
			cluster_id: cluster_id, cluster_name: cluster_name,
			submit_url: '/forum/post_comment_to_new_thread',
			populate_exhibit_url: '/forum/get_exhibit_list',
			populate_nines_obj_url: '/forum/get_nines_obj_list',
			populate_topics_url: '/forum/get_all_topics',
			progress_img: progress_img,
			logged_in: is_logged_in,
			addTopicToLoginRedirect: false,
			redirect: '/clusters/' + cluster_id
		});
	}
});

var GridDlg = Class.create({
	initialize: function (params) {
		this.class_type = 'GridDlg';	// for debugging

		var title = params.title;
		var hidden_id = params.hidden_id;
		var hidden_value = params.hidden_value;
		var url = params.url;
		var fields = params.fields;
		var data = params.data;
		var extraCtrl = params.extraCtrl;

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
						[ { text: 'grid', id: 'membership_data_grid' } ]
					]
				};
				if (hidden_id !== undefined) {
					layout.rows[0].push({ hidden: hidden_id, value: hidden_value });
				}
				if (extraCtrl !== undefined) {
					layout.rows.push(extraCtrl);
				}

			layout.rows.push([{ rowClass: 'last_row' }, { button: 'Save', url: url, callback: sendWithAjax, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback }]);

			var params = { this_id: "new_group_wizard", pages: [ layout ], body_style: "edit_group_membership_div", row_style: "new_exhibit_row", title: title };
			dlg = new GeneralDialog(params);
			dlg.changePage('layout', null);
			initDataGrid({ element_id: "membership_data_grid", paginator_id: "membership_pagination", fields: fields, data: data });
			dlg.center();

			return;
		};

		show();
	}
});

var EditMembershipDlg = Class.create({
	initialize: function (group_id, membership, show_membership) {
		this.class_type = 'EditMembershipDlg';	// for debugging

		var membership2 = [];

		membership.each(function(member) {
			var checked = member.role === 'editor' ? ' checked="true"' : '';
			membership2.push({ Name: member.name,
				"Editor?": '<input id="group_'+member.id+'_editor" type="checkbox" value="1" name="group['+member.id+'[editor]]"'+checked+'/>',
				Delete: '<input id="group_'+member.id+'_delete" type="checkbox" value="1" name="group['+member.id+'[delete]]"/>'
			});
		});

		var showMembershipCtrl = [{ text: 'Show Membership List: '}, { select: 'show_membership', klass: 'select_dlg_input', options: [ { text: "Yes", value: "Yes"}, { text: "No", value: "No"}], value: show_membership }];
		new GridDlg({ title: "Change Membership", hidden_id: 'id', hidden_value: group_id, url: 'edit_membership', fields: ["Name","Editor?", "Delete"], data: membership2, extraCtrl: showMembershipCtrl })
	}
});

var RespondToRequestDlg = Class.create({
	initialize: function (group_id, pendingRequests) {
		this.class_type = 'RespondToRequestDlg';	// for debugging

		var membership2 = [];

		pendingRequests.each(function(member) {
			membership2.push({ Name: member.user_name,
				"No Action": '<input id="group_'+member.group_id+'_noaction" type="radio" value="no_action" checked="checked" name="group['+member.group_id+']"'+'/>',
				"Accept": '<input id="group_'+member.group_id+'_accept" type="radio" value="accept" name="group['+member.group_id+']"'+'/>',
				"Deny": '<input id="group_'+member.group_id+'_deny" type="radio" value="deny" name="group['+member.group_id+']"/>'
			});
		});

		new GridDlg({ title: "Respond", hidden_id: 'id', hidden_value: group_id, url: 'pending_requests', fields: ["Name","No Action", "Accept", "Deny"], data: membership2 })
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

var editDescription = function(id, value, controller) {
	new TextAreaInputDlg({
		title: 'Edit Description',
		prompt: 'Description',
		id: controller + '[description]',
		okStr: 'Save',
		value: value,
		extraParams: { id: id },
		actions: [ '/' + controller + 's/update' ],
		target_els: [ controller + '_details' ] });
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

//var editShowMembership = function(id, value) {
//	new SelectInputDlg({
//		title: 'Change Membership Visibility',
//		prompt: 'Visibility',
//		id: 'group[show_membership]',
//		options:  [ { text: "Yes", value: "Yes"}, { text: "No", value: "No"}],
//		explanation: [ "The profiles of members of this group will be visible to other members of this group", "The profiles of members of this group will only be visible to the editors of this group"],
//		okStr: 'Save',
//		value: value,
//		extraParams: { id: id },
//		actions: [ '/groups/update' ],
//		target_els: [ 'group_details' ] });
//};

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

var editTitle = function(id, value, controller) {
	new TextInputDlg({
		title: 'Edit Title',
		prompt: 'Title',
		id: controller + '[name]',
		okStr: 'Save',
		value: value,
		extraParams: { id: id },
		actions: [ '/' + controller + 's/update' ],
		target_els: [ controller + '_details' ] });
};

var moveExhibitToCluster = function(update_url, cluster_id, exhibitOptions, update_el) {
	new SelectInputDlg({
		title: 'Move Exhibit to Cluster',
		prompt: 'Exhibit',
		id: 'exhibit_id',
		options: exhibitOptions,
		okStr: 'Move',
		extraParams: { cluster_id: cluster_id },
		actions: [ update_url, '/groups/group_exhibits_list' ],
		target_els: [ update_el, 'group_exhibits' ] });
};

var removeFromCluster = function(group_id, cluster_id, exhibit_id) {
	ajaxWithProgressDlg(['/clusters/remove_from_cluster', '/groups/group_exhibits_list'], ['cluster_details', 'group_exhibits'],
		{ title: "Removing Exhibit From Cluster", waitMessage: "Please wait...", completeMessage: 'The exhibit is now back in the group\'s list.' },
		{group_id: group_id, cluster_id: cluster_id, exhibit_id: exhibit_id });
};

var request_to_join = function(group_id, user_id) {
	ajaxWithProgressDlg(['/groups/request_join'], ['group_details'],
		{ title: "Request To Join Group", waitMessage: "Please wait...", completeMessage: 'A request to join this group is pending acceptance by the moderator.' },
		{group_id: group_id, user_id: user_id });
};

//var accept_request = function(id) {
//	ajaxWithProgressDlg(['/groups/accept_request'], ['group_details'],
//		{ title: "Updating Group Membership", waitMessage: "Please wait...", completeMessage: 'The user is now a member of the group.' },
//		{id: id });
//};
//
//var decline_request = function(id) {
//	ajaxWithProgressDlg(['/groups/decline_request'], ['group_details'],
//		{ title: "Updating Group Membership", waitMessage: "Please wait...", completeMessage: 'The user\'s request to join the group has been denied.' },
//		{id: id });
//};

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

var acceptAsPeerReviewed = function(exhibit_id, clusterOptions) {
	clusterOptions.unshift({text: "(None)", value: "0" });
	new SelectInputDlg({
		title: 'Accept As Peer Reviewed',
		prompt: 'Choose a cluster that this exhibit should appear under:',
		id: 'exhibit[cluster_id]',
		options: clusterOptions,
		okStr: 'Save',
		extraParams: { exhibit_id: exhibit_id, "exhibit[is_published]": '1' },
		actions: [ '/groups/accept_as_peer_reviewed' ],
		target_els: [ 'group_exhibits' ] });
//	ajaxWithProgressDlg(['/groups/accept_as_peer_reviewed'], ['group_exhibits'],
//		{ title: "Accept As Peer Reviewed", waitMessage: "Please wait...", completeMessage: 'The exhibit has been accepted.' },
//		{exhibit_id: exhibit_id });
};

var unpublishExhibit = function(exhibit_id) {
	ajaxWithProgressDlg(['/groups/unpublish_exhibit'], ['group_exhibits'],
		{ title: "Unpublish Exhibit", waitMessage: "Please wait...", completeMessage: 'This exhibit has be set to "Private".' },
		{exhibit_id: exhibit_id });
};

var rejectAsPeerReviewed = function(exhibit_id) {
	ajaxWithProgressDlg(['/groups/reject_as_peer_reviewed'], ['group_exhibits'],
		{ title: "Reject As Peer Reviewed", waitMessage: "Please wait...", completeMessage: 'The exhibit has been rejected.' },
		{exhibit_id: exhibit_id });
};

var newClusterDlg = null;
function stopNewClusterUpload(errMessage){
	if (errMessage.startsWith('OK:'))
		newClusterDlg.fileUploadFinished(errMessage.substring(3));
	else
		newClusterDlg.fileUploadError(errMessage);
	return true;
}

var CreateNewClusterDlg = Class.create({
	initialize: function (create_url, group_id, group_name, update_url, update_el) {
		this.class_type = 'CreateNewClusterDlg';	// for debugging

		// private variables
		var This = this;
		var dlg = null;

		// private functions

		var sendWithAjax = function (event, param)
		{
			// Validation
			dlg.setFlash("", false);
			var data = dlg.getAllData();
			if (data['cluster[name]'].strip().length === 0) {
				dlg.setFlash("Please enter a name for this cluster before continuing.", true);
				return;
			}

			newClusterDlg = This;
			dlg.setFlash('Verifying cluster creation...', false);
			dlg.getAllData();
			
			dlg.submitForm('layout', create_url);	// we have to submit the form normally to get the uploaded file transmitted.
		};

		this.fileUploadError = function(errMessage) {
			dlg.setFlash(errMessage, true);
		};

		this.fileUploadFinished = function(id) {
			dlg.setFlash('Cluster created...', false);
			var onSuccess = function(resp) {
				dlg.cancel();
			};
			updateWithAjax({ el: update_el, action: update_url, params: { id: group_id }, onSuccess: onSuccess });
		};

		// privileged methods
		var show = function () {
			var layout = {
					page: 'layout',
					rows: [
						[ { text: 'Creating New Cluster in the Group \"'+ group_name + "\"", klass: 'new_exhibit_title' }, { hidden: 'cluster[group_id]', value: group_id } ],
						[ { text: 'Title:', klass: 'groups_label' }, { input: 'cluster[name]', klass: 'new_exhibit_input_long' } ],
						[ { text: 'Description:', klass: 'groups_label' }, { textarea: 'cluster[description]', klass: 'groups_textarea' } ],
						[ { text: 'Thumbnail:', klass: 'groups_label' }, { image: 'image', size: '37' } ],
						[ { rowClass: 'last_row' }, { button: 'Create Cluster', url: create_url, callback: sendWithAjax, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
					]
				};

			var params = { this_id: "new_cluster_wizard", pages: [ layout ], body_style: "new_cluster_div", row_style: "new_exhibit_row", title: "Create New Cluster" };
			dlg = new GeneralDialog(params);
			dlg.changePage('layout', "cluster_name");
			dlg.center();

			return;
		};
		
		show();
	}
});
