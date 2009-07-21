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
/*global $, $$, Class */
/*global GeneralDialog, CreateListOfObjects, InputDialog, LinkDlgHandler, initializeElementEditing, FootnoteAbbrev, FootnotesInRte, recurseUpdateWithAjax */
/*global gIllustrationTypes */
/*extern initializeInplaceHeaderEditor, initializeInplaceIllustrationEditor, initializeInplaceRichEditor */
/*extern InplaceObjects, inplaceObjectManager */

// This is a convenience class with all the common elements needed to initialize any of our inplace types.
// It is a singleton, and it delays the initialization until the Dom is ready. Just call the initDiv method
// after an ajax update, and when loading the page for the first time.
var InplaceObjects = Class.create({
	initialize: function () {
		this.class_type = 'InplaceObjects';	// for debugging

		var inplaceObjects = [];
		var inplaceObjectsAlreadyLoaded = false;

		var getElementBlock = function(el)
		{
			var element = el.up('.element_block');
			if (element === null || element === undefined)
				element = el.up('.element_block_hover');
			return element;
		};

		var initializeInplace = function(element_id, action, setupMethod)
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
		};

		// Delay modifying the DOM until after the page has loaded because IE 7 gives the "internet explorer cannot open the internet site" message.
		 document.observe('dom:loaded', function() {
			inplaceObjects.each(function(obj) {
				initializeInplace(obj.element_id, obj.action, obj.setupMethod);
			});
			inplaceObjectsAlreadyLoaded = true;
		 });

		this.initDiv = function(element_id, action, setupMethod) {
			if (!inplaceObjectsAlreadyLoaded)
			{
				var obj = { element_id: element_id, action: action, setupMethod: setupMethod };
				inplaceObjects.push(obj);
			}
			else
				 initializeInplace(element_id, action, setupMethod);
		};
		this.ajaxUpdateFromElement = function(el, data, callback) {
			var action = el.readAttribute('action');
			var ajax_action_element_id = el.readAttribute('ajax_action_element_id');

			// If we have a comma separated list, we want to send the request synchronously to each action
			// (Doing this synchronously eliminates any race condition: The first call can update the data and
			// the rest of the calls just update the page.
			var actions = action.split(',');
			var action_elements = ajax_action_element_id.split(',');
			recurseUpdateWithAjax(actions, action_elements, callback, null, data);
		};
	}
});

var inplaceObjectManager = new InplaceObjects();

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function initializeInplaceRichEditor(element_id, action)
{
	var showRichEditor = function(event)
	{
		var This = $(this).down();
		var element_id = This.id;

		// The parameter is the < id="element_id" > tag that was originally passed in during initialization
		// That is, el = <div id='text_YY'>

		// Now populate a hash with all the starting values.
		// directly below element_id are all the hidden fields with the data we want to use to populate the dialog with

		var startingText = "";

		var downDiv = $(element_id).down('.exhibit_text');
		if (downDiv !== null && downDiv !== undefined)
			startingText = downDiv.innerHTML;
		else
			startingText = $(element_id).innerHTML;

		var footnoteHandler = new FootnotesInRte();

		startingText = footnoteHandler.preprocessFootnotes(startingText);

		var ok = function(event, params)
		{
			params.dlg.cancel();

			var data = params.dlg.getAllData();
			data.element_id = element_id;
			data.value = footnoteHandler.postprocessFootnotes(data.value);
			params.dlg.setFlash('Updating Text...', false);
			inplaceObjectManager.ajaxUpdateFromElement($(element_id), data, initializeElementEditing);
		};

		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { textarea: 'value', value: startingText } ],
					[ { rowClass: 'last_row' }, { button: 'Ok', callback: ok, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
				]
			};

		var dlgparams = { this_id: element_id + "builder_text_input_dlg", pages: [ dlgLayout ], body_style: "message_box_dlg", row_style: "message_box_row", title: 'Enter Text' };
		var dlg = new GeneralDialog(dlgparams);
		dlg.changePage('layout', null);

		var populate_nines_obj_url = '/forum/get_nines_obj_list';	// TODO-PER: pass this in
		var progress_img = '/images/ajax_loader.gif';	// TODO-PER: pass this in
		dlg.initTextAreas([ 'font', 'dropcap', 'list', 'link&footnote' ], new LinkDlgHandler(populate_nines_obj_url, progress_img), footnoteHandler.addFootnote);
		dlg.center();

		var input = $('value');
		input.select();
		input.focus();
		return false;
	};

	inplaceObjectManager.initDiv(element_id, action, showRichEditor);
}

function initializeInplaceHeaderEditor(element_id, action)
{
	var showHeaderEditor = function(event)
	{
		var This = $(this).down();
		var inner_element_id = 'inner_' + This.id;

		// The parameter is the < id="element_id" > tag that was originally passed in during initialization
		// That is, el = <div id='header_YY'>

		var footnoteDiv = $('footnote_for_' + This.id);
		var footnoteStr = footnoteDiv ? footnoteDiv.innerHTML : "";

		var okAction = function(event, params) {
			// Save has been pressed.
			var el_id = element_id.split(',')[0];
			var dlg = params.dlg;
			var data = dlg.getAllData();
			data.element_id = el_id;

			dlg.setFlash('Updating Header...', false);
			inplaceObjectManager.ajaxUpdateFromElement($(el_id), data, initializeElementEditing);

			params.dlg.cancel();
		};

		var dlgLayout = {
			page: 'layout',
			rows: [
				[ { text: 'Header:', klass: 'new_exhibit_label' }, { input: 'value', value: $(inner_element_id).innerHTML, klass: 'header_input' }, { button: "*", callback: function() { new MessageBoxDlg("TODO", "This will be a graphic image, have a tooltip, and also bring up the edit footnote dlg."); } } ],
				[ { custom: new FootnoteAbbrev(footnoteStr, 'footnote') }],
				[ { rowClass: 'last_row' }, { button: 'Save', callback: okAction, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
			]
		};

		var dlgParams = { this_id: "header_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Enter Header" };
		var dlg = new GeneralDialog(dlgParams);
		dlg.changePage('layout', null);
		dlg.center();
	};

	inplaceObjectManager.initDiv(element_id, action, showHeaderEditor);
}

function initializeInplaceIllustrationEditor(element_id, action)
{
	var showIllustrationEditor = function(event)
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
			else if (hidden.hasClassName('ill_illustration_caption1_footnote'))
				values.caption1_footnote = hidden.innerHTML;
			else if (hidden.hasClassName('ill_illustration_caption2_footnote'))
				values.caption2_footnote = hidden.innerHTML;
			else if (hidden.hasClassName('ill_nines_object_uri'))
				values.nines_object = hidden.innerHTML;
		});

		var footnoteHandler = new FootnotesInRte();

		values.ill_text = footnoteHandler.preprocessFootnotes(values.ill_text);

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

		var setCaption = function(id) {
			// This is a callback that is called when the user selects a NINES Object.
			var caption = $(id).down(".linkdlg_firstline");
			$('caption1').writeAttribute('value', caption.innerHTML);
			caption = $(id).down(".linkdlg_secondline");
			$('caption2').writeAttribute('value', caption.innerHTML);
		};

		var okAction = function(event, params) {
			// Save has been pressed.
			params.dlg.cancel();

			var data = params.dlg.getAllData();
			data.ill_illustration_id = element_id;
			data.element_id = element_id;
			data.ill_text = footnoteHandler.postprocessFootnotes(data.ill_text);

			params.dlg.setFlash('Updating Illustration...', false);
			inplaceObjectManager.ajaxUpdateFromElement($(element_id), data, initializeElementEditing);
		};

		var populate_nines_obj_url = '/forum/get_nines_obj_list';	// TODO-PER: pass this in
		var progress_img = '/images/ajax_loader.gif';	// TODO-PER: pass this in
		var objlist = new CreateListOfObjects(populate_nines_obj_url, values.nines_object, 'nines_object', progress_img, setCaption);

		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { text: 'Type of Illustration:', klass: 'new_exhibit_label' }, { select: 'type', change: selChanged, value: values.type, options: [{ text:  gIllustrationTypes[0], value: gIllustrationTypes[0] }, { text:  gIllustrationTypes[1], value: gIllustrationTypes[1] }, { text:  gIllustrationTypes[2], value: gIllustrationTypes[2] }] } ],
					[ { text: 'First Caption:', klass: 'new_exhibit_label' }, { input: 'caption1', value: values.caption1, klass: 'header_input' }, { button: "*", callback: function() { new MessageBoxDlg("TODO", "This will be a graphic image, have a tooltip, and also bring up the edit footnote dlg."); }} ],
					[ { custom: new FootnoteAbbrev(values.caption1_footnote, 'caption1_footnote') }],
					[ { text: 'Second Caption:', klass: 'new_exhibit_label' }, { input: 'caption2', value: values.caption2, klass: 'header_input' }, { button: "*", callback: function() { new MessageBoxDlg("TODO", "This will be a graphic image, have a tooltip, and also bring up the edit footnote dlg."); }} ],
					[ { custom: new FootnoteAbbrev(values.caption2_footnote, 'caption2_footnote') }],

					[ { text: 'Image URL:', klass: 'new_exhibit_label image_only hidden' }, { input: 'image_url', value: values.image_url, klass: 'new_exhibit_input_long image_only hidden' },
					  { custom: objlist, klass: 'new_exhibit_label nines_only hidden' } ],
					[ { text: 'Link URL:', klass: 'new_exhibit_label not_nines hidden' }, { input: 'link_url', value: values.link_url, klass: 'new_exhibit_input_long not_nines hidden' } ],
					[ { textarea: 'ill_text', klass: 'edit_facet_textarea text_only', value: values.ill_text } ],
					[ { text: 'Alt Text:', klass: 'new_exhibit_label image_only hidden' }, { input: 'alt_text', value: values.alt_text, klass: 'new_exhibit_input_long image_only hidden' } ],
					[ { rowClass: 'last_row' }, { button: 'Save', callback: okAction }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
				]
			};

		var dlgParams = { this_id: "illustration_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Edit Illustration" };
		var dlg = new GeneralDialog(dlgParams);
		dlg.initTextAreas([ 'font', 'fontstyle', 'alignment', 'list', 'link&footnote' ], new LinkDlgHandler(populate_nines_obj_url, progress_img), footnoteHandler.addFootnote);
		dlg.changePage('layout', null);
		objlist.populate(dlg, true, 'illust');
		selChanged(null, values.type);
		dlg.center();
	};

	inplaceObjectManager.initDiv(element_id, action, showIllustrationEditor);
}
