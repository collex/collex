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

/*global Class, $, $$, $H */
/*global InputDialog, LinkDlgHandler, CreateList, doSingleInputPrompt */
/*global getX, getY */

function postNewComment() {
	commentEditor.saveHTML();
	var t = $('title');
	if (t.defaultValue === t.value) {
		doSingleInputPrompt("Notice: Can't Create Comment", 'You must enter a title for the comment.', null, 'title', null, null, $H({ }), 'none', null, "Ok");
		return false;
	}
	
	var comment = $('comment').value;
	comment = comment.gsub("&nbsp;", "");
	if (comment.strip().length === 0) {
		doSingleInputPrompt("Notice: Can't Create Comment", 'You must enter a comment in the comment area', null, 'title', null, null, $H({ }), 'none', null, "Ok");
		return false;
	}
	
	document.post_comment.submit();
}

/////////////////////////////////////////////////////////////

//Posting an Object brings up a dialog box that allows the user to select the object to post. 
//This dialog is similar to the Edit Illustration dialog in the Exhibit Builder. The user may post a 
//NINES Object, a NINES Exhibit, or an Internet Link. The list of NINES Object is drawn from the 
//user’s collect objects listed alphabetically. For an Internet Link, the user may fill in the following 
//fields: Link URL, Image URL, and description (memo field like textual illustration entry).

// This either cancels, or it redirects to /discussions/new_thread_object with parameters for the object.

var CreateListOfExhibits = Class.create({
	initialize : function(items, className, initial_selected_uri, value_field)
	{
		var list = null;
		
		items = items.sortBy(function(item) { return item.title; });
		var This = this;
		if (items.length > 10)
			This.list = "<div style='overflow:auto; height: 450px;'>";
		else
			This.list = "";

		if (className !== null && className !== undefined)
			This.list += "<table class='input_dlg_list " + className + "' >";
		else
			This.list += "<table class='input_dlg_list' >";
		var is_first = true;
		items.each(function(obj) {
			This.list += This.constructItem(obj.thumbnail, obj.title, is_first, value_field);
			is_first = false;
		});
		This.list += "</table>";
		if (items.length > 10)
			This.list += "</div>";
	},
	
	constructItem: function(thumbnail, title, is_selected, value_field)
	{
		var str = "";
		if (is_selected)
			str = " class='input_dlg_list_item_selected' ";
		var click = "onclick='CreateListOfExhibits.prototype.select(this,\"" + value_field + "\" );'";
		return "<tr " + str + click + " ><td><img src='" + thumbnail + "' alt='exhibit' height='40' /></td><td>" + title + "</td></tr>\n";
	}
});

CreateListOfExhibits.prototype.select = function(item, value_field)
{
	var selClass = "input_dlg_list_item_selected";
	$$("." + selClass).each(function(el)
	{
		el.removeClassName(selClass);
	});
	$(item).addClassName(selClass);
	$(value_field).value = $(item).down().next().innerHTML.unescapeHTML();
};

//////////////////////////////////////////////////////////////////////////

var NewThreadObjectDlg = Class.create({
	initialize: function (params) {
		this.class_type = 'NewThreadObjectDlg';	// for debugging

		// private variables
		var This = this;
		var topic_id = params.topic_id;	// we are passed either a thread or a topic id.
		var thread_id = params.thread_id;
		var obj_list = params.obj_list;
		var exhibit_list = params.exhibit_list;
		var type_list = params.type_list;
		var submit_url = params.submit_url;
		var parent_id = params.parent_id;
		
		// private functions
		var doSelectionChanged = function (currSelection)
		{
			// This is a callback that is fired whenever the user changes the select
			// box while editing illustrations. It is also fired when the dialog first
			// is displayed.
			var inet = $$('.inet');
			var nines_obj = $$('.nines_object');
			var nines_exhibit = $$('.nines_exhibit');
		
			if (currSelection === type_list[0]) {	// nines object
				inet.each(function(el) { el.hide(); });
				nines_obj.each(function(el) { el.show(); });
				nines_exhibit.each(function(el) { el.hide(); });
			} else if (currSelection === type_list[1]) {	// nines exhibit
				inet.each(function(el) { el.hide(); });
				nines_obj.each(function(el) { el.hide(); });
				nines_exhibit.each(function(el) { el.show(); });
			} else if (currSelection === type_list[2]) {	// inet
				inet.each(function(el) { el.show(); });
				nines_obj.each(function(el) { el.hide(); });
				nines_exhibit.each(function(el) { el.hide(); });
			}
		};

		var selectionChanged = function ()
		{
			var This = $(this);
			var currSelection = This.value;
			doSelectionChanged(currSelection);
		};
		
		// privileged methods
		this.get_type_list = function () { return type_list; };
		
		this.show = function () {
			InputDialog.prototype.prepareDomForEditing(parent_id, '', submit_url);

			var values = {};
			values.element_id = parent_id;
			if (topic_id !== undefined)
				values.topic_id = topic_id;
			if (thread_id !== undefined)
				values.thread_id = thread_id;
			values.disc_type = type_list[0];

			var dlg = new InputDialog(parent_id);
			dlg.addHidden("topic_id");
			dlg.addHidden("thread_id");
			var size = 52;
			dlg.addSelect('Type of Object:', 'disc_type', type_list, selectionChanged);
			dlg.addTextInput('Link URL:', 'inet_url', size, 'inet');
			dlg.addTextInput('Thumbnail URL:', 'inet_thumbnail', size, 'inet');
			
			var list = new CreateList(obj_list, 'nines_object', values.nines_object, 'nines_object');
			dlg.addList('nines_object', list.list, 'nines_object');
			
			var exlist = new CreateListOfExhibits(exhibit_list, 'nines_exhibit', values.nines_exhibit, 'nines_exhibit');
			dlg.addList('nines_exhibit', exlist.list, 'nines_exhibit');

			dlg.addTextArea('description', 300, 100, null, [ 'alignment' ], new LinkDlgHandler());
			
			var el = $(parent_id);
			dlg.show("Post Object", getX(el), getY(el), 530, 350, values );
			doSelectionChanged(values.disc_type);
		};
	}
});

//////////////////////////////////////////

//TODO: When a user decides to “Post a Comment”, a rich edit box appears for them to post their comment. To the 
//left of the comment is the user’s profile picture (or the placeholder if he or she doesn’t have one). This is 
//just like the text editor for exhibits with similar capabilities with regards to linking. To the bottom right of 
//the rich text editor are two buttons: “Post Comment” and “Cancel”.

var NewDiscussionCommentDlg = Class.create({
	initialize: function (params) {
		this.class_type = 'NewDiscussionCommentDlg';	// for debugging

		// private variables
		var This = this;
		var thread_id = params.thread_id;
		var submit_url = params.submit_url;
		var parent_id = params.parent_id;
		
		this.show = function () {
			doSingleInputPrompt("Add Comment", "Comment:", "new_comment", parent_id, "", submit_url,
				$H({ thread_id: thread_id }), 'textarea', $H({ height: 80, width: 80 }), null, null);
		};
	}
});

//////////////////////////////////////////

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

