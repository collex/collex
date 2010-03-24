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

/*global $, $$, Class, Element */
/*global YAHOO */
/*global GeneralDialog, SelectInputDlg, recurseUpdateWithAjax, MessageBoxDlg, RteInputDlg, TextInputDlg, ajaxWithProgressDlg, updateWithAjax */
/*global window */
/*global ForumReplyDlg, LinkDlgHandler */
/*extern EditGroupThumbnailDlg, EditMembershipDlg, GroupNewPost, InviteMembersDlg, editDescription, editGroupThumbnailDlg, editPermissions, editType, stopEditGroupThumbnailUpload */
/*extern ClusterNewPost, CreateNewClusterDlg, GridDlg, RespondToRequestDlg, acceptAsPeerReviewed, accept_invitation, changeClusterLabel, changeClusterVisibility, changeExhibitLabel, changeWhichExhibitsAreShown, confirmDlgWithTextArea, decline_invitation, editGroupTextField, editTitle, editURL, editVisibility, hideAdmins, limitExhibit, moveExhibit, moveExhibitToCluster, newClusterDlg, rejectAsPeerReviewed, request_to_join, setNotificationLevel, showAdmins, stopNewClusterUpload, unlimitExhibit, unpublishExhibit */

var editGroupThumbnailDlg = null;
function stopEditGroupThumbnailUpload(errMessage){
	if (errMessage.startsWith('OK:'))
		editGroupThumbnailDlg.fileUploadFinished(errMessage.substring(3));
	else
		editGroupThumbnailDlg.fileUploadError(errMessage);
	return true;
}

var EditGroupThumbnailDlg = Class.create({
	initialize: function (group_id, label, controller) {
		this.class_type = 'EditGroupThumbnailDlg';	// for debugging
		var This = this;
		var dlg = null;
		
		var sendWithAjax = function (event, params)
		{
			editGroupThumbnailDlg = This;
			//var curr_page = params.curr_page;
			var url = params.destination;

			dlg.setFlash('Editing ' + label.toLowerCase() + ' thumbnail...', false);

			dlg.submitForm('layout', url);	// we have to submit the form normally to get the uploaded file transmitted.
		};

		this.fileUploadError = function(errMessage) {
			dlg.setFlash(errMessage, true);
		};

		this.fileUploadFinished = function(id) {
			dlg.setFlash(label + ' thumbnail updated...', false);
			window.location.reload(true);
		};
		var show = function () {
			var layout = {
					page: 'layout',
					rows: [
						[ { text: 'Choose Thumbnail:' } ],
						[ { image: 'image', size: '47', klass: 'edit_group_thumbnail' }, { hidden: 'id', value: group_id } ],
						[ { rowClass: 'last_row' }, { button: 'Update Thumbnail', url: "/" + controller + "/edit_thumbnail", callback: sendWithAjax }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
					]
				};

			var params = { this_id: "edit_group_thumbnail", pages: [ layout ], body_style: "new_group_div", row_style: "new_exhibit_row", title: "Edit " + label + " Thumbnail" };
			dlg = new GeneralDialog(params);
			dlg.changePage('layout', null);
			dlg.center();

			return;
		};

		show();
	}
});

var GroupNewPost = Class.create({
	initialize: function (progress_img, group_id, group_name, is_logged_in, license) {

		new ForumReplyDlg({ group_id: group_id, group_name: group_name,
			submit_url: '/forum/post_comment_to_new_thread',
			populate_exhibit_url: '/forum/get_exhibit_list',
			populate_collex_obj_url: '/forum/get_nines_obj_list',
			populate_topics_url: '/forum/get_all_topics',
			progress_img: progress_img,
			logged_in: is_logged_in,
			addTopicToLoginRedirect: false,
			redirect: '/groups/' + group_id,
			license: license
		});
	}
});

var ClusterNewPost = Class.create({
	initialize: function (progress_img, group_id, group_name, cluster_id, cluster_name, cluster_label, is_logged_in, license) {

		new ForumReplyDlg({ group_id: group_id, group_name: group_name,
			cluster_id: cluster_id, cluster_name: cluster_name, cluster_label: cluster_label,
			submit_url: '/forum/post_comment_to_new_thread',
			populate_exhibit_url: '/forum/get_exhibit_list',
			populate_collex_obj_url: '/forum/get_nines_obj_list',
			populate_topics_url: '/forum/get_all_topics',
			progress_img: progress_img,
			logged_in: is_logged_in,
			addTopicToLoginRedirect: false,
			redirect: '/clusters/' + cluster_id,
			license: license
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
		var extraCtrl2 = params.extraCtrl2;

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
				if (extraCtrl2 !== undefined) {
					layout.rows.push(extraCtrl2);
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
	initialize: function (group_id, membership, show_membership, owner_name, is_owner) {
		this.class_type = 'EditMembershipDlg';	// for debugging

		var membership2 = [ { Name: owner_name, "Administrator?": 'owner' } ];

		var ownerOptions = [ { text: "No change", value: 0 }];
		membership.each(function(member) {
			var checked = member.role === 'editor' ? ' checked="true"' : '';
			membership2.push({ Name: member.name,
				"Administrator?": '<input id="group_'+member.id+'_editor" type="checkbox" value="1" name="group['+member.id+'[editor]]"'+checked+'/>',
				Delete: '<input id="group_'+member.id+'_delete" type="checkbox" value="1" name="group['+member.id+'[delete]]"/>'
			});
			if (member.role === 'editor') {
				ownerOptions.push({ text: member.name, value: member.user_id });
			}
		});

		var showMembershipCtrl = [{ text: 'Show Membership List: '}, { select: 'show_membership', klass: 'select_dlg_input', options: [ { text: "To All", value: "Yes"}, { text: "To Admins", value: "No"}], value: show_membership }];
		var changeOwnerCtrl = undefined;
		if (is_owner && ownerOptions.length > 1)
			changeOwnerCtrl = [{ text: 'Change Owner: '}, { select: 'change_owner', klass: 'select_dlg_input', options: ownerOptions, value: 0 }];
		new GridDlg({ title: "Edit Membership", hidden_id: 'id', hidden_value: group_id, url: 'edit_membership', fields: ["Name","Administrator?", "Delete"], data: membership2, extraCtrl: showMembershipCtrl, extraCtrl2: changeOwnerCtrl });
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

		new GridDlg({ title: "Respond", hidden_id: 'id', hidden_value: group_id, url: 'pending_requests', fields: ["Name","No Action", "Accept", "Deny"], data: membership2 });
	}
});

var InviteMembersDlg = Class.create({
	initialize: function (group_id, siteName) {
		this.class_type = 'InviteMembersDlg';	// for debugging

		// private variables
		var dlg = null;

		var sendWithAjax = function (event, params)
		{
			dlg.setFlash('Sending email to invitees. Please wait...', false);
			var onSuccess = function(resp) {
					dlg.cancel();
			};
			var onFailure = function(resp) {
				var str = "Some or all of your invitees have not been invited. Please check their email address and try again.<br />" + resp.responseText;
				new MessageBoxDlg("Members Not Invited", str);
				dlg.setFlash("Error: Please try again.", true);
			};
			var data = dlg.getAllData();
			var url = params.destination;
			recurseUpdateWithAjax([url], ['group_details'], onSuccess, onFailure, data);
		};

		// privileged methods
		var show = function () {
			var layout = {
					page: 'layout',
					rows: [
						[ { text: 'There are two ways to invite people to join your group in ' + siteName +
							': email address or username. If you know the participants\' usernames, list them in the blank below, one per line.', klass: 'invite_users_instructions' }, { hidden: 'id', value: group_id } ],
						[ { text: 'By Username:', klass: 'invite_users_label' }, { textarea: 'usernames', klass: 'groups_textarea' } ],
						[ { rowClass: 'button_row' }, { button: 'Submit', url: '/groups/update', callback: sendWithAjax } ],
						[ { text: "Don't know any usernames? Add email addresses of users you want to invite in the blank below, one per line.", klass: 'invite_users_instructions' } ],
						[ { text: 'By Email Address:', klass: 'invite_users_label' }, { textarea: 'emails', klass: 'groups_textarea' } ],
						[ { rowClass: 'last_row' }, { button: 'Submit', url: '/groups/update', callback: sendWithAjax }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
					]
				};

			var params = { this_id: "invite_users_dlg", pages: [ layout ], body_style: "invite_users_div", row_style: "new_exhibit_row", title: "Invite Users to Join" };
			dlg = new GeneralDialog(params);
			dlg.changePage('layout', "username");
			dlg.center();

			return;
		};
		
		show();
	}
});

var editDescription = function(id, value, controller, populate_url, progress_img) {
	var okCallback = function(value) {
		var params = { id: id };
		params[controller + '[description]'] = value;
		recurseUpdateWithAjax([ '/' + controller + 's/update' ], [ controller + '_details' ], null, null, params);

	};
	new RteInputDlg({
		title: 'Edit Description',
		okCallback: okCallback,
		value: value,
		populate_urls: [ populate_url ],
		progress_img: progress_img });
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
		target_els: [ 'group_discussions' ] });
};

var changeWhichExhibitsAreShown = function(id, value, groupShowExhibitsOptions, groupShowExhibitsExplanations, exhibitLabel) {
	new SelectInputDlg({
		title: 'Change Which ' + exhibitLabel + 's Are Shown',
		prompt: 'Show ' + exhibitLabel + 's',
		id: 'group[show_exhibits]',
		options: groupShowExhibitsOptions,
		explanation: groupShowExhibitsExplanations,
		okStr: 'Save',
		value: value,
		extraParams: { id: id },
		actions: [ '/groups/update', '/groups/group_exhibits_list' ],
		target_els: [ 'group_details', 'group_exhibits' ] });
};

var editVisibility = function(id, value, groupExhibitVisibilityOptions, groupExhibitVisibilityExplanations, exhibitLabel) {
	new SelectInputDlg({
		title: 'Change ' + exhibitLabel + ' Visibility',
		prompt: exhibitLabel + 's are ',
		id: 'group[exhibit_visibility]',
		options: groupExhibitVisibilityOptions,
		explanation: groupExhibitVisibilityExplanations,
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
			'This group is being used to teach. File this group under the "Classroom" section.',
			'Publication groups work closely with the NINES staff to vet their content. If you select this option a notification will be sent to the NINES staff, and someone will be in contact with you soon.' ],
		okStr: 'Save',
		value: value,
		extraParams: { id: id },
		actions: [ '/groups/update' ],
		target_els: [ 'group_details' ] });
};

var editGroupTextField = function(id, value, name, field) {
	var verifyFxn = function(data) {
		var val = data['group[' + field + ']'];
		if (val.length === 0)
			return "This entry cannot be blank. Please enter a value.";
		return null;
	};

	new TextInputDlg({
		title: 'Edit ' + name,
		prompt: name,
		id: 'group[' + field + ']',
		okStr: 'Save',
		value: value,
		verifyFxn: verifyFxn,
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

var editURL = function(id, value, controller, prompt) {
	new TextInputDlg({
		title: 'Edit URL',
		prompt: prompt,
		id: controller + '[visible_url]',
		okStr: 'Save',
		value: value,
		inputKlass: 'edit_url_input',
		extraParams: { id: id },
		verify: '/' + controller + 's/check_url',
		actions: [ '/' + controller + 's/update' ],
		target_els: [ controller + '_details' ] });
};

var moveExhibitToCluster = function(update_url, group_id, cluster_id, exhibitOptions, update_el, exhibitLabel, clusterLabel) {
	new SelectInputDlg({
		title: 'Move ' + exhibitLabel + ' to ' + clusterLabel,
		prompt: exhibitLabel,
		id: 'exhibit_id',
		options: exhibitOptions,
		okStr: 'Move',
		body_style: "",
		extraParams: { dest_cluster: cluster_id, cluster_id: cluster_id, group_id: group_id },
		actions: [ update_url],
		target_els: [ update_el ] });
};

var changeClusterVisibility = function(update_url, cluster_id, value, visibilityOptions, update_el, clusterLabel) {
	new SelectInputDlg({
		title: 'Change ' + clusterLabel + ' Visibility',
		prompt: 'Visibility',
		id: 'cluster[visibility]',
		options: visibilityOptions,
		value: value,
		okStr: 'Save',
		extraParams: { id: cluster_id },
		actions: [ update_url ],
		target_els: [ update_el ] });
};

var changeExhibitLabel = function(update_url, cluster_id, value, options, update_el) {
	new SelectInputDlg({
		title: 'Change Exhibit Label',
		prompt: 'Label',
		id: 'group[exhibits_label]',
		options: options,
		value: value,
		okStr: 'Save',
		extraParams: { id: cluster_id },
		actions: [ update_url, '/groups/group_exhibits_list' ],
		target_els: [ update_el, 'group_exhibits' ] });
};

var changeClusterLabel = function(update_url, cluster_id, value, options, update_el) {
	new SelectInputDlg({
		title: 'Change Cluster Label',
		prompt: 'Label',
		id: 'group[clusters_label]',
		options: options,
		value: value,
		okStr: 'Save',
		extraParams: { id: cluster_id },
		actions: [ update_url, '/groups/group_exhibits_list' ],
		target_els: [ update_el, 'group_exhibits' ] });
};

var moveExhibit = function(exhibit_id, clusterOptions, group_id, cluster_id, exhibitLabel) {
	clusterOptions.unshift({text: "(None)", value: "0" });
	new SelectInputDlg({
		title: 'Move ' + exhibitLabel,
		prompt: 'To:',
		id: 'dest_cluster',
		value: cluster_id,
		options: clusterOptions,
		okStr: 'Save',
		body_style: "",
		extraParams: { group_id: group_id, cluster_id: cluster_id, exhibit_id: exhibit_id },
		actions: [ '/clusters/move_exhibit' ],
		target_els: [ 'group_exhibits' ] });
};

var request_to_join = function(group_id, user_id) {
	ajaxWithProgressDlg(['/groups/request_join'], ['group_details'],
		{ title: "Request To Join Group", waitMessage: "Please wait...", completeMessage: 'A request to join this group is pending acceptance by the moderator.' },
		{group_id: group_id, user_id: user_id });
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

var acceptAsPeerReviewed = function(exhibit_id, clusterOptions, exhibitLabel, clusterLabel, exhibitTitle, exhibitAuthor, siteName, currentCluster, groupName, groupPermissions, exhibitLink, userInfoUrl) {
	clusterOptions.unshift({text: "(None)", value: "0" });
	var dlg = null;

	var sendWithAjax = function (event, params)
	{
		var onSuccess = function(resp) {
			dlg.cancel();
		};
		var onFailure = function(resp) {
			dlg.setFlash("Error: " + resp.responseText, true);
		};
		var data = dlg.getAllData();
		data.exhibit_id = exhibit_id;
		data["exhibit[is_published]"] = '1';
		if (data.typ === 'cluster' && data['exhibit[cluster_id]'] === '0')
			dlg.setFlash("Please choose a " + clusterLabel + " from the list.", true);
		else {
			var url = params.destination;
			dlg.setFlash('Accepting ' + exhibitLabel + '. Please wait...', false);
			recurseUpdateWithAjax([url], ['group_exhibits'], onSuccess, onFailure, data);
		}
	};

	var layout = {
			page: 'layout',
			rows: [
				[ { rowClass: 'accept_peer_review_header' }, { text: 'You are about to set <a href="' + exhibitLink + '" target="_blank" class="nav_link">' + exhibitTitle + '</a> by <a class="nav_link" href="#" onclick="showPartialInLightBox(\'' + userInfoUrl + '\', \'Profile for ' + exhibitAuthor + '\'); return false;">' + exhibitAuthor + '</a> as a peer-reviewed object.' } ],
				[ { text: 'This means that the work will be indexed into ' + siteName + ' and stamped with a badge of approval. If you wish to continue, please select "Accept". Otherwise, please select "Cancel."', klass: 'accept_peer_review_label non_cluster_options' },
					{ text: 'This means that the work will be indexed into ' + siteName + ' and stamped with a badge of approval. If you wish to continue, please select a method for sharing this work below. Otherwise, please select "Cancel."', klass: 'accept_peer_review_label hidden cluster_options' } ],
				[ { radioList: 'typ', klass: 'accept_peer_review_radio hidden cluster_options', value: (currentCluster === 0 ? 'noncluster' : 'cluster'), buttons: [ { value: 'noncluster', text: 'I certify this ' + exhibitLabel + ' has been peer reviewed as a stand-alone object.' }, { value: 'cluster', text: 'I certify that this ' + exhibitLabel + ' has been peer reviewed as part of a ' + clusterLabel + ' of objects.' } ]}],
				[ { text: 'Choose a ' + clusterLabel + ':', klass: 'accept_peer_review_label2 hidden cluster_options' }, { select: 'exhibit[cluster_id]', options: clusterOptions, value: currentCluster, klass: 'hidden cluster_options' } ],
				[ { text: 'Note: Objects in <span class="accept_peer_review_group_name">' + groupName + '</span> have a default sharing option of "<span class="accept_peer_review_permissions">' + groupPermissions + '</span>".', klass: 'accept_peer_review_label' } ],
				[ { rowClass: 'last_row' }, { button: 'Accept', url: '/groups/accept_as_peer_reviewed', callback: sendWithAjax }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
			]
		};

	var params = { this_id: "invite_users_dlg", pages: [ layout ], body_style: "invite_users_div", row_style: "new_exhibit_row", title: "Accept As Peer Reviewed" };
	dlg = new GeneralDialog(params);
	dlg.changePage('layout', "username");
	if (clusterOptions.length > 1) {
		$$('.cluster_options').each(function(el) { el.removeClassName('hidden'); });
		$$('.non_cluster_options').each(function(el) { el.addClassName('hidden'); });
	}
	dlg.center();
};

var limitExhibit = function(exhibit_id, exhibitLabel) {
	ajaxWithProgressDlg(['/groups/limit_exhibit'], ['group_exhibits'],
		{ title: "Limit Exhibit", waitMessage: "Please wait...", completeMessage: 'This ' + exhibitLabel + ' can only be viewed by group members.' },
		{exhibit_id: exhibit_id });
};

var unlimitExhibit = function(exhibit_id, exhibitLabel) {
	ajaxWithProgressDlg(['/groups/unlimit_exhibit'], ['group_exhibits'],
		{ title: "Allow Publishing", waitMessage: "Please wait...", completeMessage: 'This ' + exhibitLabel + ' can be viewed by everyone.' },
		{exhibit_id: exhibit_id });
};

var hideAdmins = function(group_id, url) {
	ajaxWithProgressDlg([url], ['group_details'],
		{ title: "Hide Admins", waitMessage: "Please wait...", completeMessage: 'The administators are hidden to non-members.' },
		{id: group_id, 'group[show_admins]': 'members' });
};

var showAdmins = function(group_id, url) {
	ajaxWithProgressDlg([url], ['group_details'],
		{ title: "Show Admins", waitMessage: "Please wait...", completeMessage: 'The administators are visible to non-members.' },
		{id: group_id, 'group[show_admins]': 'all' });
};

var confirmDlgWithTextArea = function(urls, els, title, completeMsg, confirmMsg, commentLabel, extraData) {
	var action = function(event, params) {
		var data = params.dlg.getAllData();
		extraData.comment = data.comment;
		params.dlg.cancel();
		ajaxWithProgressDlg(urls, els,
			{ title: title, waitMessage: "Please wait...", completeMessage: completeMsg },
			extraData);
	};

	var dlgLayout = {
			page: 'layout',
			rows: [
				[ {text: confirmMsg, klass: 'message_box_label'} ],
				[ { text: commentLabel },
					{ textarea: 'comment', klass: 'confirmdlg_comment' }],
				[ {rowClass: 'last_row'}, {button: "Ok", callback: action, isDefault: true}, {button: "Cancel", callback: GeneralDialog.cancelCallback} ]
			]
		};

		var params = {this_id: "confirm_comment_dlg", pages: [ dlgLayout ], body_style: "message_box_dlg", row_style: "message_box_row", title: title};
		var dlg = new GeneralDialog(params);
		dlg.changePage('layout', null);
		dlg.center();
};

var unpublishExhibit = function(exhibit_id, name, email, exhibitLabel) {
	confirmDlgWithTextArea(['/groups/unpublish_exhibit'], ['group_exhibits'], "Unpublish Exhibit",
		'This ' + exhibitLabel + ' has been set to "Private".',
		'This option unpublishes the ' + exhibitLabel + '. A message will be sent to ' + name + " at " + email + " with a short message notifying them of your action.",
		'Add a comment to this email:', { exhibit_id: exhibit_id });
};

var rejectAsPeerReviewed = function(exhibit_id, name, email, exhibitLabel) {
	confirmDlgWithTextArea(['/groups/reject_as_peer_reviewed'], ['group_exhibits'], "Return Exhibit For Revisions",
		'The ' + exhibitLabel + ' has been sent back for revisions.',
		'This option returns the ' + exhibitLabel + ' to its original contributor for revision. A message will be sent to ' + name + " at " + email + " with a short message notifying them of your request.",
		'Add a comment to this email:', { exhibit_id: exhibit_id });
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
	initialize: function (create_url, group_id, group_name, can_set_thumbnail, update_url, update_el, populate_urls, progress_img, clusterLabel) {
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
				dlg.setFlash('Please enter a name for this ' + clusterLabel + ' before continuing.', true);
				return;
			}

			newClusterDlg = This;
			dlg.setFlash('Verifying ' + clusterLabel + ' creation...', false);
			dlg.getAllData();
			
			dlg.submitForm('layout', create_url);	// we have to submit the form normally to get the uploaded file transmitted.
		};

		this.fileUploadError = function(errMessage) {
			dlg.setFlash(errMessage, true);
		};

		this.fileUploadFinished = function(id) {
			dlg.setFlash(clusterLabel + ' created...', false);
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
						[ { text: 'Creating New ' + clusterLabel + ' in the Group \"'+ group_name + "\"", klass: 'new_exhibit_title' }, { hidden: 'cluster[group_id]', value: group_id } ],
						[ { text: 'Title:', klass: 'groups_label' }, { input: 'cluster[name]', klass: 'new_exhibit_input_long' } ],
						[ { text: 'Description:', klass: '' } ],
						[ { textarea: 'cluster[description]', klass: 'groups_textarea' } ],
						[ { text: 'Thumbnail:', klass: 'groups_label thumbnail hidden' }, { image: 'image', size: '37', removeButton: 'Remove Thumbnail', klass: 'thumbnail hidden' } ],
						[ { rowClass: 'last_row' }, { button: 'Create ' + clusterLabel, url: create_url, callback: sendWithAjax }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
					]
				};

			var params = { this_id: "new_cluster_wizard", pages: [ layout ], body_style: "new_cluster_div", row_style: "new_exhibit_row", title: "Create New " + clusterLabel };
			dlg = new GeneralDialog(params);
			dlg.changePage('layout', "cluster_name");
			dlg.initTextAreas({ toolbarGroups: [ 'fontstyle', 'link' ], linkDlgHandler: new LinkDlgHandler([populate_urls], progress_img) });
			if (can_set_thumbnail)
				$$('.thumbnail').each(function(el) { el.removeClassName('hidden'); });
			dlg.center();

			return;
		};
		
		show();
	}
});

var setNotificationLevel = function(group_id, groupName, currentNotifications) {
	var dlg = null;

	var sendWithAjax = function (event, params)
	{
		var onSuccess = function(resp) {
			dlg.cancel();
		};
		var onFailure = function(resp) {
			dlg.setFlash("Error: " + resp.responseText, true);
		};
		var data = dlg.getAllData();
		data.group_id = group_id;
		var url = params.destination;
		dlg.setFlash('Setting Notifications for ' + groupName + '. Please wait...', false);
		recurseUpdateWithAjax([url], ['group_details'], onSuccess, onFailure, data);
	};

	var layout = {
			page: 'layout',
			rows: [
				[ { text: 'Set the email notifications you want to receive when activity occurs in ' + groupName + ':' } ],
				[ { checkboxList: 'notifications', klass: 'notifications_checkbox_label', selections: currentNotifications, items:
					[ ["exhibit", "<span class='notifications_item'>Exhibit changes</span>: added or removed from group or cluster, sharing level changed"],
					["membership", "<span class='notifications_item'>Membership changes</span>: member invited, member added, member declined, member removed, member becomes admin"],
					["discussion", "<span class='notifications_item'>Discussion changes</span>: new thread or new comment posted in this group"],
					["group", "<span class='notifications_item'>Group changes</span>: changed name, description, add clusters, remove clusters, changed visibility"] ] }],
				[ { rowClass: 'last_row' }, { button: 'Save', url: '/groups/notifications', callback: sendWithAjax }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
			]
		};

	var params = { this_id: "invite_users_dlg", pages: [ layout ], body_style: "invite_users_div", row_style: "new_exhibit_row", title: "Set Notifications" };
	dlg = new GeneralDialog(params);
	dlg.changePage('layout', "username");
	dlg.center();
};

