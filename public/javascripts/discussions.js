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
			
		if (className != null && className != undefined)
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
		var click = "onclick='CreateListOfExhibits.prototype._select(this,\"" + value_field + "\" );'";
		return "<tr " + str + click + " ><td><img src='" + thumbnail + "' alt='exhibit' height='40' /></td><td>" + title + "</td></tr>\n";
	}
});

CreateListOfExhibits.prototype._select = function(item, value_field)
{
	var selClass = "input_dlg_list_item_selected";
	$$("." + selClass).each(function(el)
	{
		el.removeClassName(selClass);
	});
	$(item).addClassName(selClass);
	$(value_field).value = $(item).down().next().innerHTML.unescapeHTML();
}

//////////////////////////////////////////////////////////////////////////

var NewThreadObjectDlg = Class.create({
	initialize: function (params) {
		this.class_type = 'NewThreadObjectDlg';	// for debugging

		// private variables
		var This = this;
		var topic_id = params.topic_id;
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
			values.topic_id = topic_id;
			values.disc_type = type_list[0];

			var dlg = new InputDialog(parent_id);
			dlg.addHidden("topic_id");
			var size = 52;
			dlg.addSelect('Type of Object:', 'disc_type', type_list, selectionChanged);
			dlg.addTextInput('Link URL:', 'inet_url', size, 'inet');
			dlg.addTextInput('Thumbnail URL:', 'inet_thumbnail', size, 'inet');
			dlg.addTextArea('inet_description', 300, 100, 'inet', [ 'alignment' ], new LinkDlgHandler());
			
			var list = new CreateList(obj_list, 'nines_object', values.nines_object, 'nines_object');
			dlg.addList('nines_object', list.list, 'nines_object');
			
			var exlist = new CreateListOfExhibits(exhibit_list, 'nines_exhibit', values.nines_exhibit, 'nines_exhibit');
			dlg.addList('nines_exhibit', exlist.list, 'nines_exhibit');
			
			var el = $(parent_id);
			dlg.show("Post Object", getX(el), getY(el), 530, 350, values );
			doSelectionChanged(values.disc_type);
		};
	}
});

// public static methods
//NewThreadObjectDlg.prototype.show = function () {
//	alert("Show: " + this.get_topic_id() + " " + this.get_user_id());
//}

