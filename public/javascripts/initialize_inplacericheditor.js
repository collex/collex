/**
 * @author paulrosen
 * This contains the glue code between the input_dialog object and the HTML elements
 * that the user is able to click on to edit. To use, pass in the element_id and the callback
 * URL that will report the user's changes. There is an entry point for each type of popup
 * dialog that should be displayed.
 * 
 */

function initializeInplaceRichEditor(element_id, action)
{
	_initializeInplace(element_id, action, 'showRichEditor');
}

function initializeInplaceHeaderEditor(element_id, action)
{
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
	// We pass in <div id='illustration_YY' class="illustration_block"> as the element_id
	// We want to use <div id="element_XX" class="element_block"> for the ajax call
	// The element_block will be a parent of the element_id object
	var el = $(element_id);
	var ajax_action_element_id = $(element_id).up('.element_block').id;

	InputDialog.prototype.prepareDomForEditing(element_id, ajax_action_element_id, action, 'richEditorHover', 'showIllustrationEditor');
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
	if (currSelection == 'Internet Image') {
		image_only.each(function(el) { el.show(); });
		text_only.each(function(el) { el.hide(); });
	} else if (currSelection == 'Textual Illustration') {
		image_only.each(function(el) { el.hide(); });
		text_only.each(function(el) { el.show(); });
	}
}

function showIllustrationEditor(element_id)
{
	// The parameter is the < id="element_id" > tag that was originally passed in during initialization
	// That is, el = <div id='illustration_YY' class="illustration_block">

	// First construct the dialog
	var dlg = new InputDialog(element_id);
    dlg.addHidden("ill_illustration_id");
	
	var size = 52;
	dlg.addSelect('Type of Illustration:', 'type', gIllustrationTypes, 'selectionChanged(this.options[this.selectedIndex].value);');
	dlg.addTextInput('First Caption:', 'caption1', size);
	dlg.addTextInput('Second Caption:', 'caption2', size);
	dlg.addHr();
	dlg.addTextInput('Image URL:', 'image_url', size, 'image_only');
	dlg.addTextInput('Link URL:', 'link_url', size);
	dlg.addTextInput('Alt Text:', 'alt_text', size, 'image_only');
	dlg.addTextInput('Width:', 'ill_width', size, 'image_only');
	dlg.addTextArea('ill_text', 300, 100, 'text_only');

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
	});

	// We also need to set the hidden fields on our form. This is the mechanism
	// for passing back the context to the controller.
	values['ill_illustration_id'] = element_id;

	// Now, everything is initialized, fire up the dialog.
	var el = $(element_id);
	dlg.show("Edit Illustration", getX(el), getY(el), values );
	selectionChanged(values['type']);
}

function showRichEditor(element_id)
{
	// The parameter is the < id="element_id" > tag that was originally passed in during initialization
	// That is, el = <div id='text_YY'>

	// First construct the dialog
	var dlg = new InputDialog(element_id);
    dlg.addHidden("element_id");
	
	dlg.addTextArea('value', 300, 100);

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
	dlg.show("Enter Text", getX(el), getY(el), values );
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
	dlg.show("Enter Header", getX(el), getY(el), values );
}

