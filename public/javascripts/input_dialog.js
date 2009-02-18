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


var InputDialog = Class.create();
InputDialog._win = null;
InputDialog._form = null;
InputDialog._table = null;
InputDialog._extraButton = null;
InputDialog._linkDlgHandler = null;
InputDialog._modalDialog = null;
InputDialog._okFunction = null;
InputDialog._okObject = null;
InputDialog._noButtons = false;
InputDialog._cancelCallback = null;
InputDialog._cancelThis = null;
InputDialog._onCompleteCallback = null;

InputDialog.prototype = {
	initialize: function(element_id, submitCode)
	{
		var form_id = element_id + '_form';
		// If submitCode is not passed in, then the submit button does an Ajax callback.
		var inlineSubmitCode = "";
		if (submitCode == null || submitCode == undefined)
			inlineSubmitCode = '';
		else
			inlineSubmitCode += "; return false;";
		this._form = new Element('form', { id: form_id, 'class': 'modal_dialog_form', onsubmit:  inlineSubmitCode});
		if (submitCode == null || submitCode == undefined)
			this._form.observe('submit', InputDialog.prototype._observerSubmit.bind(this));
		this._table = new Element('table');
		this._form.appendChild(this._table);
		this._table.appendChild(new Element('tbody'));
	},
	
	_type: "InputDialog",
	_buttonAction: [],
	
	prepareDomForEditing: function(element_id, ajax_action_element_id, action, strHoverClass, strShowEditor)
	{
		var el = $(element_id);
			
		var elWrapper = el.wrap('a');
		el.writeAttribute('action', action);
		el.writeAttribute('ajax_action_element_id', ajax_action_element_id);
		if (strHoverClass != undefined) {
			elWrapper.writeAttribute('hoverclass', strHoverClass);
			elWrapper.observe('mouseover', InputDialog.prototype._editorHover);
			elWrapper.observe('mouseout', InputDialog.prototype._editorExitHover);
		}
		if (strShowEditor != undefined)
			elWrapper.observe('click', strShowEditor);
	},
	
	show: function(title, left, top, width, height, dataHash)
	{
		this._modalDialog = new ModalDialog();
		if (this._onCompleteCallback)
			this._modalDialog.setCompleteCallback(this._onCompleteCallback);

		if (this._okFunction)
			this._modalDialog.showPrompt(title, dataHash.element_id, this._form, left, top, width, height, this._extraButton, this._okFunction, this._okObject);
		else
			this._modalDialog.show(title, dataHash.element_id, this._form, left, top, width, height, this._extraButton, this._linkDlgHandler, this._noButtons, this._cancelCallback, this._cancelThis);
		this._initData(dataHash);
		var buttons = $$("a[clickaction]");
		buttons.each(function(but) {
			var count = but.getAttribute('clickaction');
			but.observe('click', this._buttonAction[count]);
		}, this);
	},
	
	setOkFunction : function(okFunction, okObject)
	{
		this._okFunction = okFunction;
		this._okObject = okObject;
	},
	
	setNoButtons : function()
	{
		this._noButtons = true;
	},
	
	setNotifyCancel : function(cancelCallback, cancelThis)
	{
		this._cancelCallback = cancelCallback;
		this._cancelThis = cancelThis;
	},
	
	setCompleteCallback : function(callBack)
	{
		this._onCompleteCallback = callBack;
	},
	
	cancel : function()
	{
		this._modalDialog._handleCancel();
		//this._modalDialog.dialog.cancel();
		//this._modalDialog.dialog.destroy();

	},

	addSelect: function(label, id, options, change, className)
	{
		var wrapper = new Element('tr');
		if (className != undefined)
			wrapper.addClassName(className);
		var el_label = new Element('label', { 'for': id} ).update(label);
		wrapper.appendChild(el_label.wrap('td'));
		var el = new Element('select', { id: id, name: id, align: 'top' });
		if (change != null && change.length > 0)
			el.observe('change', change);
		options.each(function(option) {
			el.appendChild(new Element('option', { value: option}).update(option));
		});
		wrapper.appendChild(el.wrap('td'));
		this._table.down().appendChild(wrapper);
	},

	addList: function(id, tbl, className)
	{
		this._form.appendChild(new Element('input', { type: 'hidden', id: id, name: id }));
		var wrapper = new Element('tr');
		if (className != undefined)
			wrapper.addClassName(className);
		var wrapper2 = new Element('td', { colspan: 2 });
		wrapper2.innerHTML = tbl;
		wrapper.appendChild(wrapper2);
		this._table.down().appendChild(wrapper);
	},
	
	addPrompt: function(label, className)
	{
		var wrapper = new Element('tr');
		if (className != undefined)
			wrapper.addClassName(className);
		var el_label = new Element('td', { 'colspan': 2} ).update(label);
		wrapper.appendChild(el_label.wrap('td'));
		this._table.down().appendChild(wrapper);
	},
	
	addTextInput: function(label, id, size, className)
	{
		var wrapper = new Element('tr');
		if (className != undefined)
			wrapper.addClassName(className);
		var el_label = new Element('label', { 'for': id} ).update(label);
		wrapper.appendChild(el_label.wrap('td'));
		var el = new Element('input', { type: 'text', id: id, name: id, size: size});
		wrapper.appendChild(el.wrap('td'));
		this._table.down().appendChild(wrapper);
	},

	addHr: function(className)
	{
		var wrapper = new Element('tr');
		if (className != undefined)
			wrapper.addClassName(className);
		var el = new Element('hr');
		wrapper.appendChild(el.wrap('td', { colspan: 2 }));
		this._table.down().appendChild(wrapper);
	},
	
	addHidden: function(id)
	{
		this._form.appendChild(new Element('input', { type: 'hidden', id: id, name: id }));
	},
	
	addTextArea: function(id, width, height, className, extraButtons, linkDlgHandler)
	{
		var wrapper = new Element('tr');
		if (className != null)
			wrapper.addClassName(className);
		var el = new Element('textarea', { id: id, name: id });
		el.setStyle({ width: width + 'px', height: height + 'px', display: 'none' });
		var td = Element.wrap(el, 'td', { colspan: 2, style: 'text-align: center' });
		wrapper.appendChild(td);
		this._table.down().appendChild(wrapper);
		this._extraButton = extraButtons;
		this._linkDlgHandler = linkDlgHandler;
	},
	
	addLink: function(strText, strUrl, clickAction, className)
	{
		var wrapper = new Element('tr');
		wrapper.appendChild(new Element('td'));
		var el = new Element('a', { 'class': className, href: strUrl, onclick: clickAction }).update(strText);
		wrapper.appendChild(el.wrap('td'));
		this._table.down().appendChild(wrapper);
	},
	
	addLinkToNewWindow: function(strText, strUrl, clickAction, className)
	{
		var wrapper = new Element('tr');
		wrapper.appendChild(new Element('td'));
		var el = new Element('a', { 'class': className, target: '_blank', href: strUrl, onclick: clickAction }).update(strText);
		wrapper.appendChild(el.wrap('td'));
		this._table.down().appendChild(wrapper);
	},

	addButtons: function(arrButtons)
	{
		var wrapper = new Element('tr');
		wrapper.appendChild(new Element('td'));
		var td = new Element('td');
		arrButtons.each(function(but) {
			var count = this._buttonAction.length;
			this._buttonAction[count] = but.action;
			var el = new Element('a', { href: "#", clickaction: count }).update(but.text);
			var el2 = el.wrap('span', { 'class': 'first-child' });
			var el3 = el2.wrap('span', { 'class': 'yui-button yui-link-button' });
			td.appendChild(el3);
		}, this);
		wrapper.appendChild(td);
		this._table.down().appendChild(wrapper);
	},

	///////////////////////////////// private members //////////////////////////////////
	_initData: function(dataHash)
	{
		$H(dataHash).each(function(datum) {
			var el = $(datum.key);
			if (el)
				el.value = datum.value;
		} );
	},

	_observerSubmit: function(event)
	{
		//InputDialog._modalDialog._handleSave();
		this._modalDialog._handleSave();
	},
	
	_editorHover: function(ev)
	{
		var el = $(this);
		var hover = el.readAttribute('hoverClass');
		var div = el.down();
		div.addClassName(hover);
	},
	
	_editorExitHover: function(ev)
	{
		var el = $(this);
		var hover = el.readAttribute('hoverClass');
		var div = el.down();
		div.removeClassName(hover);
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
	options	// This is a hash that contains whatever is needed by the inputType
		// text: null
		// select: array of strings that become the choices. 
		// textarea: { height: xx, width: yy }
	)
{
	// put up a Prototype window type dialog.
	if (actionElementIds != null)
		InputDialog.prototype.prepareDomForEditing(referenceElementId, actionElementIds, actions);
	
	// First construct the dialog
	var dlg = new InputDialog(referenceElementId);
	hiddenDataHash.each(function(datum) {
		if (datum.key != promptId)
			dlg.addHidden(datum.key);
	});
	
	// Store the reference element
	hiddenDataHash['element_id'] = referenceElementId;
	
	var width = 400;
	var height = 100;
	
	switch (inputType)
	{
		case 'text':
			dlg.addTextInput(promptStr, promptId, 40);
			break;
		case 'select':
			dlg.addSelect(promptStr, promptId, options);
			break;
		case 'textarea':
			dlg.addTextArea(promptId, options.get('width'), options.get('height'), null, [ ], null);
			width = options.get('width') + 10;
			height = options.get('height') + 60;
			break;
		case 'none':
			dlg.addPrompt(promptStr);
			break;
	}
		
	
	// Now, everything is initialized, fire up the dialog.
	var el = $(referenceElementId);
	var viewportWidth = getViewportWidth() + currentScrollPos()[0];
	var margin = 25;
	var left = getX(el);
	if (left + width + margin > viewportWidth)
		left = viewportWidth - width - margin;
	var viewportHeight = getViewportHeight() + currentScrollPos()[1];
	var top = getY(el);
	if (top + height + margin > viewportHeight)
		top = viewportHeight - height - margin;
	if (actionElementIds == null)
		dlg.setNoButtons();
	dlg.show(titleStr, left, top, width, height, hiddenDataHash );
	
	var prompt = $(promptId);
	if (prompt && prompt.tagName != "TEXTAREA")
	{
		prompt.focus();
		prompt.select();
	}
}

// Take an image and show it in a modal lightbox.
//var _lightboxModalDialog = null;	// There is a problem with the object not destroying itself on close, so this is a hack so there is never more than one created.
function showInLightbox(imageUrl, referenceElementId)
{
	var divName = "lightbox";
	var img = new Element('img', { id: 'lightbox_img', src: imageUrl, alt: ""});
	img.setStyle({display: 'none' });
	var form = img.wrap('form', { id: divName + "_id"});
	var progress = new Element('center', { id: 'lightbox_img_spinner', 'class': 'lightbox_img_spinner'});
	progress.appendChild(new Element('div').update("Image Loading..."));
	progress.appendChild(new Element('img', { src: "/images/ajax_loader.gif", alt: ''}));
	progress.appendChild(new Element('div').update("Please wait"));
	form.appendChild(progress);
	var lightboxModalDialog = new ModalDialog();
	img.observe('load', _lightboxCenter.bind(lightboxModalDialog));
	var el = $(referenceElementId);
	var left = getX(el);
	var top = getY(el);
	lightboxModalDialog.showLightbox("Image", divName, form, left, top);
}

function _lightboxCenter()
{
	var img = $('lightbox_img');
	if (!img)	// The user must have cancelled.
		return;

	var img_spinner = $('lightbox_img_spinner');
	if (img_spinner)
		img_spinner.remove();
	img.show();
	var w = parseInt(img.getStyle('width'));
	var vpWidth = getViewportWidth();
	if (w > vpWidth)
		img.width = vpWidth - 40;
	var h = parseInt(img.getStyle('height'));
	var vpHeight = getViewportHeight();
	if (h > vpHeight)
	{
		img.removeAttribute('width');
		img.height = vpHeight - 80;
	}

	this.center();
}
