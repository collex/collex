/**
 * @author paulrosen
 * This contains the glue code between the input_dialog object and the HTML elements
 * that the user is able to click on to edit. To use, pass in the element_id and the callback
 * URL that will report the user's changes. There is an entry point for each type of popup
 * dialog that should be displayed.
 * 
 */

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
		var obj = { element_id: element_id, action: action, setupMethod: 'showRichEditor', type: 'inplace' };
		_inplaceObjects.push(obj);
	}
	else
		_initializeInplace(element_id, action, 'showRichEditor');
}

function initializeInplaceHeaderEditor(element_id, action)
{
	if (!_inplaceObjectsAlreadyLoaded)
	{
		var obj = { element_id: element_id, action: action, setupMethod: 'showHeaderEditor', type: 'inplace' };
		_inplaceObjects.push(obj);
	}
	else
		_initializeInplace(element_id, action, 'showHeaderEditor');
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

	InputDialog.prototype.prepareDomForEditing(elements[0], ajax_action_element_id, action, 'richEditorHover', 'showIllustrationEditor');
}

/////////////////////////////////////////////////////////////////////////////////////////
// Private functions
/////////////////////////////////////////////////////////////////////////////////////////

function selectionChanged(currSelection)
{
	// This is a callback that is fired whenever the user changes the select
	// box while editing illustrations. It is also fired when the dialog first
	// is displayed.
	var image_only = $$('.image_only');
	var text_only = $$ ('.text_only');
	var nines_only = $$ ('.nines_only');
	var not_nines = $$ ('.not_nines');
	if (currSelection == gIllustrationTypes[0]) {	// image
		image_only.each(function(el) { el.show(); });
		not_nines.each(function(el) { el.show(); });
		nines_only.each(function(el) { el.hide(); });
		text_only.each(function(el) { el.hide(); });
	} else if (currSelection == gIllustrationTypes[1]) {	// nines object
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

function showIllustrationEditor(element_id)
{
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

	// First construct the dialog
	var dlg = new InputDialog(element_id);
    dlg.addHidden("ill_illustration_id");
	
	var size = 52;
	dlg.addSelect('Type of Illustration:', 'type', gIllustrationTypes, 'selectionChanged(this.options[this.selectedIndex].value);');
	dlg.addTextInput('First Caption:', 'caption1', size);
	dlg.addTextInput('Second Caption:', 'caption2', size);
	dlg.addHr();
	dlg.addTextInput('Image URL:', 'image_url', size, 'image_only');
	dlg.addTextInput('Link URL:', 'link_url', size, 'not_nines');
	dlg.addTextInput('Alt Text:', 'alt_text', size, 'image_only');
	dlg.addTextInput('Width:', 'ill_width', size, 'image_only');
	dlg.addTextArea('ill_text', 300, 100, 'text_only');
	var list = new CreateList(gCollectedObjects, 'nines_only', values['nines_object']);
	dlg.addList('nines_object', list.list, 'nines_only');

	// Now, everything is initialized, fire up the dialog.
	var el = $(element_id);
	dlg.show("Edit Illustration", getX(el), getY(el), 530, 350, values );
	selectionChanged(values['type']);
}

var _ninesDlg_ed = null;
var _ninesDlg_str = null;
var _ninesDlg_rng = null;

function showNinesObjectDlg(ed)
{
	_ninesDlg_ed = ed;
	_ninesDlg_str = ed.selection.getContent();
	_ninesDlg_rng = ed.selection.getRng();
	if (_ninesDlg_str == '')
		_ninesDlg_str = "[NINES Object]";

	var dlg = new InputDialog('nines_object', '_ninesObjectSelected(this);');
	
	var size = 52;
	var list = new CreateList(gCollectedObjects);
	dlg.addList('nines_object', list.list);

	var values = {};
	
	// Now, everything is initialized, fire up the dialog.
	var el = $(ed.formElement);
	dlg.show("Create Link to NINES Object", getX(el), getY(el), 400, 400, values );
}

function _ninesObjectSelected(This)
{
	var uri = $('nines_object').value;
	var win = $(This).up('.dialog');
	Windows.close(win.id);
//	_ninesDlg_ed.selection.setRng(_ninesDlg_rng);
//	_ninesDlg_ed.selection.setContent('<span nines_obj_uri="' + uri + '" >' + _ninesDlg_str + '</span>');
	setTimeout('_ninesObjectSelected2("' + uri + '");', 300);
}

function _ninesObjectSelected2(uri)
{
	_ninesDlg_ed.selection.setRng(_ninesDlg_rng);
	_ninesDlg_ed.selection.setContent('<span class="nines_obj_uri" nines_obj_uri="' + uri + '" >' + _ninesDlg_str + '</span>');
}

var CreateList = Class.create({
	list : null,
	initialize : function(items, className, initial_selected_uri)
	{
		var This = this;
		if (className != null && className != undefined)
			This.list = "<table class='input_dlg_list " + className + "' >";
		else
			This.list = "<table class='input_dlg_list' >";
		items.each(function(obj) {
			This.list += This.constructItem(obj.uri, obj.thumbnail, obj.title, obj.uri == initial_selected_uri);
		});
		This.list += "</table>";
	},
	
	constructItem: function(uri, thumbnail, title, is_selected)
	{
		var str = "";
		if (is_selected)
			str = " class='input_dlg_list_item_selected' ";
		return "<tr " + str + "onclick='CreateList.prototype._select(this);' uri='" + uri + "' ><td><img src='" + thumbnail + "' alt='' height='40' /></td><td>" + title + "</td></tr>\n";
	}
});

CreateList.prototype._select = function(item)
{
	var selClass = "input_dlg_list_item_selected";
	$$("." + selClass).each(function(el)
	{
		el.removeClassName(selClass);
	});
	$(item).addClassName(selClass);
	$('nines_object').value = $(item).getAttribute('uri');
}

function showRichEditor(element_id)
{
	// The parameter is the < id="element_id" > tag that was originally passed in during initialization
	// That is, el = <div id='text_YY'>

	// First construct the dialog
	var dlg = new InputDialog(element_id);
    dlg.addHidden("element_id");
	
	var extraButton = {
		id : 'ninesobj',
		insertionPoint : 'redo,|',
		title :  'Link to NINES object',
		image : '/images/mce_link_to_nines_obj.gif',
		onclick : 'showNinesObjectDlg(ed);'
	};

	dlg.addTextArea('value', 300, 100, null, extraButton);

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
}

function showHeaderEditor(element_id)
{
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

