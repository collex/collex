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

//This contains the glue code between the input_dialog object and the HTML elements
//that the user is able to click on to edit. To use, pass in the element_id and the callback
//URL that will report the user's changes. There is an entry point for each type of popup
//dialog that should be displayed.

/*global document */
/*global $, $$, Ajax, Class */
/*global MessageBoxDlg, GeneralDialog, CreateListOfObjects, InputDialog, LinkDlgHandler, getX, getY, initializeElementEditing */
/*global gIllustrationTypes */
/*extern CreateList, doSelectionChanged, initializeInplaceHeaderEditor, initializeInplaceIllustrationEditor, initializeInplaceRichEditor, showIllustrationEditor, showRichEditor */

var inplaceObjects = [];
var inplaceObjectsAlreadyLoaded = false;

function getElementBlock(el)
{
	var element = el.up('.element_block');
	if (element === null || element === undefined)
		element = el.up('.element_block_hover');
	return element;
}

function showIllustrationEditor(event)
{
	var This = $(this).down();
	var element_id = This.id;

	// The parameter is the < id="element_id" > tag that was originally passed in during initialization
	// That is, el = <div id='illustration_YY' class="illustration_block">

	// Now populate a hash with all the starting values.
	// directly below element_id are all the hidden fields with the data we want to use to populate the dialog with

	var values = {};

	// Initialize the controls in the dialog from the hidden fields on the page.
	// All the hidden fields have a class of "saved_data". They also have a second class
	// with the name of the variable they represent.
	var hidden_data = $$('#' + element_id + ' .saved_data');
	hidden_data.each(function(hidden) {
		if (hidden.hasClassName('ill_illustration_type'))
			values.type = hidden.innerHTML;
		else if (hidden.hasClassName('ill_image_url'))
			values.image_url = hidden.innerHTML;
		else if (hidden.hasClassName('ill_link'))
			values.link_url = hidden.innerHTML;
		else if (hidden.hasClassName('ill_image_width'))
			values.ill_width = hidden.innerHTML;
		else if (hidden.hasClassName('ill_illustration_text'))
			values.ill_text = hidden.innerHTML;
		else if (hidden.hasClassName('ill_illustration_alt_text'))
			values.alt_text = hidden.innerHTML;
		else if (hidden.hasClassName('ill_illustration_caption1'))
			values.caption1 = hidden.innerHTML;
		else if (hidden.hasClassName('ill_illustration_caption2'))
			values.caption2 = hidden.innerHTML;
		else if (hidden.hasClassName('ill_nines_object_uri'))
			values.nines_object = hidden.innerHTML;
	});

	// We also need to set the hidden fields on our form. This is the mechanism
	// for passing back the context to the controller.
	values.ill_illustration_id = element_id;
	values.element_id = element_id;

	var selChanged = function(id, currSelection) {
		if (currSelection === gIllustrationTypes[0]) {
			$$('.image_only').each(function(el) { el.addClassName('hidden'); });
			$$('.text_only').each(function(el) { el.addClassName('hidden'); });
			$$('.not_nines').each(function(el) { el.addClassName('hidden'); });
			$$('.nines_only').each(function(el) { el.removeClassName('hidden'); });
		} else if (currSelection === gIllustrationTypes[1]) {	// External Link
			$$('.nines_only').each(function(el) { el.addClassName('hidden'); });
			$$('.text_only').each(function(el) { el.addClassName('hidden'); });
			$$('.image_only').each(function(el) { el.removeClassName('hidden'); });
			$$('.not_nines').each(function(el) { el.removeClassName('hidden'); });
		} else if (currSelection === gIllustrationTypes[2]) {	// Textual Illustration
			$$('.nines_only').each(function(el) { el.addClassName('hidden'); });
			$$('.image_only').each(function(el) { el.addClassName('hidden'); });
			$$('.not_nines').each(function(el) { el.removeClassName('hidden'); });
			$$('.text_only').each(function(el) { el.removeClassName('hidden'); });
		}
	};

	var cancel = function(event, params)
	{
		params.dlg.cancel();
	};

	// TODO-PER: Make this generic: probably put in general_dialog
	var ajaxUpdateFromElement = function(el, data, callback) {
		var action = el.readAttribute('action');
		var ajax_action_element_id = el.readAttribute('ajax_action_element_id');

		// If we have a comma separated list, we want to send the request synchronously to each action
		// (Doing this synchronously eliminates any race condition: The first call can update the data and
		// the rest of the calls just update the page.
		var actions = action.split(',');
		var action_elements = ajax_action_element_id.split(',');
		if (actions.length === 1)
		{
			new Ajax.Updater(ajax_action_element_id, action, {
				parameters : data,
				evalScripts : true,
				onComplete : initializeElementEditing,
				onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
			});
		}
		else
		{
			new Ajax.Updater(action_elements[0], actions[0], {
				parameters : data,
				evalScripts : true,
				onComplete: function(resp) {
					new Ajax.Updater(action_elements[1], actions[1], {
						parameters : data,
						evalScripts : true,
						onComplete : initializeElementEditing,
						onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
					});
				},
				onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
			});
		}
	};

	var setCaption = function(id) {
		// This is a callback that is called when the user selects a NINES Object.
		var caption = $(id).down(".linkdlg_firstline");
		$('caption1').writeAttribute('value', caption.innerHTML);
		caption = $(id).down(".linkdlg_secondline");
		$('caption2').writeAttribute('value', caption.innerHTML);
	};

	var okAction = function(event, params) {
		// Save has been pressed.
		var url = params.destination;
		var dlg = params.dlg;
		var data = dlg.getAllData();
		data.ill_illustration_id = element_id;
		data.element_id = element_id;

		dlg.setFlash('Updating Illustration...', false);
		ajaxUpdateFromElement($(element_id), data, initializeElementEditing);

		params.dlg.cancel();
	};

	var populate_nines_obj_url = '/forum/get_nines_obj_list';	// TODO-PER: pass this in
	var progress_img = '/images/ajax_loader.gif';	// TODO-PER: pass this in
	var objlist = new CreateListOfObjects(populate_nines_obj_url, values.nines_object, 'nines_object', progress_img, setCaption);

	var dlgLayout = {
			page: 'layout',
			rows: [
				[ { text: 'Type of Illustration:', klass: 'new_exhibit_label' }, { select: 'type', change: selChanged, value: values.type, options: [{ text:  gIllustrationTypes[0], value: gIllustrationTypes[0] }, { text:  gIllustrationTypes[1], value: gIllustrationTypes[1] }, { text:  gIllustrationTypes[2], value: gIllustrationTypes[2] }] } ],
				[ { text: 'First Caption:', klass: 'new_exhibit_label' }, { input: 'caption1', value: values.caption1, klass: 'new_exhibit_input_long' } ],
				[ { text: 'Second Caption:', klass: 'new_exhibit_label' }, { input: 'caption2', value: values.caption2, klass: 'new_exhibit_input_long' } ],

				[ { text: 'Image URL:', klass: 'new_exhibit_label image_only hidden' }, { input: 'image_url', value: values.image_url, klass: 'new_exhibit_input_long image_only hidden' },
				  { custom: objlist, klass: 'new_exhibit_label nines_only hidden' } ],
				[ { text: 'Link URL:', klass: 'new_exhibit_label not_nines hidden' }, { input: 'link_url', value: values.link_url, klass: 'new_exhibit_input_long not_nines hidden' } ],
				[ { textarea: 'ill_text', klass: 'edit_facet_textarea text_only', value: values.ill_text } ],
				[ { text: 'Alt Text:', klass: 'new_exhibit_label image_only hidden' }, { input: 'alt_text', value: values.alt_text, klass: 'new_exhibit_input_long image_only hidden' } ],
				[ { button: 'Save', callback: okAction }, { button: 'Cancel', callback: cancel } ]
			]
		};

	var dlgParams = { this_id: "illustration_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Set Link" };
	var dlg = new GeneralDialog(dlgParams);
	dlg.initTextAreas([ 'font', 'fontstyle', 'alignment', 'list', 'link' ], new LinkDlgHandler(populate_nines_obj_url, progress_img));
	dlg.changePage('layout', null);
	objlist.populate(dlg, true, 'illust');
	selChanged(null, values.type);
	dlg.center();
}

function initializeInplaceIllustrationEditor_(element_id, action)
{
	// We pass in <div id='illustration_YY' class="illustration_block"> as the element_id
	// We want to use <div id="element_XX" class="element_block"> for the ajax call
	// The element_block will be a parent of the element_id object
	var elements = element_id.split(',');
	var el = $(elements[0]);
	var ajax_action_element_id = getElementBlock(el).id;
	if (elements.length > 1)
		ajax_action_element_id = ajax_action_element_id + ',' + elements[1];

	InputDialog.prototype.prepareDomForEditing(elements[0], ajax_action_element_id, action, 'richEditorHover', showIllustrationEditor);
}

function initializeInplace(element_id, action, setupMethod)
{
	// We pass in <div id='text_YY'> as the element_id
	// We want to use <div id="element_XX" class="element_block"> for the ajax call
	// The element_block will be a parent of the element_id object
	var elements = element_id.split(',');
	var el = $(elements[0]);
	var ajax_action_element_id = getElementBlock(el).id;
	if (elements.length > 1)
		ajax_action_element_id = ajax_action_element_id + ',' + elements[1];

	InputDialog.prototype.prepareDomForEditing(elements[0], ajax_action_element_id, action, 'richEditorHover', setupMethod);
}

// Delay modifying the DOM until after the page has loaded because IE 7 gives the "internet explorer cannot open the internet site" message.
 document.observe('dom:loaded', function() {
 	inplaceObjects.each(function(obj) {
		if (obj.type === 'illustration')
			initializeInplaceIllustrationEditor_(obj.element_id, obj.action);
		else
			initializeInplace(obj.element_id, obj.action, obj.setupMethod);
	});
	inplaceObjectsAlreadyLoaded = true;
 });

function showRichEditor(event)
{
	var This = $(this).down();
	var element_id = This.id;

	// The parameter is the < id="element_id" > tag that was originally passed in during initialization
	// That is, el = <div id='text_YY'>

	// First construct the dialog
	var dlg = new InputDialog(element_id);
    dlg.addHidden("element_id");

//	var extraButton = {
//		id : 'ninesobj',
//		insertionPoint : 'redo,|',
//		title :  'Link to NINES object',
//		image : '/images/mce_link_to_nines_obj.gif',
//		onclick : 'showNinesObjectDlg(ed);'
//	};

	var populate_nines_obj_url = '/forum/get_nines_obj_list';	// TODO-PER: pass this in
	var progress_img = '/images/ajax_loader.gif';	// TODO-PER: pass this in
	dlg.addTextArea('value', 600, 100, null, [ 'font', 'dropcap', 'list', 'link' ], new LinkDlgHandler(populate_nines_obj_url, progress_img));

	// Now populate a hash with all the starting values.
	// directly below element_id are all the hidden fields with the data we want to use to populate the dialog with

	var values = {};

	var downDiv = $(element_id).down('.exhibit_text');
	if (downDiv !== null && downDiv !== undefined)
		values.value = downDiv.innerHTML;
	else
		values.value = $(element_id).innerHTML;

	// We also need to set the hidden fields on our form. This is the mechanism
	// for passing back the context to the controller.
	values.element_id = element_id;

	// Now, everything is initialized, fire up the dialog.
	var el = $(element_id);
	dlg.show("Enter Text", getX(el), getY(el), 600, 300, values );
	dlg.centerEditor();
	return false;
}

function initializeInplaceRichEditor(element_id, action)
{
	if (!inplaceObjectsAlreadyLoaded)
	{
		var obj = { element_id: element_id, action: action, setupMethod: showRichEditor, type: 'inplace' };
		inplaceObjects.push(obj);
	}
	else
		initializeInplace(element_id, action, showRichEditor);
}

function initializeInplaceHeaderEditor(element_id, action)
{
	var showHeaderEditor = function(event)
	{
		var This = $(this).down();
		var element_id = This.id;

		// The parameter is the < id="element_id" > tag that was originally passed in during initialization
		// That is, el = <div id='header_YY'>

		// First construct the dialog
		var dlg = new InputDialog(element_id);
		dlg.addHidden("element_id");

		dlg.addTextInput('Header:', 'value', 40);

		// Now populate a hash with all the starting values.
		// directly below element_id are all the hidden fields with the data we want to use to populate the dialog with

		var values = {};

		values.value = $(element_id).down().innerHTML;

		// We also need to set the hidden fields on our form. This is the mechanism
		// for passing back the context to the controller.
		values.element_id = element_id;

		// Now, everything is initialized, fire up the dialog.
		var el = $(element_id);
		dlg.show("Enter Header", getX(el), getY(el), 380, 100, values );
		var prompt = $('value');
		prompt.focus();
		prompt.select();
	};

	if (!inplaceObjectsAlreadyLoaded)
	{
		var obj = { element_id: element_id, action: action, setupMethod: showHeaderEditor, type: 'inplace' };
		inplaceObjects.push(obj);
	}
	else
		initializeInplace(element_id, action, showHeaderEditor);
}

function initializeInplaceIllustrationEditor(element_id, action)
{
	if (!inplaceObjectsAlreadyLoaded)
	{
		var obj = { element_id: element_id, action: action, type: 'illustration' };
		inplaceObjects.push(obj);
	}
	else
		 initializeInplaceIllustrationEditor_(element_id, action);
}

/////////////////////////////////////////////////////////////////////////////////////////
// Private functions
/////////////////////////////////////////////////////////////////////////////////////////

function doSelectionChanged(currSelection)
{
	// This is a callback that is fired whenever the user changes the select
	// box while editing illustrations. It is also fired when the dialog first
	// is displayed.
	var image_only = $$('.image_only');
	var text_only = $$ ('.text_only');
	var nines_only = $$ ('.nines_only');
	var not_nines = $$ ('.not_nines');
	if (currSelection === gIllustrationTypes[1]) {	// image
		image_only.each(function(el) { el.show(); });
		not_nines.each(function(el) { el.show(); });
		nines_only.each(function(el) { el.hide(); });
		text_only.each(function(el) { el.hide(); });
	} else if (currSelection === gIllustrationTypes[0]) {	// nines object
		image_only.each(function(el) { el.hide(); });
		not_nines.each(function(el) { el.hide(); });
		nines_only.each(function(el) { el.show(); });
		text_only.each(function(el) { el.hide(); });
	} else if (currSelection === gIllustrationTypes[2]) {	// text
		image_only.each(function(el) { el.hide(); });
		not_nines.each(function(el) { el.show(); });
		nines_only.each(function(el) { el.hide(); });
		text_only.each(function(el) { el.show(); });
	}
}

function selectionChanged(event)
{
	var This = $(this);
	var currSelection = This.value;
	doSelectionChanged(currSelection);
}

var CreateList = Class.create({
	list : null,
	initialize : function(items, className, initial_selected_uri, value_field)
	{
		this.value_field = value_field;
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
		items.each(function(obj) {
//			if (initial_selected_uri === "")	// If nothing is selected, then automatically select the first one.
//				initial_selected_uri = obj.uri;
			This.list += This.constructItem(obj.uri, obj.thumbnail, obj.title, obj.uri === initial_selected_uri, value_field);
		});
		This.list += "</table>";
		if (items.length > 10)
			This.list += "</div>";
	},
	
	constructItem: function(uri, thumbnail, title, is_selected, value_field)
	{
		var str = "";
		if (is_selected)
			str = " class='input_dlg_list_item_selected' ";
		return "<tr " + str + "onclick='CreateList.prototype._select(this,\"" + value_field + "\" );' uri='" + uri + "' ><td><img src='" + thumbnail + "' alt='' height='40' /></td><td>" + title + "</td></tr>\n";
	},
	
	makeSureThereIsASelection: function() {
		var sel = $$('.input_dlg_list .input_dlg_list_item_selected');
		if (sel.length > 0)
			return;
			
		var el = $$(".input_dlg_list tr");
		if (el.length > 0)
			this.select(el[0], this.value_field);
	}
});

CreateList.prototype.select = function(item, value_field)
{
	var selClass = "input_dlg_list_item_selected";
	$$("." + selClass).each(function(el)
	{
		el.removeClassName(selClass);
	});
	$(item).addClassName(selClass);
	$(value_field).value = $(item).getAttribute('uri');
	var caption = $('caption1');
	if (caption !== null)
		caption.value = $(item).down().next().innerHTML;
};


