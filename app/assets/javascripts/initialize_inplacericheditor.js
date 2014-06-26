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
/*global GeneralDialog, CreateListOfObjects, LinkDlgHandler, initializeElementEditing, FootnoteAbbrev, FootnotesInRte, serverAction */
/*global gIllustrationTypes */
/*extern initializeInplaceHeaderEditor, initializeInplaceIllustrationEditor, initializeInplaceRichEditor */
/*extern InplaceObjects, inplaceObjectManager */

// Refactoring notes:
// InplaceObjects could become private
// inplaceObjectManager could become private
// initializeInplaceHeaderEditor called in edit_section.html.erb
// initializeInplaceIllustrationEditor called in illustration.html.erb
// initializeInplaceRichEditor called in exhibit_text.html.erb
// gIllustrationTypes should be passed in, instead
// study initializeElementEditing
// find cleaner alternative to prepareDomForEditing that doesn't write weird stuff to the DOM
// see if the initialization is done at the right time with no timeouts

// This is a convenience class with all the common elements needed to initialize any of our inplace types.
// It is a singleton, and it delays the initialization until the Dom is ready. Just call the initDiv method
// after an ajax update, and when loading the page for the first time.

var InplaceObjects = Class.create({
	initialize: function () {
		this.class_type = 'InplaceObjects';	// for debugging

		var inplaceObjects = [];
		var inplaceObjectsAlreadyLoaded = false;

		var initializeInplace = function(element_id, action, setupMethod)
		{
			var getElementBlock = function(el)
			{
				var element = el.up('.element_block');
				if (element === null || element === undefined)
					element = el.up('.element_block_hover');
				return element;
			};

			var prepareDomForEditing = function(element_id, ajax_action_element_id, action, strHoverClass, strShowEditor) {
				var editorHover = function(ev) {
					var el = $(this);
					var hover = el.readAttribute('hoverClass');
					var div = el.down();
					div.addClassName(hover);
				};

				var editorExitHover = function(ev) {
					var el = $(this);
					var hover = el.readAttribute('hoverClass');
					var div = el.down();
					div.removeClassName(hover);
				};

				var el = $(element_id);

				var elWrapper = el.wrap('a');
				el.writeAttribute('action', action);
				el.writeAttribute('ajax_action_element_id', ajax_action_element_id);
				if (strHoverClass !== undefined) {
					elWrapper.writeAttribute('hoverclass', strHoverClass);
					elWrapper.observe('mouseover', editorHover);
					elWrapper.observe('mouseout', editorExitHover);
				}
				if (strShowEditor !== undefined)
					elWrapper.observe('click', strShowEditor);
			};

			// We pass in <div id='text_YY'> as the element_id
			// We want to use <div id="element_XX" class="element_block"> for the ajax call
			// The element_block will be a parent of the element_id object
			var elements = element_id.split(',');
			var el = $(elements[0]);
			var ajax_action_element_id = getElementBlock(el).id;
			if (elements.length > 1)
				ajax_action_element_id = ajax_action_element_id + ',' + elements[1];

			prepareDomForEditing(elements[0], ajax_action_element_id, action, 'richEditorHover', setupMethod);
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
			serverAction({action:{actions: actions, els: action_elements, onSuccess: callback, params: data}});
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
		// There is extra spaces all around
		startingText = startingText.strip();
		while (startingText.startsWith('<div>') && startingText.endsWith('</div>')) {
			startingText = startingText.substring(5);
			startingText = startingText.substring(0, startingText.length-6);
			startingText = startingText.strip();
		}
		if (startingText === 'Welcome to your new exhibit. Click here to enter text, or select another layout from the section editing toolbar above.' ||
			startingText === 'Enter your text here.')
			startingText = '';

		var footnoteHandler = new FootnotesInRte();

		startingText = footnoteHandler.preprocessFootnotes(startingText);

		var ok = function(event, params)
		{
			var data = params.dlg.getAllData();
			data.element_id = element_id;
			data.value = footnoteHandler.postprocessFootnotes(data.value);
			params.dlg.setFlash('Updating Text...', false);
			inplaceObjectManager.ajaxUpdateFromElement($(element_id), data, initializeElementEditing);
			params.dlg.cancel();
		};

		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { textarea: 'value', value: startingText } ],
					[ { rowClass: 'gd_last_row' }, { button: 'Ok', callback: ok, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
				]
			};

		var width = This.getStyle('width');
		width = parseInt(width) + 10 + 10 + 16;	// This adds room for padding on each side and a scrollbar.
		var dlgparams = { this_id: element_id + "builder_text_input_dlg", pages: [ dlgLayout ], body_style: "exhibit_builder_text_dlg", row_style: "gd_message_box_row", title: 'Enter Text', width: width + 'px' };
		var dlg = new GeneralDialog(dlgparams);
		//dlg.changePage('layout', null);

		var idArr = element_id.split('_');
		var id = idArr[idArr.length-1];
		var populate_all = '/forum/get_nines_obj_list';	// TODO-PER: pass this in
		var populate_exhibit_only = '/forum/get_nines_obj_list?element_id=' + id;	// TODO-PER: pass this in
		var progress_img = '/assets/ajax_loader.gif';	// TODO-PER: pass this in
		var fontStyle = This.getStyle('font-family');
		var fontSize = This.getStyle('font-size');
		var style = "html body { font-family: " + fontStyle + "; font-size: " + fontSize + "; }";
		dlg.initTextAreas({ toolbarGroups: [ 'dropcap', 'list', 'link&footnote' ], linkDlgHandler: new LinkDlgHandler([ populate_exhibit_only, populate_all ], progress_img),
			footnote: {callback: footnoteHandler.addFootnote, populate_url: [ populate_exhibit_only, populate_all ], progress_img: progress_img }, bodyStyle: style });
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
		var startingText = $(inner_element_id).innerHTML;
		if (startingText === 'Welcome to your new exhibit. Click here to enter text, or select another layout from the section editing toolbar above.' ||
			startingText === 'Enter your text here.')
			startingText = '';


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

		var idArr = element_id.split(',')[0].split('_');
		var id = idArr[idArr.length-1];
		var populate_all = '/forum/get_nines_obj_list';	// TODO-PER: pass this in
		var populate_exhibit_only = '/forum/get_nines_obj_list?element_id=' + id;	// TODO-PER: pass this in
		var progress_img = '/assets/ajax_loader.gif';	// TODO-PER: pass this in
		var footnoteAbbrev = new FootnoteAbbrev({ startingValue: footnoteStr, field: 'footnote', populate_exhibit_only: populate_exhibit_only, populate_all: populate_all, progress_img: progress_img });

		var dlgLayout = {
			page: 'layout',
			rows: [
				[ { text: 'Header: ', klass: 'new_exhibit_label' }, { input: 'value', value: startingText, klass: 'header_input' }, { custom: footnoteAbbrev }, footnoteAbbrev.createEditButton('footnoteEditStar') ],
				[ { rowClass: 'gd_last_row' }, { button: 'Save', callback: okAction, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
			]
		};

		var dlgParams = { this_id: "header_dlg", pages: [ dlgLayout ], body_style: "edit_header_dlg", row_style: "new_exhibit_row", title: "Enter Header", focus: 'value' };
		var dlg = new GeneralDialog(dlgParams);
		//dlg.changePage('layout', 'value');
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
			else if (hidden.hasClassName('ill_illustration_caption1_bold'))
				values.caption1_bold = hidden.innerHTML;
			else if (hidden.hasClassName('ill_illustration_caption1_italic'))
				values.caption1_italic = hidden.innerHTML;
			else if (hidden.hasClassName('ill_illustration_caption1_underline'))
				values.caption1_underline = hidden.innerHTML;
			else if (hidden.hasClassName('ill_illustration_caption2_bold'))
				values.caption2_bold = hidden.innerHTML;
			else if (hidden.hasClassName('ill_illustration_caption2_italic'))
				values.caption2_italic = hidden.innerHTML;
			else if (hidden.hasClassName('ill_illustration_caption2_underline'))
				values.caption2_underline = hidden.innerHTML;
			else if (hidden.hasClassName('ill_nines_object_uri'))
				values.nines_object = hidden.innerHTML;
			else if (hidden.hasClassName('ill_upload_filename'))
				values.upload_filename = hidden.innerHTML;
		});

		var footnoteHandler = new FootnotesInRte();

		values.ill_text = footnoteHandler.preprocessFootnotes(values.ill_text);

		var selChanged = function(id, currSelection) {
			if (currSelection === gIllustrationTypes[0][0]) {
				$$('.image_only').each(function(el) { el.addClassName('hidden'); });
				$$('.text_only').each(function(el) { el.addClassName('hidden'); });
				$$('.not_nines').each(function(el) { el.addClassName('hidden'); });
				$$('.nines_only').each(function(el) { el.removeClassName('hidden'); });
				$$('.file_only').each(function(el) { el.addClassName('hidden'); });
			} else if (currSelection === gIllustrationTypes[1][0]) {	// External Link
				$$('.nines_only').each(function(el) { el.addClassName('hidden'); });
				$$('.text_only').each(function(el) { el.addClassName('hidden'); });
				$$('.image_only').each(function(el) { el.removeClassName('hidden'); });
				$$('.not_nines').each(function(el) { el.removeClassName('hidden'); });
				$$('.file_only').each(function(el) { el.addClassName('hidden'); });
			} else if (currSelection === gIllustrationTypes[2][0]) {	// Textual Illustration
				$$('.nines_only').each(function(el) { el.addClassName('hidden'); });
				$$('.image_only').each(function(el) { el.addClassName('hidden'); });
				$$('.not_nines').each(function(el) { el.removeClassName('hidden'); });
				$$('.text_only').each(function(el) { el.removeClassName('hidden'); });
				$$('.file_only').each(function(el) { el.addClassName('hidden'); });
			} else if (currSelection === gIllustrationTypes[3][0]) {	// Upload
				$$('.nines_only').each(function(el) { el.addClassName('hidden'); });
				$$('.image_only').each(function(el) { el.addClassName('hidden'); });
				$$('.not_nines').each(function(el) { el.addClassName('hidden'); });
				$$('.text_only').each(function(el) { el.addClassName('hidden'); });
				$$('.file_only').each(function(el) { el.removeClassName('hidden'); });
			}
		};

		var setCaption = function(id) {
			// This is a callback that is called when the user selects a NINES Object.
			var caption = $(id).down(".linkdlg_firstline");
			$('caption1').writeAttribute('value', caption.innerHTML);
			caption = $(id).down(".linkdlg_secondline");
			$('caption2').writeAttribute('value', caption.innerHTML);
		};

		var idArr = element_id.split('_');
		var id = idArr[idArr.length-1];
		var populate_all = '/forum/get_nines_obj_list';	// TODO-PER: pass this in
		var populate_exhibit_only = '/forum/get_nines_obj_list?illustration_id=' + id;	// TODO-PER: pass this in
		//var curr_populate = populate_exhibit_only;
		var progress_img = '/assets/ajax_loader.gif';	// TODO-PER: pass this in

		var objlist = new CreateListOfObjects(populate_exhibit_only, values.nines_object, 'nines_object', progress_img, setCaption);
		objlist.useTabs(populate_all, populate_exhibit_only);
		
		var okAction = function(event, params) {
			// Save has been pressed.
			params.dlg.cancel();

			var data = params.dlg.getAllData();
			data.ill_illustration_id = element_id;
			data.element_id = element_id;
			data.ill_text = footnoteHandler.postprocessFootnotes(data.ill_text);

			params.dlg.setFlash('Updating Illustration...', false);
			objlist.resetCacheIfNecessary();
			if (data.type === gIllustrationTypes[3][0]) {
				var arr = action.split(',');
				submitForm('layout', arr[0]);
			} else
				inplaceObjectManager.ajaxUpdateFromElement($(element_id), data, initializeElementEditing);
		};

		var footnoteAbbrev1 = new FootnoteAbbrev({ startingValue: values.caption1_footnote, field: 'caption1_footnote', populate_exhibit_only: populate_exhibit_only, populate_all: populate_all, progress_img: progress_img });
		var footnoteAbbrev2 = new FootnoteAbbrev({ startingValue: values.caption2_footnote, field: 'caption2_footnote', populate_exhibit_only: populate_exhibit_only, populate_all: populate_all, progress_img: progress_img });

		function getOption(index) {
			// gIllustrationTypes is an array of arrays. The inner array has either one or two items: if it has two items then the second is the text, the first is the value.
			return { text:  gIllustrationTypes[index][gIllustrationTypes[index].length-1], value: gIllustrationTypes[index][0] };
		}

		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { text: 'Type of Illustration:', klass: 'edit_illustration_caption_label' }, { select: 'type', callback: selChanged, value: values.type, options: [getOption(0), getOption(1), getOption(2), getOption(3)] },
						{ hidden: 'ill_illustration_id', value: element_id }, { hidden: 'element_id', value: element_id }],
					[ { text: 'First Caption:', klass: 'edit_illustration_caption_label' }, { inputWithStyle: 'caption1', value: { text: values.caption1, isBold: values.caption1_bold === '1', isItalic: values.caption1_italic === '1', isUnderline: values.caption1_underline === '1' }, klass: 'header_input' },
						{ custom: footnoteAbbrev1 }, footnoteAbbrev1.createEditButton('footnoteEditStar') ],
					[ { text: 'Second Caption:', klass: 'edit_illustration_caption_label' }, { inputWithStyle: 'caption2', value: { text: values.caption2, isBold: values.caption2_bold === '1', isItalic: values.caption2_italic === '1', isUnderline: values.caption2_underline === '1' }, klass: 'header_input' },
						{ custom: footnoteAbbrev2 }, footnoteAbbrev2.createEditButton('footnoteEditStar2') ],

					[ { text: 'Sort objects by:', klass: 'forum_reply_label nines_only hidden' },
						{ select: 'sort_by', callback: objlist.sortby, klass: 'link_dlg_select nines_only hidden', value: 'date_collected', options: [{ text:  'Date Collected', value:  'date_collected' }, { text:  'Title', value:  'title' }, { text:  'Author', value:  'author' }] },
						{ text: 'and', klass: 'link_dlg_label_and nines_only hidden' }, { inputFilter: 'filterObjects', klass: 'nines_only hidden', prompt: 'type to filter objects', callback: objlist.filter } ],
					[ { text: 'Image URL:', klass: 'edit_illustration_label_lined_up image_only hidden' }, { input: 'image_url', value: values.image_url, klass: 'new_exhibit_input_long image_only hidden' },
					  { link: "Exhibit Palette", klass: 'dlg_tab_link_current nines_only hidden', callback: objlist.ninesObjView, arg0: 'exhibit' }, { link: "All My Objects", klass: 'dlg_tab_link nines_only hidden', callback: objlist.ninesObjView, arg0: 'all' },
						{ text: "Upload Image:", klass: 'edit_illustration_label_lined_up file_only hidden'}, { image: 'uploaded_image', size: 60, klass: 'edit_illustration_upload file_only hidden', value: values.upload_filename, no_iframe: true }],
					[ { text: 'Link URL:', klass: 'edit_illustration_label_lined_up not_nines hidden' }, { input: 'link_url', value: values.link_url, klass: 'new_exhibit_input_long not_nines hidden' }, { custom: objlist, klass: 'dlg_tab_contents nines_only hidden' } ],
					[ { textarea: 'ill_text', klass: 'edit_facet_textarea text_only', value: values.ill_text } ],
					[ { text: 'Alt Text:', klass: 'edit_illustration_label_lined_up image_only hidden' }, { input: 'alt_text', value: values.alt_text, klass: 'new_exhibit_input_long image_only hidden' } ],
					[ { rowClass: 'gd_last_row' }, { button: 'Save', callback: okAction, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
				]
			};

		var dlgParams = { this_id: "illustration_dlg", pages: [ dlgLayout ], body_style: "edit_illustration_dlg", row_style: "new_exhibit_row", title: "Edit Illustration", focus: 'illustration_dlg_sel0' };
		var dlg = new GeneralDialog(dlgParams);
		dlg.initTextAreas({ toolbarGroups: [ 'fontstyle', 'alignment', 'list', 'link&footnote' ], linkDlgHandler: new LinkDlgHandler([ populate_exhibit_only, populate_all ], progress_img),
			footnote: {callback: footnoteHandler.addFootnote, populate_url: [ populate_exhibit_only, populate_all ], progress_img: progress_img } });
		//dlg.changePage('layout', 'illustration_dlg_sel0');
		objlist.populate(dlg, true, 'illust');
		selChanged(null, values.type);
		dlg.center();
	};

	inplaceObjectManager.initDiv(element_id, action, showIllustrationEditor);
}
