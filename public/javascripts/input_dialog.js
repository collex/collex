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
/*extern InputDialog */

// Refactoring notes:
// InputDialog is only used by initialize_inplacericheditor

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
