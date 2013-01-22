//------------------------------------------------------------------------
//    Copyright 2009 Applied Research in Patacriticism and the University of Virginia
//    
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
//  
//        http://www.apache.org/licenses/LICENSE-2.0
//  
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.
//----------------------------------------------------------------------------

/*global Class, $, $$, Element */
/*global MessageBoxDlg, GeneralDialog, SignInDlg, LinkDlgHandler, serverRequest, gotoPage */
/*global ForumLicenseDisplay */
/*extern StartDiscussionWithExhibit */

///////////////////////////////////////////////////////////////////////////

var StartDiscussionWithExhibit = Class.create({
	initialize: function (url_get_topics, url_update, exhibit_id, title, discussion_button, is_logged_in, populate_collex_obj_url, progress_img, group_id, cluster_id) {
		// This puts up a modal dialog that allows the user to select the objects to be in this exhibit.
		this.class_type = 'StartDiscussionWithExhibit';	// for debugging

		// private variables
		//var This = this;
		var dlg = null;

		if (!is_logged_in) {
			var logdlg = new SignInDlg();
			logdlg.setInitialMessage("Please log in to start a discussion");
			logdlg.setRedirectPageToCurrentWithParam('script=StartDiscussionWithExhibit');
			logdlg.show('sign_in');
			return;
		}

		// private functions
		var populate = function()
		{
			var onSuccess = function(resp) {
				var topics = [];
				dlg.setFlash('', false);
				try {
					if (resp.responseText.length > 0)
						topics = resp.responseText.evalJSON(true);
				} catch (e) {
					new MessageBoxDlg("Error", e);
				}
				// We got all the topics. Now put them on the dialog.
				var sel_arr = $$('.discussion_topic_select');
				var select = sel_arr[0];
				select.update('');
				topics = topics.sortBy(function(topic) { return topic.text; });
				topics.each(function(topic) {
					select.appendChild(new Element('option', { value: topic.value }).update(topic.text));
				});
				$('topic_id').writeAttribute('value', topics[0].value);
			};
			serverRequest({ url: url_get_topics, onSuccess: onSuccess});
		};

		// privileged functions
		this.sendWithAjax = function (event, params)
		{
			//var curr_page = params.curr_page;
			var url = params.arg0;
			var dlg = params.dlg;

			dlg.setFlash('Updating Discussion Topics...', false);
			var data = dlg.getAllData();
			data.inet_thumbnail = "";
			data.thread_id = "";
			data.group_id = group_id;
			data.cluster_id = cluster_id;
			data.nines_exhibit = exhibit_id;
			data.nines_object = "";
			data.inet_url = "";
			data.inet_title = "";
			data.disc_type = "NINES Exhibit";

			var onSuccess = function(resp) {
				$(discussion_button).hide();
				dlg.cancel();
				gotoPage(resp.responseText);
			};
			serverRequest({ url: url, params: data, onSuccess: onSuccess});
		};

		var licenseDisplay = new ForumLicenseDisplay({ populateLicenses: '/exhibits/get_licenses?non_sharing=false', currentLicense: 5, id: 'license_list' });
		var dlgLayout = {
				page: 'start_discussion',
				rows: [
					[ { text: 'Starting a discussion of: ' + title, klass: 'new_exhibit_label' } ],
					[ { custom: licenseDisplay, klass: 'forum_reply_license title' }, { text: 'Select the topic you want this discussion to appear under:', klass: 'new_exhibit_label' } ],
					[ { select: 'topic_id', klass: 'discussion_topic_select', options: [ { value: -1, text: 'Loading topics. Please Wait...' } ] } ],
					[ { text: 'Title', klass: 'forum_reply_label title ' } ],
					[ { input: 'title', klass: 'forum_reply_input title' } ],
					[ { textarea: 'description' } ],
					[ { rowClass: 'gd_last_row' }, { button: 'Ok', arg0: url_update, callback: this.sendWithAjax, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
				]
			};

		var params = { this_id: "start_discussion_with_object_dlg", pages: [ dlgLayout ], body_style: "forum_reply_dlg", row_style: "new_exhibit_row", title: "Start Discussion", focus: 'start_discussion_with_object_dlg_sel0' };
		dlg = new GeneralDialog(params);
		dlg.initTextAreas({ toolbarGroups: [ 'fontstyle', 'link' ], linkDlgHandler: new LinkDlgHandler([populate_collex_obj_url], progress_img) });
		//dlg.changePage('start_discussion', 'start_discussion_with_object_dlg_sel0');
		licenseDisplay.populate(dlg);
		dlg.center();
		populate(dlg);
	}
});
