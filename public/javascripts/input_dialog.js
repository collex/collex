/**
 * @author paulrosen
 * This creates a modal dialog (like native apps have), using Prototype Window.
 * The user specifies the fields desired and the fields are arranged in a vertical
 * column.
 */

var InputDialog = Class.create();
InputDialog._win = null;
InputDialog._form = null;
InputDialog._table = null;

InputDialog.prototype = {
	initialize: function(element_id)
	{
		var form_id = element_id + '_form';
		_form = new Element('form', { id: form_id, onsubmit: 'InputDialog.prototype._userPressedOk("' + element_id + '","' + form_id + '"); return false;' });
		_table = new Element('table');
		_form.appendChild(_table);
	},
	
	prepareDomForEditing: function(element_id, ajax_action_element_id, action, strHoverClass, strShowEditor)
	{
		var el = $(element_id);
			
		var elWrapper = el.wrap('a', { href: '#' });
		el.writeAttribute('action', action);
		el.writeAttribute('ajax_action_element_id', ajax_action_element_id);
		if (strHoverClass != undefined) {
			elWrapper.writeAttribute('hoverclass', strHoverClass);
			elWrapper.writeAttribute('onmouseover', 'InputDialog.prototype._editorHover(this);');
			elWrapper.writeAttribute('onmouseout', "InputDialog.prototype._editorExitHover(this);");
		}
		if (strShowEditor != undefined)
			elWrapper.writeAttribute('onclick', strShowEditor + "('" + element_id + "'); return false;");
	},
	
	show: function(title, left, top, dataHash)
	{
//		var w = _table.getStyle('width') + 10;
//		var h = _form.getStyle('height');
		
		_win = new Window({
			title: title,
			className: 'darkX',
			width: null,
			height: null,
			destroyOnClose: true,
			left: left,
			top: top,
			showEffect: Element.show,
			hideEffect: Element.hide,
			maximizable: false,
			minimizable: false,
			resizable: true
		});

		var buttons = new Element('p', { style: "text-align: center;" });
		buttons.appendChild(new Element('input', { type: 'submit', 'class': 'editor_ok_button', value: 'ok'}));
		_form.appendChild(buttons);
		_win.getContent().update(_form);
		//_win.setConstraint(true, {left:10 - pos[0], right:30 - pos[1], top: 10 - pos[0], bottom:10 - pos[1]});
		_win.show(true);
		tinyMCE.init({
			mode: "textareas",
			theme: "advanced",
			plugins : "style,advlink,media,contextmenu,paste,visualchars",
			theme_advanced_buttons1 : "cut,copy,paste,|,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,formatselect,fontselect,fontsizeselect",
			theme_advanced_buttons2 : "bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,code,|,forecolor,backcolor,hr,removeformat,|,sub,sup,|,charmap,media",
			theme_advanced_buttons3: "",
			theme_advanced_toolbar_location : "top",
			theme_advanced_toolbar_align : "left"
		});
		// TODO: This returns null for the width and height. How do you get the width?
		//var w = _form.getStyle('width');
		//var h = _form.getStyle('height');
		//var par = _form.up();
		//par.setStyle({ width: w + 20 + 'px', height: h + 40 + 'px' });
		this._initData(dataHash);
	},
	
	addSelect: function(label, id, options, change, className)
	{
		var wrapper = new Element('tr');
		if (className != undefined)
			wrapper.addClassName(className);
		var el_label = new Element('label', { 'for': id} ).update(label);
		wrapper.appendChild(el_label.wrap('td'));
		var el = new Element('select', { id: id, name: id, align: 'top', onchange: change });
		options.each(function(option) {
			el.appendChild(new Element('option', { value: option}).update(option));
		});
		wrapper.appendChild(el.wrap('td'));
		_table.appendChild(wrapper);
	},

	addTextInput: function(label, id, size, className)
	{
		var wrapper = new Element('tr');
		if (className != undefined)
			wrapper.addClassName(className);
		var el_label = new Element('label', { 'for': id} ).update(label);
		wrapper.appendChild(el_label.wrap('td', { style: 'text-align: right;' }));
		var el = new Element('input', { type: 'text', id: id, name: id, size: size});
		wrapper.appendChild(el.wrap('td'));
		_table.appendChild(wrapper);
	},

	addHr: function(className)
	{
		var wrapper = new Element('tr');
		if (className != undefined)
			wrapper.addClassName(className);
		var el = new Element('hr');
		wrapper.appendChild(el.wrap('td', { colspan: 2 }));
		_table.appendChild(wrapper);
	},
	
	addHidden: function(id)
	{
		_form.appendChild(new Element('input', { type: 'hidden', id: id, name: id }));
	},
	
	addTextArea: function(id, width, height, className)
	{
		var wrapper = new Element('tr');
		if (className != undefined)
			wrapper.addClassName(className);
		var el = new Element('textarea', { id: id, name: id });
		el.setStyle({ width: width + 'px', height: height + 'px' });
		wrapper.appendChild(el.wrap('td', { colspan: 2, style: 'text-align: center' }));
		_table.appendChild(wrapper);
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

	_userPressedOk: function(element_id, form_id)
	{
		// Just set a timeout here. This allows the tinyMCE to get the
		// on submit callback and put the user's changed back in the
		// original textarea. It also lets tinyMCE turn off the callbacks
		// to that control so there isn't a javascript crash after removing
		// it from the page.
		setTimeout('InputDialog.prototype._userPressedOk2("' + element_id + '","' + form_id + '");', 300);
	},

	_userPressedOk2: function(element_id, form_id)
	{
		var el = $(element_id);
		var action = el.readAttribute('action');
		var ajax_action_element_id = el.readAttribute('ajax_action_element_id');
	
		var params = { element_id: element_id };
		var els = $$('#' + form_id + ' input');
		els.each(function(e) { params[e.id] = e.value; });
		els = $$('#' + form_id + ' textarea');
		els.each(function(e) { params[e.id] = e.value; });
		els = $$('#' + form_id + ' select');
		els.each(function(e) { params[e.id] = e.value; });
	
		// If we have a comma separated list, we want to send the alert synchronously to each action
		// (Doing this synchronously eliminates any race condition: The first call can update the data and
		// the rest of the calls just update the page.
		var actions = action.split(',');
		var action_elements = ajax_action_element_id.split(',');
		if (actions.length == 1)
		{
			new Ajax.Updater(ajax_action_element_id, action, {
				parameters : params,
				evalScripts : true,
				onFailure : function(resp) { alert("Oops, there's been an error."); }
			});
		}
		else
		{
			new Ajax.Updater(action_elements[0], actions[0], {
				parameters : params,
				evalScripts : true,
				onComplete: function(resp) {
					new Ajax.Updater(action_elements[1], actions[1], {
						parameters : params,
						evalScripts : true,
						onFailure : function(resp) { alert("Oops, there's been an error."); }
					});
				},
				onFailure : function(resp) { alert("Oops, there's been an error."); }
			});
		}
				
		Windows.closeAllModalWindows();
	},
	
	_editorHover: function(This)
	{
		var el = $(This);
		var hover = el.readAttribute('hoverClass');
		var div = el.down();
		div.addClassName(hover);
	},
	
	_editorExitHover: function(This)
	{
		var el = $(This);
		var hover = el.readAttribute('hoverClass');
		var div = el.down();
		div.removeClassName(hover);
	}
};
