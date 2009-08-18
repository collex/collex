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

/*global Class, $, $$, Ajax */
/*global CreateListOfObjects, GeneralDialog, SignInDlg, LinkDlgHandler, ForumLicenseDisplay */
/*global YAHOO */
/*global window, setTimeout */
/*extern ForumReplyDlg */

/////////////////////////////////////////////////////////////

var ForumReplyDlg = Class.create({
	initialize: function (params) {
		// This puts up a modal dialog that allows the user to reply to a thread.
		// If the topic_id is passed, then this should start a new thread.
		// If comment_id is passed, then this will edit an existing comment.
		// in that case, the following are also passed:  title, obj_type, reply, nines_obj_list, exhibit_list, inet_thumbnail, inet_url
		this.class_type = 'ForumReplyDlg';	// for debugging
		var topic_id = params.topic_id;
		var thread_id = params.thread_id;
		var submit_url = params.submit_url;
		var populate_exhibit_url = params.populate_exhibit_url;
		var populate_nines_obj_url = params.populate_nines_obj_url;
		var progress_img = params.progress_img;
		var ajax_div = params.ajax_div;
		var logged_in = params.logged_in;
		var redirect = params.redirect;
		var addTopicToLoginRedirect = params.addTopicToLoginRedirect;
		var starting_license = 5;
		var comment_id = params.comment_id;
		if (comment_id !== undefined) {
			var starting_title = params.title;
			var starting_obj_type = params.obj_type;
			var starting_comment_el = params.reply;
			var starting_nines_obj_list = params.nines_obj_list;
			var starting_exhibit_list = params.exhibit_list;
			var starting_inet_thumbnail = params.inet_thumbnail;
			var starting_inet_url = params.inet_url;
			starting_license = params.license;
		}
		
		if (!logged_in) {
			var logdlg = new SignInDlg();
			logdlg.setInitialMessage("You must be logged in to create a comment.");
			var r = 'script=ForumReplyDlg';
			if (addTopicToLoginRedirect)
				r += '_' + topic_id;
			logdlg.setRedirectPageToCurrentWithParam(r);
			logdlg.show('sign_in');
			return;
		}

		// private variables
		var This = this;
		
		// private functions
		
		// privileged functions
		var removeAttachItem = function() {
			var attach_el = $$('.attach_item')[0];
			attach_el.addClassName('hidden');
			setTimeout(function() {
				var sel = $$('.attach');
				sel.each(function(s) { s.removeClassName('hidden'); });
				}, 50);
		};
		
		var currSel = "";
		var currSelClass = "";
		this.attachItem = function(event, params)
		{
			removeAttachItem();
			
			// Now select the first tab, which is the My Collection.
			params.destination = "mycollection";
			currSel = 'forum_reply_dlg_btn0';
			currSelClass = params.destination;
			var fn = This.switch_page.bind($(currSel));
			fn(event, params);
			//$(currSel).addClassName('button_tab_selected');
		};
		
		this.switch_page = function(event, params)
		{
			if (currSel !== "") {
				$(currSel).removeClassName('button_tab_selected');
				var sel = $$('.' + currSelClass);
				sel.each(function(s) { s.addClassName('hidden'); });
			}
			currSel = this.id;
			currSelClass = params.destination;
			$(this.id).addClassName('button_tab_selected');
			var sel2 = $$('.' + params.destination);
			sel2.each(function(s) { s.removeClassName('hidden'); });
		};
		
		this.sendWithAjax = function (event, params)
		{
			//var curr_page = params.curr_page;
			var url = params.destination;
			var dlg = params.dlg;
			
			dlg.setFlash('Adding Comment...', false);
			var data = dlg.getAllData();
			data.thread_id = thread_id;
			data.topic_id = topic_id;
			data.comment_id = comment_id;
			data.obj_type = currSelClass;

			if (ajax_div) {
				new Ajax.Updater(ajax_div, url, {
					parameters: data,
					evalScripts: true,
					onSuccess: function(resp){
						dlg.cancel();
					},
					onFailure: function(resp){
						dlg.setFlash(resp.responseText, true);
					}
				});
			} else {
				new Ajax.Request(url, {
					parameters: data,
					evalScripts: true,
					onSuccess: function(resp){
						dlg.cancel();
						window.location = redirect;
					},
					onFailure: function(resp){
						dlg.setFlash(resp.responseText, true);
					}
				});
			}
		};

		var objlist = new CreateListOfObjects(populate_nines_obj_url, starting_nines_obj_list, 'nines_obj_list', progress_img);
		var exlist = new CreateListOfObjects(populate_exhibit_url, starting_exhibit_list, 'exhibit_list', progress_img);
		var licenseDisplay = new ForumLicenseDisplay({ populateLicenses: '/my9s/get_licenses', currentLicense: starting_license, id: 'license_list' });

		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { custom: licenseDisplay, klass: 'forum_reply_license title hidden' }, { text: 'Title', klass: 'forum_reply_label title hidden' } ],
					[ { input: 'title', value: starting_title, klass: 'forum_reply_input title hidden' } ],
					[ { textarea: 'reply', klass: 'clear_both', value: starting_comment_el ? $(starting_comment_el).innerHTML : undefined } ],
					[ { page_link: 'Attach an Item...', klass: 'attach_item', new_page: "", callback: this.attachItem }],
					[ { button: 'My Collection', url: 'mycollection', klass: 'button_tab attach hidden', callback: this.switch_page }, { button: 'NINES Exhibit', klass: 'button_tab attach hidden', url: 'exhibit', callback: this.switch_page }, { button: 'Web Item', klass: 'button_tab attach hidden', url: 'weblink', callback: this.switch_page } ],
					[ { custom: objlist, klass: 'mycollection hidden' }, { custom: exlist, klass: 'exhibit hidden' } ],
					[ { text: 'URL', klass: 'forum_reply_label weblink hidden' }, { input: 'inet_url', value: starting_inet_url, klass: 'forum_reply_input weblink hidden' } ],
					[ { text: 'Thumbnail for Item', klass: 'forum_reply_label weblink hidden' }, { input: 'inet_thumbnail', value: starting_inet_thumbnail, klass: 'forum_reply_input weblink hidden' } ],
					[ { rowClass: 'last_row' }, { button: 'Post', url: submit_url, callback: this.sendWithAjax, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
				]
			};
		
		var dlgTitle = topic_id ? "New Post" : (thread_id ? "Reply" : "Edit Comment");
		var dlgParams = { this_id: "forum_reply_dlg", pages: [ dlgLayout ], body_style: "forum_reply_dlg", row_style: "forum_reply_row", title: dlgTitle };
		var dlg = new GeneralDialog(dlgParams);
		var focus_id = null;
		if (topic_id || (comment_id && starting_title)) {
			focus_id = 'title';
			$$(".title").each(function(el) { el.removeClassName('hidden'); });
		}
		dlg.initTextAreas({ toolbarGroups: [ 'fontstyle', 'link' ], linkDlgHandler: new LinkDlgHandler(populate_nines_obj_url, progress_img) });
		dlg.changePage('layout', focus_id);
		licenseDisplay.populate(dlg);
		objlist.populate(dlg, false, 'forum');
		exlist.populate(dlg, false, 'forum');
		dlg.center();
		if (starting_obj_type && starting_obj_type !== 1) {
			YAHOO.util.Event.onAvailable('reply_container', function() {	// We want this to happen after creating the RTE because the user sees that first.
				removeAttachItem();
				
				var pages = [ 'mycollection', 'exhibit', 'weblink' ];
				var params = { destination: pages[starting_obj_type-2] };
				currSel = 'forum_reply_dlg_btn' + (starting_obj_type-2);
				currSelClass = params.destination;
				var fn = This.switch_page.bind($(currSel));
				fn(null, params);
			}, this);
		}
	}
});

