/**
 * @author paulrosen
 */

function initializeInplaceRichEditor(element_id, action)
{
	// We pass in <div id='illustration_YY' class="illustration_block"> as the element_id
	// We want to use <div id="element_XX" class="element_block"> for the ajax call
	// The element_block will be a parent of the element_id object
	var el = $(element_id);
	var ajax_action_element_id = $(element_id).up('.element_block').id;

	InputDialog.prototype.prepareDomForEditing(element_id, ajax_action_element_id, action, 'richEditorHover', 'showRichEditor');
//	initializeInplaceEditor(element_id, action, 'richEditorHover', 'richEditorExitHover', 'showRichEditor');
}

//function richEditorHover(This)
//{
//	var el = $(This);
//	var div = el.down();
//	div.addClassName('richEditorHover');
//}
//
//function richEditorExitHover(This)
//{
//	var el = $(This);
//	var div = el.down();
//	div.removeClassName('richEditorHover');
//}

//function richEditorOk(element_id)
//{
//	// Just set a timeout here. This allows the tinyMCE to get the
//	// on submit callback and put the user's changed back in the
//	// original textarea. It also lets tinyMCE turn off the callbacks
//	// to that control so there isn't a javascript crash after removing
//	// it from the page.
//	setTimeout('richEditorOk2("' + element_id + '");', 300);
//}
//
//function richEditorOk2(element_id)
//{
//	var el = $(element_id);
//	var action = el.up().readAttribute('action');
//
//	var ta = $('richeditor_ta');
//	var txt = ta.value;
//
//	new Ajax.Updater(el, action, {
//		parameters : { editorId: element_id, value: txt },
//		evalScripts : false,
//		//onComplete : setTimeout("initializeInplaceRichEditor('" + element_id + "', '" + action + "')", 1000),
//		onFailure : function(resp) { alert("Oops, there's been an error."); }
//	});
//	
//	Windows.closeAllModalWindows();
//}



function initializeInplaceIllustrationEditor(element_id, action)
{
	// We pass in <div id='illustration_YY' class="illustration_block"> as the element_id
	// We want to use <div id="element_XX" class="element_block"> for the ajax call
	// The element_block will be a parent of the element_id object
	var el = $(element_id);
	var ajax_action_element_id = $(element_id).up('.element_block').id;

	InputDialog.prototype.prepareDomForEditing(element_id, ajax_action_element_id, action, 'richEditorHover', 'showIllustrationEditor');
}

function selectionChanged(currSelection)
{
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
	
	values['value'] = $(element_id).down().innerHTML;
	
	// We also need to set the hidden fields on our form. This is the mechanism
	// for passing back the context to the controller.
	values['element_id'] = element_id;

	// Now, everything is initialized, fire up the dialog.
	var el = $(element_id);
	dlg.show("Enter Text", getX(el), getY(el), values );
}

/////////////////////////////////////////////////////////////////////////////////////////
// Generalized functions for all pop up dialogs
/////////////////////////////////////////////////////////////////////////////////////////

function initializeInplaceEditor(element_id, action, strEditorHover, strEditorExitHover, strShowEditor)
{
	var el = $(element_id);
	// first see if there is already a wrapper. We don't want to wrap twice.
	var par = el.up();
	if (par.getAttribute('action') == action)
		return;
		
	var elWrapper = el.wrap('a', { href: '#' });
	elWrapper.writeAttribute('action', action);
	elWrapper.writeAttribute('onmouseover', strEditorHover + '(this);');
	elWrapper.writeAttribute('onmouseout', strEditorExitHover + "(this);");
	elWrapper.writeAttribute('onclick', strShowEditor + "(this); return false;");
}

