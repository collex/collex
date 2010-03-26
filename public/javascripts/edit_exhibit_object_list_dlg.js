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

/*global Class, Element, Ajax, $ */
/*global GeneralDialog, CreateListOfObjects, genericAjaxFail */
/*extern EditExhibitObjectListDlg, ObjectSelector, doRemoveObjectFromExhibit */

////////////////////////////////////////////////////////////////////////////
/// Create the control that adds and subtracts objects from exhibits
////////////////////////////////////////////////////////////////////////////

var ObjectSelector = Class.create({
	initialize: function (progress_img, url_get_objects, exhibit_id) {
		// This creates 4 controls: the unselected list, the selected list, and the buttons to move items between the two
		this.class_type = 'ObjectSelector';	// for debugging

		// private variables
		//var This = this;
		var olUnchosen = new CreateListOfObjects(url_get_objects + '?chosen=false&exhibit_id='+exhibit_id, null, 'unchosen_objects', progress_img);
		var olChosen = new CreateListOfObjects(url_get_objects + '?chosen=true&exhibit_id='+exhibit_id, null, 'chosen_objects', progress_img);

//		var olChosen = new ObjectList(progress_img, "Objects In Exhibit");
		var divMarkup = null;
		var actions = [];
		//var objs = null;

		// private functions
		var addSelection = function()
		{
			var obj = olUnchosen.popSelection();
			if (obj)
				olChosen.add(obj);
		};

		var removeSelection = function()
		{
			var obj = olChosen.popSelection();
			if (obj)
				olUnchosen.add(obj);
		};

		// privileged functions
		this.populate = function(dlg)
		{
			// Call the server to get the data, then pass it to the ObjectLists
			dlg.setFlash('Getting objects...', false);
			olUnchosen.populate(dlg, false, 'new');
			olChosen.populate(dlg, false, 'new');
			actions.each(function(action) {
				action.el.observe('click', action.action);
			});
		};

		this.getMarkup =  function()
		{
			if (divMarkup !== null)
				return divMarkup;

			divMarkup = new Element('div');
			divMarkup.addClassName('object_selector');

			var divLeftText = new Element('div').update('Available Objects:');
			divLeftText.addClassName('select_objects_label select_objects_label_left');
			divMarkup.appendChild(divLeftText);
			var divRightText = new Element('div').update('Objects in Exhibit:');
			divRightText.addClassName('select_objects_label select_objects_label_right');
			divMarkup.appendChild(divRightText);

			divMarkup.appendChild(olUnchosen.getMarkup());
			var mid = new Element('div');
			mid.addClassName('select_objects_buttons');
			var but2 = new Element('input', { type: 'button', value: 'ADD >>' });
			mid.appendChild(but2);
			var but = new Element('input', { type: 'button', value: '<<' });
			mid.appendChild(but);
			actions.push({el: but, action: removeSelection });
			actions.push({el: but2, action: addSelection });
			divMarkup.appendChild(mid);
			divMarkup.appendChild(olChosen.getMarkup());
			return divMarkup;
		};

		this.getSelectedObjects = function()
		{
			return olChosen.getAllObjects();
		};

		this.getSelection = function() {
			// TODO: This is the new way of getting the selection from custom controls.
			return "";
		};
	}
});

var EditExhibitObjectListDlg = Class.create({
	initialize: function (progress_img, url_get_objects, url_update_objects, exhibit_id, palette_el_id) {
		// This puts up a modal dialog that allows the user to select the objects to be in this exhibit.
		this.class_type = 'EditExhibitObjectListDlg';	// for debugging

		// private variables
		//var This = this;
		var obj_selector = new ObjectSelector(progress_img, url_get_objects, exhibit_id);

		// private functions

		// privileged functions
		this.sendWithAjax = function (event, params)
		{
			//var curr_page = params.curr_page;
			var url = params.destination;
			var dlg = params.dlg;

			dlg.setFlash('Updating Exhibit\'s Objects...', false);
			var data = { exhibit_id: exhibit_id, objects: obj_selector.getSelectedObjects().join('\t') };

			new Ajax.Updater(palette_el_id, url, {
				parameters : data,
				evalScripts : true,
				onSuccess : function(resp) {
					dlg.cancel();
				},
				onFailure : function(resp) {
					genericAjaxFail(dlg, resp);
				}
			});
		};

		var dlgLayout = {
				page: 'choose_objects',
				rows: [
					[ { text: 'Select object from the list on the left and press the ">>" button to move it to the exhibit.', klass: 'new_exhibit_instructions' } ],
					[ { custom: obj_selector } ],
					[ { rowClass: 'last_row' }, { button: 'Ok', url: url_update_objects, callback: this.sendWithAjax, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
				]
			};

		var params = { this_id: "edit_exhibit_object_list_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Choose Objects for Exhibit" };
		var dlg = new GeneralDialog(params);
		dlg.changePage('choose_objects', null);
		dlg.center();
		obj_selector.populate(dlg);
	}
});

function doRemoveObjectFromExhibit(exhibit_id, uri)
{
	var reference = $("in_exhibit_" + exhibit_id + "_" + uri);
	if (reference !== null)
		reference.remove();
	new Ajax.Updater("exhibited_objects_container", "/my_collex/remove_exhibited_object", {
		parameters : { uri: uri, exhibit_id: exhibit_id },
		onFailure : function(resp) { genericAjaxFail(null, resp); }
	});
}

