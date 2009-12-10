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

//This creates a modal dialog (like native apps have), using Prototype Window.
//The user specifies the fields desired and the fields are arranged in a vertical
//column.

/*global $, $$, Event, Class, Element, $H */
/*global YAHOO */
/*global ModalDialog, currentScrollPos, getX, getY */
/*extern InputDialog, doSingleInputPrompt */

// Refactoring notes:
// InputDialog is only used by initialize_inplacericheditor and doSingleInputPrompt
// doSingleInputPrompt is used by doSaveSearch, editTag, showString [for showing the saved search URL], doAddToExhibit, doAnnotation

var InputDialog = Class.create();
InputDialog.form = null;
InputDialog.table = null;
InputDialog.extraButton = null;
InputDialog.linkDlgHandler = null;
InputDialog.modalDialog = null;
InputDialog.okFunction = null;
InputDialog.okObject = null;
InputDialog.noButtons = false;
InputDialog.cancelCallback = null;
InputDialog.cancelThis = null;
InputDialog.onCompleteCallback = null;

InputDialog.prototype = {
	initialize: function(element_id, submitCode)
	{
		var observerSubmit = function(event) {
			this.modalDialog._handleSave();
		};

		var form_id = element_id + '_form';
		// If submitCode is not passed in, then the submit button does an Ajax callback.
		var inlineSubmitCode = "";
		if (submitCode === null || submitCode === undefined)
			inlineSubmitCode = '';
		else
			inlineSubmitCode += "; return false;";
		this.form = new Element('form', { id: form_id, onsubmit:  inlineSubmitCode});
		this.form.addClassName('modal_dialog_form');
		if (submitCode === null || submitCode === undefined)
			this.form.observe('submit', observerSubmit.bind(this));
		this.table = new Element('table');
		this.form.appendChild(this.table);
		this.table.appendChild(new Element('tbody'));
	},
	
	buttonAction: [],

	centerEditor: function()
	{
		this.modalDialog.editors[0].editor.on('afterRender', function() {
			this.center();
		}, this, true);
	},

	prepareDomForEditing: function(element_id, ajax_action_element_id, action, strHoverClass, strShowEditor)
	{
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
	},
	
	show: function(title, left, top, width, height, dataHash)
	{
		var initData = function(dataHash) {
			$H(dataHash).each(function(datum) {
				var el = $(datum.key);
				if (el)
					el.value = datum.value;
			} );
		};

		this.modalDialog = new ModalDialog();
		if (this.onCompleteCallback)
			this.modalDialog.setCompleteCallback(this.onCompleteCallback);
		if (this._saveButtonName)
			this.modalDialog.setSaveButton(this._saveButtonName);

		if (this.okFunction)
			this.modalDialog.showPrompt(title, dataHash.element_id, this.form, left, top, width, height, this.extraButton, this.okFunction, this.okObject);
		else
			this.modalDialog.show(title, dataHash.element_id, this.form, left, top, width, height, this.extraButton, this.linkDlgHandler, this.noButtons, this.cancelCallback, this.cancelThis);
		initData(dataHash);
		var buttons = $$("a[clickaction]");
		buttons.each(function(but) {
			var count = but.getAttribute('clickaction');
			if (this.buttonAction[count].context === null || this.buttonAction[count].context === undefined)
				but.observe('click', this.buttonAction[count].action);
			else
				Event.observe(but, 'click', this.buttonAction[count].action.bindAsEventListener(this.buttonAction[count].context));
		}, this);
	},
	
	center: function() {
		this.modalDialog.center();
	},
	
	setSaveButton : function(name) {
		this._saveButtonName = name;
	},
	
	setOkFunction : function(okFunction_, okObject_)
	{
		this.okFunction = okFunction_;
		this.okObject = okObject_;
	},
	
	setNoButtons : function()
	{
		this.noButtons = true;
	},
	
	setNotifyCancel : function(cancelCallback_, cancelThis_)
	{
		this.cancelCallback = cancelCallback_;
		this.cancelThis = cancelThis_;
	},
	
	setCompleteCallback : function(callBack)
	{
		this.onCompleteCallback = callBack;
	},
	
	cancel : function()
	{
		this.modalDialog._handleCancel();
	},

	addSelect: function(label, id, options, change, className)
	{
		var wrapper = new Element('tr');
		if (className !== undefined)
			wrapper.addClassName(className);
		var el_label = new Element('label', { 'for': id} ).update(label);
		wrapper.appendChild(el_label.wrap('td'));
		var el = new Element('select', { id: id, name: id, align: 'top' });
		if (change !==null && change !== undefined)
			el.observe('change', change);
		options.each(function(option) {
			el.appendChild(new Element('option', { value: option}).update(option));
		});
		wrapper.appendChild(el.wrap('td'));
		this.table.down().appendChild(wrapper);
	},

	addList: function(id, tbl, className)
	{
		this.form.appendChild(new Element('input', { type: 'hidden', id: id, name: id }));
		var wrapper = new Element('tr');
		if (className !== undefined)
			wrapper.addClassName(className);
		var wrapper2 = new Element('td', { colspan: 2 });
		wrapper2.innerHTML = tbl;
		wrapper.appendChild(wrapper2);
		this.table.down().appendChild(wrapper);
	},
	
	addPrompt: function(label, className)
	{
		var wrapper = new Element('tr');
		if (className !== undefined)
			wrapper.addClassName(className);
		var el_label = new Element('td', { 'colspan': 2} ).update(label);
		wrapper.appendChild(el_label.wrap('td'));
		this.table.down().appendChild(wrapper);
	},
	
	addTextInput: function(label, id, size, className)
	{
		var wrapper = new Element('tr');
		if (className !== undefined)
			wrapper.addClassName(className);
		var el_label = new Element('label', { 'for': id} ).update(label);
		wrapper.appendChild(el_label.wrap('td'));
		var el = new Element('input', { type: 'text', id: id, name: id, size: size});
		wrapper.appendChild(el.wrap('td'));
		this.table.down().appendChild(wrapper);
	},

	addHr: function(className)
	{
		var wrapper = new Element('tr');
		if (className !== undefined)
			wrapper.addClassName(className);
		var el = new Element('hr');
		wrapper.appendChild(el.wrap('td', { colspan: 2 }));
		this.table.down().appendChild(wrapper);
	},
	
	addHidden: function(id)
	{
		this.form.appendChild(new Element('input', { type: 'hidden', id: id, name: id }));
	},
	
	addTextArea: function(id, width, height, className, extraButton_, linkDlgHandler_)
	{
		var wrapper = new Element('tr');
		if (className !== null)
			wrapper.addClassName(className);
		var el = new Element('textarea', { id: id, name: id });
		el.setStyle({ width: width + 'px', height: height + 'px', display: 'none' });
		var td = Element.wrap(el, 'td', { colspan: 2, style: 'text-align: center' });
		wrapper.appendChild(td);
		this.table.down().appendChild(wrapper);
		this.extraButton = extraButton_;
		this.linkDlgHandler = linkDlgHandler_;
	},
	
	addLink: function(strText, strUrl, clickAction, className)
	{
		var wrapper = new Element('tr');
		wrapper.appendChild(new Element('td'));
		var el = new Element('a', { href: strUrl, onclick: clickAction }).update(strText);
		el.addClassName(className);
		wrapper.appendChild(el.wrap('td'));
		this.table.down().appendChild(wrapper);
	},
	
	addLinkToNewWindow: function(strText, strUrl, clickAction, className)
	{
		var wrapper = new Element('tr');
		wrapper.appendChild(new Element('td'));
		var el = new Element('a', { target: '_blank', href: strUrl, onclick: clickAction }).update(strText);
		el.addClassName(className);
		wrapper.appendChild(el.wrap('td'));
		this.table.down().appendChild(wrapper);
	},

	addButtons: function(arrButtons)
	{
		var wrapper = new Element('tr');
		wrapper.appendChild(new Element('td'));
		var td = new Element('td');
		arrButtons.each(function(but) {
			var count = this.buttonAction.length;
			this.buttonAction[count] = { action: but.action, context: but.context };
			var el = new Element('a', { href: "#", clickaction: count }).update(but.text);
			var el2 = el.wrap('span');
			el2.addClassName('first-child');
			var el3 = el2.wrap('span');
			el3.addClassName('yui-button');
			el3.addClassName('yui-link-button');
			td.appendChild(el3);
		}, this);
		wrapper.appendChild(td);
		this.table.down().appendChild(wrapper);
	}
};

//var _observer = {
//  onResize: function(eventName, win) {
//	var mce = $(win.element).down('.mceIframeContainer');
//	if (mce != null)
//	{
//		var mcei = mce.down('iframe');
//		mcei.setStyle({ height: '100%' });
//		var mcel = $(win.element).down('.mceLayout');
//		mcel.setStyle({ width: '' });
//
//		// Height manipulation: needs to take the offset of the interior edit box, plus the offset to the 
//		// larger edit box (that includes the toolbar), and the height of the OK button, plus some extra
//		// for the window borders and a margin.
//		var mcetd = mcel.up().up();	// get to the <td> element
//		var top = mce.offsetTop + mcetd.offsetTop;
//		var ok = $(win.element).down('.editor_ok_button');
//		var margin = ok.offsetHeight + 30;
//		var height = win.height - top - margin;
//		
//		// Width manipulation: just needs a margin
//		var width = win.width - 10;
//		mce.setStyle({ height: height + "px", width: width + 'px' });
//	}
//  }
//}
//Windows.addObserver(_observer);

//////////////////////////////////////////////////////////////////////////////////////////////////

// Create a small prompt dialog with one field, then send the user's response to the server by ajax.
function doSingleInputPrompt(titleStr, // The string that appears in the title bar
	promptStr, // The string that appears to the left of the input
	promptId, // The key that will be used in the params[] hash in the ajax call
	referenceElementId, // The element that the dialog will appear above
	actionElementIds, // The list of elements that should be updated by the ajax calls (comma separated) [ if this is "", then the entire page should be redrawn. If this is null, then no OK button exists. ]
	actions, // The list of urls that should be called by Ajax (should be the same number as above)
	hiddenDataHash, // Extra data that should be sent back to the server .eg.: $H({ key1: 'value1', key2: 'value2' })
	inputType,	// one of: 'text', 'select', or 'textarea'; or 'none' meaning that this dialog is just for info.
	options,	// This is a hash that contains whatever is needed by the inputType
		// text: null, or width: yy
		// select: array of strings that become the choices. 
		// textarea: { height: xx, width: yy, toolbarGroups: [ ' ', ' ' ], linkDlgHandler: new LinkDlgHandler() }
	saveButtonName)	// either a string that appears as the text of the save button, or null to take the default
{
	// put up a Prototype window type dialog.
	if (actionElementIds !== null)
		InputDialog.prototype.prepareDomForEditing(referenceElementId, actionElementIds, actions);
	
	// First construct the dialog
	var dlg = new InputDialog(referenceElementId);
	hiddenDataHash.each(function(datum) {
		if (datum.key !== promptId)
			dlg.addHidden(datum.key);
	});
	
	// Store the reference element
	hiddenDataHash.element_id = referenceElementId;
	
	var width = 400;
	var height = 100;
	
	switch (inputType)
	{
		case 'text':
			if (options !== null)
				width = options.get('width');
			else
				width = 40;
			dlg.addTextInput(promptStr, promptId, width);
			break;
		case 'select':
			dlg.addSelect(promptStr, promptId, options);
			break;
		case 'textarea':
			var toolbarGroups = options.get('toolbarGroups');
			if (toolbarGroups === undefined)
				toolbarGroups = [ 'font', 'fontstyle', 'list', 'link' ];
			dlg.addTextArea(promptId, options.get('width'), options.get('height'), null, toolbarGroups, options.get('linkDlgHandler'));
			width = options.get('width') + 10;
			height = options.get('height') + 60;
			break;
		case 'none':
			dlg.addPrompt(promptStr);
			break;
	}
		
	
	// Now, everything is initialized, fire up the dialog.
	var el = $(referenceElementId);
	var viewportWidth = YAHOO.util.Dom.getViewportWidth() + currentScrollPos()[0];
	var margin = 25;
	var left = getX(el);
	if (left + width + margin > viewportWidth)
		left = viewportWidth - width - margin;
	var viewportHeight = YAHOO.util.Dom.getViewportHeight() + currentScrollPos()[1];
	var top = getY(el);
	if (top + height + margin > viewportHeight)
		top = viewportHeight - height - margin;
	if (actionElementIds === null)
		dlg.setNoButtons();
	if (saveButtonName)
		dlg.setSaveButton(saveButtonName);
	dlg.show(titleStr, left, top, width, height, hiddenDataHash );
	dlg.center();
	
	var prompt = $(promptId);
	if (prompt && prompt.tagName !== "TEXTAREA")
	{
		prompt.select();
		prompt.focus();
	}
	if (prompt && prompt.tagName === "TEXTAREA") {
		dlg.modalDialog.editors[0].editor.on('afterRender', function() {
			dlg.center();
		}, this, true);
	}
}

