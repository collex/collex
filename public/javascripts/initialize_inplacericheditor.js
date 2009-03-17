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

var _inplaceObjects = [];
var _inplaceObjectsAlreadyLoaded = false;

// Delay modifying the DOM until after the page has loaded because IE 7 gives the "internet explorer cannot open the internet site" message.
 document.observe('dom:loaded', function() {
 	_inplaceObjects.each(function(obj) {
		if (obj.type == 'illustration')
			_initializeInplaceIllustrationEditor(obj.element_id, obj.action)
		else
			_initializeInplace(obj.element_id, obj.action, obj.setupMethod);
	});
	_inplaceObjectsAlreadyLoaded = true;
 });

function initializeInplaceRichEditor(element_id, action)
{
	if (!_inplaceObjectsAlreadyLoaded)
	{
		var obj = { element_id: element_id, action: action, setupMethod: showRichEditor, type: 'inplace' };
		_inplaceObjects.push(obj);
	}
	else
		_initializeInplace(element_id, action, showRichEditor);
}

function initializeInplaceHeaderEditor(element_id, action)
{
	if (!_inplaceObjectsAlreadyLoaded)
	{
		var obj = { element_id: element_id, action: action, setupMethod: showHeaderEditor, type: 'inplace' };
		_inplaceObjects.push(obj);
	}
	else
		_initializeInplace(element_id, action, showHeaderEditor);
}

function _initializeInplace(element_id, action, setupMethod)
{
	// We pass in <div id='text_YY'> as the element_id
	// We want to use <div id="element_XX" class="element_block"> for the ajax call
	// The element_block will be a parent of the element_id object
	var elements = element_id.split(',');
	var el = $(elements[0]);
	var ajax_action_element_id = el.up('.element_block').id;
	if (elements.length > 1)
		ajax_action_element_id = ajax_action_element_id + ',' + elements[1];

	InputDialog.prototype.prepareDomForEditing(elements[0], ajax_action_element_id, action, 'richEditorHover', setupMethod);
}

function initializeInplaceIllustrationEditor(element_id, action)
{
	if (!_inplaceObjectsAlreadyLoaded)
	{
		var obj = { element_id: element_id, action: action, type: 'illustration' };
		_inplaceObjects.push(obj);
	}
	else
		 _initializeInplaceIllustrationEditor(element_id, action);
}

function _initializeInplaceIllustrationEditor(element_id, action)
{
	// We pass in <div id='illustration_YY' class="illustration_block"> as the element_id
	// We want to use <div id="element_XX" class="element_block"> for the ajax call
	// The element_block will be a parent of the element_id object
	var elements = element_id.split(',');
	var el = $(elements[0]);
	var ajax_action_element_id = el.up('.element_block').id;
	if (elements.length > 1)
		ajax_action_element_id = ajax_action_element_id + ',' + elements[1];

	InputDialog.prototype.prepareDomForEditing(elements[0], ajax_action_element_id, action, 'richEditorHover', showIllustrationEditor);
}

/////////////////////////////////////////////////////////////////////////////////////////
// Private functions
/////////////////////////////////////////////////////////////////////////////////////////

function selectionChanged(event)
{
	var This = $(this);
	var currSelection = This.value;
	doSelectionChanged(currSelection);
}

function doSelectionChanged(currSelection)
{
	// This is a callback that is fired whenever the user changes the select
	// box while editing illustrations. It is also fired when the dialog first
	// is displayed.
	var image_only = $$('.image_only');
	var text_only = $$ ('.text_only');
	var nines_only = $$ ('.nines_only');
	var not_nines = $$ ('.not_nines');
	if (currSelection == gIllustrationTypes[1]) {	// image
		image_only.each(function(el) { el.show(); });
		not_nines.each(function(el) { el.show(); });
		nines_only.each(function(el) { el.hide(); });
		text_only.each(function(el) { el.hide(); });
	} else if (currSelection == gIllustrationTypes[0]) {	// nines object
		image_only.each(function(el) { el.hide(); });
		not_nines.each(function(el) { el.hide(); });
		nines_only.each(function(el) { el.show(); });
		text_only.each(function(el) { el.hide(); });
	} else if (currSelection == gIllustrationTypes[2]) {	// text
		image_only.each(function(el) { el.hide(); });
		not_nines.each(function(el) { el.show(); });
		nines_only.each(function(el) { el.hide(); });
		text_only.each(function(el) { el.show(); });
	}
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
			values['type'] = hidden.innerHTML;
		else if (hidden.hasClassName('ill_image_url'))
			values['image_url'] = hidden.innerHTML;
		else if (hidden.hasClassName('ill_link'))
			values['link_url'] = hidden.innerHTML;
		else if (hidden.hasClassName('ill_image_width'))
			values['ill_width'] = hidden.innerHTML;
		else if (hidden.hasClassName('ill_illustration_text'))
			values['ill_text'] = hidden.innerHTML;
		else if (hidden.hasClassName('ill_illustration_alt_text'))
			values['alt_text'] = hidden.innerHTML;
		else if (hidden.hasClassName('ill_illustration_caption1'))
			values['caption1'] = hidden.innerHTML;
		else if (hidden.hasClassName('ill_illustration_caption2'))
			values['caption2'] = hidden.innerHTML;
		else if (hidden.hasClassName('ill_nines_object_uri'))
			values['nines_object'] = hidden.innerHTML;
	});

	// We also need to set the hidden fields on our form. This is the mechanism
	// for passing back the context to the controller.
	values['ill_illustration_id'] = element_id;
	values['element_id'] = element_id; 
	
	// First construct the dialog
	var dlg = new InputDialog(element_id);
    dlg.addHidden("ill_illustration_id");
	
	var size = 52;
	dlg.addSelect('Type of Illustration:', 'type', gIllustrationTypes, selectionChanged);
	dlg.addTextInput('First Caption:', 'caption1', size);
	dlg.addTextInput('Second Caption:', 'caption2', size);
	dlg.addHr();
	dlg.addTextInput('Image URL:', 'image_url', size, 'image_only');
	dlg.addTextInput('Link URL:', 'link_url', size, 'not_nines');
	dlg.addTextInput('Alt Text:', 'alt_text', size, 'image_only');
	//dlg.addTextInput('Width:', 'ill_width', size, 'image_only');
	dlg.addTextArea('ill_text', 300, 100, 'text_only', [ 'alignment' ], new LinkDlgHandler);
	var list = new CreateList(gCollectedObjects, 'nines_only', values['nines_object'], 'nines_object');
	dlg.addList('nines_object', list.list, 'nines_only');

	var onCompleteCallback = function() {
		initializeElementEditing();
		};
	dlg.setCompleteCallback(onCompleteCallback);

	// Now, everything is initialized, fire up the dialog.
	var el = $(element_id);
	dlg.show("Edit Illustration", getX(el), getY(el), 530, 350, values );
	doSelectionChanged(values['type']);
}

LinkDlgHandler = Class.create();

LinkDlgHandler.prototype = {
	initialize: function () {
	},
	
	_modalDlg: null,

//	onShowLinkDlg : function(modalDlg, id, elSelectionParent, hasSelection)
//	{
//		this._modalDlg = modalDlg;
//		
//		// see if there is already a link
//		var par = $(elSelectionParent);
//		var starting_selection = "";
//		var starting_type = 0;
//		
//		var ext_link = par.getAttribute('real_link');
//		var cls = par.className;
//		var is_nines = cls.indexOf('nines_linklike') >= 0;
//		var is_ext = cls.indexOf('ext_linklike') >= 0;
//		if ((par.tagName == 'SPAN') && is_nines)
//		{
//			modalDlg.selectNode(elSelectionParent);
//			starting_type = 0;
//			starting_selection = ext_link;
//		}
//		else if ((par.tagName == 'SPAN') && is_ext)
//		{
//			modalDlg.selectNode(elSelectionParent);
//			starting_type = 1;
//			starting_selection = ext_link;
//		}
//		else
//		{
//			// Be sure that at least one character was selected
//			if (!hasSelection)
//			{
//				alert("There is nothing selected. First select some text, then press the link button again.");
//				return;
//			}
//		}
//		
//		// Put up the selection dialog
//		this._createLinkDlg(id, starting_type, starting_selection);
//	},
	
	_getFirstOf : function (str, start, match1, match2) {
		var i = str.substring(start).indexOf(match1);
		var j = str.substring(start).indexOf(match2);
		if (i >= 0 && (j == -1 || i < j))
			return { found: match1, index: start + i };
		if (j >= 0)
			return { found: match2, index: start + j };
		return { found: "" };
	},
	
	_getLastOf : function (str, end, match1, match2) {
		var i = str.substring(0, end).lastIndexOf(match1);
		var j = str.substring(0, end).lastIndexOf(match2);
		if (i >= 0 && i > j)
			return { found: match1, index: i };
		if (j >= 0)
			return { found: match2, index: j };
		return { found: "" };
	},
	
	_getEncompassingLink : function ( rawHtmlOfEditor, iPos ) {
		// The html passed may have multiple levels of spans and other tags. We only care about spans, though.
		// We know if we got this far that the selection completely is encompassed by legal html, so we only need
		// to look at the starting position, since the end position will give the same results.
		// The algorithm is: look backwards in the string for either "</span>" or "real_link".
		// If "</span" is found, then ignore anything until before the next "<span" element.
		// If "real_link" is found, then look backwards for the "<span" element. That is the start.
		// If the start was not found, then return null.
		// If the start was found, then look forward for "<span" and "</span>".
		// If "<span" was found, then ignore everything until after the next "</span>".
		// If "</span>" was found, then that is the end. Return the [start, end] pair.
		
		var done = false;
		var iStart = iPos;
		while (!done) {
			var ret = this._getLastOf(rawHtmlOfEditor, iStart, "</span>", "real_link");
			if (ret.found === "</span>") {
				iStart = rawHtmlOfEditor.substring(0, ret.index).lastIndexOf("<span");	// skip this span, so set the index to just before it.
			} else if (ret.found === "real_link") {
				iStart = rawHtmlOfEditor.substring(0, ret.index).lastIndexOf("<span");
				done = true;
			} else
				return null;
		}
		
		done = false;
		var iEnd = iPos;
		while (!done) {
			var ret = this._getFirstOf(rawHtmlOfEditor, iEnd, "</span>", "<span");
			if (ret.found === "</span>") {
				iEnd = ret.index + 7;	// add the length of the tag itself
				done = true;
			} else if (ret.found === "<span") {
				iEnd = rawHtmlOfEditor.substring(ret.index).lastIndexOf("</span>");	// skip this span, so set the index to just before it.
			} else
				return null;
		}
		
		return [ iStart, iEnd ];
	},
	
	_getInternalLink : function (str)
	{
		// This will only find the first link. That's ok, that's what we want.
		var i = str.indexOf('real_link');
		if (i < 0)
			return null;
		
		var j = str.substring(i+11).indexOf('"');
		return str.substring(i+11, i+11+j);
	},
	
	onShowLinkDlg : function(modalDlg, id, rawHtmlOfEditor, iStartPos, iEndPos)
	{
		this._modalDlg = modalDlg;
		this._iStartPos = iStartPos;
		this._iEndPos = iEndPos;
		this._rawHtmlOfEditor = rawHtmlOfEditor;
		
		// See if there is already a link. There is a link if there is one of our spans either inside the selection or outside the selection.
		// The which one it is matters. If there is a link outside the selection, then we want to expand the selection area to the size of the link
		// and pass the selection value to the dialog as a starting place.
		// If there is a link inside the selection (and there could potentially be two links!) then we keep the selection size as it is passed to us, start
		// the dialog with the first link found, and, if the user presses ok, then remove the interior links and replace them with the larger link.
		// If there are neither of the above is true, then we put up the dialog with the first NINES link selected.
		
		var starting_selection = "";
		var starting_type = 0;

		// See if a link encompasses the selection.
		var ret = this._getEncompassingLink(rawHtmlOfEditor, iStartPos);
		if (ret) {
			this._iStartPos = ret[0];
			this._iEndPos = ret[1];
			var selStr = rawHtmlOfEditor.substring(this._iStartPos, this._iEndPos);
			if (selStr.indexOf('ext_linklike') > 0)
				starting_type = 1;
			var i = selStr.indexOf('real_link') + 11;
			var j = selStr.substring(i).indexOf('"');
			starting_selection = selStr.substring(i, i+j);
		} else { // see if a link is contained in the selection. If so, use the first one.
			ret = this._getInternalLink(rawHtmlOfEditor.substring(this._iStartPos, this._iEndPos));
			if (ret) {
				starting_selection = ret;
			}
		}
		
		
		// Put up the selection dialog
		this._createLinkDlg(id, starting_type, starting_selection);
	},
	
	_linkTypes: [ 'NINES Object', 'External Link' ],
	
	_removeLink : function(event)
	{
		var html = this._splitRawHtml();
		html.selection = this._removeLinksFromSelection(html.selection);
		this._modalDlg.editor.setEditorHTML(html.prologue + html.selection + html.ending);
		this._popup.cancel();
		//this._popup.destroy();
	},
	
	_createLinkDlg : function(element_id, starting_type, starting_selection)
	{
		this._popup = new InputDialog(element_id);
		
		var values = starting_type == 0 ? { ld_type: this._linkTypes[starting_type], ld_nines_object: starting_selection } : { ld_type: this._linkTypes[starting_type], ld_link_url: starting_selection };
		var size = 52;
		this._popup.addSelect('Type of Link:', 'ld_type', this._linkTypes, this._selectionChanged);
		this._popup.addTextInput('Link URL:', 'ld_link_url', size, 'ld_link_only');
		this._popup.addHr();
		var list = new CreateList(gCollectedObjects, 'ld_nines_only', values['ld_nines_object'], 'ld_nines_object');
		this._popup.addList('ld_nines_object', list.list, 'ld_nines_only');

		if (starting_selection.length > 0) {
			this._popup.addButtons([ 
				{ text: "Remove Link", action: LinkDlgHandler.prototype._removeLink, context: this }
			]);
		}
	
		// Now, everything is initialized, fire up the dialog.
		var el = $(element_id);
		this._popup.setOkFunction(this._processLink, this);
		this._popup.show("Set Link", getX(el), getY(el), 530, 350, values );
		this._doSelectionChanged(this._linkTypes[starting_type]);
	},
	
	_selectionChanged: function(event)
	{
		var This = $(this);
		var currSelection = This.value;
		LinkDlgHandler.prototype._doSelectionChanged(currSelection);
	},

	_doSelectionChanged: function(currSelection)
	{
		// This is a callback that is fired whenever the user changes the select
		// box while editing illustrations. It is also fired when the dialog first
		// is displayed.
		var link_only = $$('.ld_link_only');
		var nines_only = $$ ('.ld_nines_only');
		if (currSelection == this._linkTypes[1]) {	// ext link
			link_only.each(function(el) { el.show(); });
			nines_only.each(function(el) { el.hide(); });
		} else if (currSelection == this._linkTypes[0]) {	// nines object
			link_only.each(function(el) { el.hide(); });
			nines_only.each(function(el) { el.show(); });
		}
	},
	
	_removeLinksFromSelection: function (strSel)
	{
		var str = strSel;
		// find "<span....real_link...>" and remove it, and also remove the matching "</span>"
		var iRealLink = str.indexOf("real_link");
		while (iRealLink > 0) {
			var iStart = str.substring(0, iRealLink).lastIndexOf("<span");
			var iEnd = str.substring(iRealLink).indexOf(">");
			var iClose = str.substring(iRealLink).indexOf("</span>");	// TBD-PER: This might not work if there is a complicated set of spans in the selection.
			if (iStart < 0 || iEnd < 0 || iClose < 0)
				return strSel;	// something went wrong, so it is safe to not remove anything
			str = str.substring(0, iStart) + str.substring(iRealLink+iEnd+1, iRealLink+iClose) + str.substring(iRealLink+iClose+7);
			iRealLink = str.indexOf("real_link");
		}
		return str;
	},
	
	_splitRawHtml: function ()
	{
		return { prologue: this._rawHtmlOfEditor.substring(0, this._iStartPos),
			selection: this._rawHtmlOfEditor.substring(this._iStartPos, this._iEndPos),
			ending: this._rawHtmlOfEditor.substring(this._iEndPos)
		};
	},
	
	_processLink: function(This, values)
	{
		var html = This._splitRawHtml();
		html.selection = This._removeLinksFromSelection(html.selection);
		
		if (values['ld_type'] == This._linkTypes[0])
		{
			//<span title="NINES Object: uri" real_link="uri" class="nines_linklike">target</span>
			html.selection = '<span title="NINES Object: ' + values['ld_nines_object'] + '" real_link="' + 
				values['ld_nines_object'] + '" class="nines_linklike">' + html.selection + "</span>";
			This._modalDlg.editor.setEditorHTML(html.prologue + html.selection + html.ending);
		}
		else
		{
			//<span title="External Link: url" real_link="url" class="ext_linklike">target</span>
			html.selection = '<span title="NINES Object: ' + values['ld_link_url'] + '" real_link="' + 
				values['ld_link_url'] + '" class="ext_linklike">' + html.selection + "</span>";
			This._modalDlg.editor.setEditorHTML(html.prologue + html.selection + html.ending);
		}
	}
};

var CreateList = Class.create({
	list : null,
	initialize : function(items, className, initial_selected_uri, value_field)
	{
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
		items.each(function(obj) {
			if (initial_selected_uri === "")	// If nothing is selected, then automatically select the first one.
				initial_selected_uri = obj.uri;
			This.list += This.constructItem(obj.uri, obj.thumbnail, obj.title, obj.uri == initial_selected_uri, value_field);
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
	}
});

CreateList.prototype._select = function(item, value_field)
{
	var selClass = "input_dlg_list_item_selected";
	$$("." + selClass).each(function(el)
	{
		el.removeClassName(selClass);
	});
	$(item).addClassName(selClass);
	$(value_field).value = $(item).getAttribute('uri');
	var caption = $('caption1');
	if (caption != null)
		caption.value = $(item).down().next().innerHTML;
}

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

	dlg.addTextArea('value', 300, 100, null, [ 'drop_cap' ], new LinkDlgHandler);

	// Now populate a hash with all the starting values.	
	// directly below element_id are all the hidden fields with the data we want to use to populate the dialog with

	var values = {};
	
	var downDiv = $(element_id).down('.exhibit_text');
	if (downDiv != null)
		values['value'] = downDiv.innerHTML;
	else
		values['value'] = $(element_id).innerHTML;

	// We also need to set the hidden fields on our form. This is the mechanism
	// for passing back the context to the controller.
	values['element_id'] = element_id;

	// Now, everything is initialized, fire up the dialog.
	var el = $(element_id);
	dlg.show("Enter Text", getX(el), getY(el), 600, 300, values );
	return false;
}

function showHeaderEditor(event)
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
	
	values['value'] = $(element_id).down().innerHTML;
	
	// We also need to set the hidden fields on our form. This is the mechanism
	// for passing back the context to the controller.
	values['element_id'] = element_id;

	// Now, everything is initialized, fire up the dialog.
	var el = $(element_id);
	dlg.show("Enter Header", getX(el), getY(el), 380, 100, values );
}

