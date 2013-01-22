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

/*global SelectInputDlg */
/*extern setExhibitAuthorAlias, addAdditionalAuthor */

function setExhibitAuthorAlias(url_get_users, url_update_alias, exhibit_id, page_id, page_num) {
	new SelectInputDlg({
		title: "Choose User to Publish As",
		prompt: 'Select the user that you wish to impersonate',
		id: 'user_id',
		actions: url_update_alias,
		target_els: page_id,
		extraParams: { exhibit_id: exhibit_id, page_num: page_num },
		pleaseWaitMsg: 'Updating Exhibit\'s Author...',
		body_style: "edit_palette_dlg",
		options: [ { value: -1, text: 'Loading user names. Please Wait...' } ],
		populateUrl: url_get_users
	});
}

function addAdditionalAuthor(url_get_users, url_add_author, exhibit_id, page_id, page_num) {
	new SelectInputDlg({
		title: "Add Additional Author",
		prompt: 'Select the user that you wish to add to the author line',
		id: 'user_id',
		actions: url_add_author,
		target_els: page_id,
		extraParams: { exhibit_id: exhibit_id, page_num: page_num },
		pleaseWaitMsg: 'Adding Author to Exhibit...',
		body_style: "edit_palette_dlg",
		options: [ { value: -1, text: 'Loading user names. Please Wait...' } ],
		populateUrl: url_get_users
	});
}
