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

/*global Class, $, $$, $H, Ajax */
/*global doSingleInputPrompt */
/*global MessageBoxDlg, CreateListOfObjects, GeneralDialog */

/////////////////////////////////////////////////////////////

//If a user finds something that another user has posted objectionable, they can click on the “Report” button. 
//This is guarded by an “Are You Sure?” dialog. If the user affirms their intent to report the content, a popup 
//appears informing them that an email message has been sent to the site administrator. The email is sent to 
//a list of addresses configurable via config/environments files. The email includes the post that was objected 
//to and a link to it on the site.

var DiscussionReportDlg = Class.create({
	initialize: function (params) {
		this.class_type = 'DiscussionReportDlg';	// for debugging

		// private variables
		var This = this;
		var comment_id = params.comment_id;
		var submit_url = params.submit_url;
		var parent_id = params.parent_id;
		
		this.show = function () {
			doSingleInputPrompt("Report this comment as objectionable",
				"Press Ok if you want an email sent to the administrators complaining about this entry.",
				"", parent_id, "", submit_url,
				$H({ comment_id: comment_id }), 'none', null, "Ok");
		};
	}
});

//////////////////////////////////////////

var ForumReplyDlg = Class.create({
	initialize: function (params) {
		// This puts up a modal dialog that allows the user to reply to a thread.
		// If the topic_id is passed, then this should start a new thread.
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
		
		if (!logged_in) {
			new MessageBoxDlg("Warning", "You must be logged in to create a comment");
			return;
		}

		// private variables
		var This = this;
		
		// private functions
		
		// privileged functions
		this.cancel = function(event, params)
		{
			params.dlg.cancel();
		};
		
		this.attachItem = function(event, params)
		{
			$(this.id).addClassName('hidden');
			var sel = $$('.attach');
			sel.each(function(s) { s.removeClassName('hidden'); });
		};
		
		var currSel = "";
		var currSelClass = "";
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
			var curr_page = params.curr_page;
			var url = params.destination;
			var dlg = params.dlg;
			
			dlg.setFlash('Adding Comment...', false);
			var data = dlg.getAllData();
			data.thread_id = thread_id;
			data.topic_id = topic_id;
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
		
		var objlist = new CreateListOfObjects(populate_nines_obj_url, null, 'nines_obj_list', progress_img);
		var exlist = new CreateListOfObjects(populate_exhibit_url, null, 'exhibit_list', progress_img);

		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { text: 'Title', klass: 'new_exhibit_label title hidden' }, { input: 'title', klass: 'new_exhibit_input_long title hidden' } ],
					[ { textarea: 'reply' } ],
					[ { page_link: 'Attach an Item...', new_page: "", callback: this.attachItem }],
					[ { button: 'My Collection', url: 'mycollection', klass: 'button_tab attach hidden', callback: this.switch_page }, { button: 'NINES Exhibit', klass: 'button_tab attach hidden', url: 'exhibit', callback: this.switch_page }, { button: 'Web Item', klass: 'button_tab attach hidden', url: 'weblink', callback: this.switch_page } ],
					[ { custom: objlist, klass: 'mycollection hidden' }, { custom: exlist, klass: 'exhibit hidden' } ],
					[ { text: 'URL', klass: 'new_exhibit_label weblink hidden' }, { input: 'inet_url', klass: 'new_exhibit_input_long weblink hidden' } ],
					[ { text: 'Thumbnail for Item', klass: 'new_exhibit_label weblink hidden' }, { input: 'inet_thumbnail', klass: 'new_exhibit_input_long weblink hidden' } ],
					[ { button: 'Post', url: submit_url, callback: this.sendWithAjax }, { button: 'Cancel', callback: this.cancel } ]
				]
			};
		
		var dlgParams = { this_id: "forum_reply_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Reply" };
		var dlg = new GeneralDialog(dlgParams);
		if (topic_id)
			$$(".title").each(function(el) { el.removeClassName('hidden'); });
		dlg.initTextAreas([ 'fontstyle', 'link' ], null);
		dlg.changePage('layout', null);
		objlist.populate(dlg);
		exlist.populate(dlg);
		dlg.center();
	}
});

