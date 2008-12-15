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
InputDialog._extraButton = null;
InputDialog._useRichEditor = true;

InputDialog.prototype = {
	initialize: function(element_id, submitCode)
	{
		var form_id = element_id + '_form';
		// If submitCode is not passed in, then the submit button does an Ajax callback.
		if (submitCode == null || submitCode == undefined)
			submitCode = 'InputDialog.prototype._userPressedOk("' + element_id + '","' + form_id + '"); return false;';
		else
			submitCode += "; return false;";
		this._form = new Element('form', { id: form_id, onsubmit:  submitCode});
		this._table = new Element('table');
		this._form.appendChild(this._table);
		this._table.appendChild(new Element('tbody'));
		this._useRichEditor = true;
	},
	
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
			modalDialog.show(title, dataHash.element_id, this._form, left, top, width, height);
			this._initData(dataHash);				
	},
	
	oldshow: function(title, left, top, width, height, dataHash)
	{
//		var w = _table.getStyle('width') + 10;
//		var h = _form.getStyle('height');
		
		this._win = new Window({
			title: title,
			//className: 'darkX',
			className: "collex",
			destroyOnClose: true,
			left: left,
			top: top,
			showEffect: Element.show,
			hideEffect: Element.hide,
			maximizable: false,
			minimizable: false,
			width: width,
			height: height,
			resizable: true
		});
		
		var buttons = new Element('p', { style: "text-align: center;" });
		buttons.appendChild(new Element('input', { type: 'submit', 'class': 'editor_ok_button', value: 'ok'}));
		this._form.appendChild(buttons);
		this._win.getContent().update(this._form);
		//_win.setConstraint(true, {left:10 - pos[0], right:30 - pos[1], top: 10 - pos[0], bottom:10 - pos[1]});
		this._win.show(true);
		this._initData(dataHash);

		if (this._useRichEditor)
		{
			var strButtons1 = "cut,copy,paste,|,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,formatselect,fontselect,fontsizeselect";
			var strButtons2 = "bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,ninesobj,link,unlink,code,|,forecolor,backcolor,hr,removeformat,|,sub,sup,|,charmap,media";
			if (this._extraButton != null)
			{
				strButtons1 = strButtons1.replace(this._extraButton.insertionPoint, this._extraButton.insertionPoint + ',' + this._extraButton.id);
				strButtons2 = strButtons2.replace(this._extraButton.insertionPoint, this._extraButton.insertionPoint + ',' + this._extraButton.id);
			}
			
			tinyMCE.init({
				mode: "textareas",
				theme: "advanced",
				plugins : "style,advlink,media,contextmenu,paste,visualchars",
				theme_advanced_buttons1 : strButtons1,
				theme_advanced_buttons2 : strButtons2,
				theme_advanced_buttons3: "",
				theme_advanced_toolbar_location : "top",
				theme_advanced_toolbar_align : "left",
			    setup : function(ed) {
			        // Add a custom button
					if (this._extraButton != null)
					{
				        ed.addButton(this._extraButton.id, {
				            title : this._extraButton.title,
				            image : this._extraButton.image,
				            onclick : function() {
								eval(this._extraButton.onclick);
				            }
				        });
					}
			    }
			});
		}
		
		// TODO: This returns null for the width and height. How do you get the width?
		//var w = _form.getStyle('width');
		//var h = _form.getStyle('height');
		//var par = _form.up();
		//par.setStyle({ width: w + 20 + 'px', height: h + 40 + 'px' });
		
		__win = this._win;	// TODO-PER: Temporarily set a global variable to pass the window on.
		setTimeout('_observer.onResize("resize", __win)', 600);
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
	
	addTextInput: function(label, id, size, className)
	{
		var wrapper = new Element('tr');
		if (className != undefined)
			wrapper.addClassName(className);
		var el_label = new Element('label', { 'for': id} ).update(label);
		//wrapper.appendChild(el_label.wrap('td', { style: 'text-align: right;' }));
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
	
	addTextArea: function(id, width, height, className, extraButton)
	{
		var wrapper = new Element('tr');
		if (className != undefined)
			wrapper.addClassName(className);
		var el = new Element('textarea', { id: id, name: id });
		el.setStyle({ width: width + 'px', height: height + 'px' });
		var td = Element.wrap(el, 'td', { colspan: 2, style: 'text-align: center' });
		wrapper.appendChild(td);
		this._table.down().appendChild(wrapper);
		this._extraButton = extraButton;
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
		modalDialog.handleSave();
		// Just set a timeout here. This allows the tinyMCE to get the
		// on submit callback and put the user's changed back in the
		// original textarea. It also lets tinyMCE turn off the callbacks
		// to that control so there isn't a javascript crash after removing
		// it from the page.
		//setTimeout('InputDialog.prototype._userPressedOk2("' + element_id + '","' + form_id + '");', 300);
	},

//	_userPressedOk2: function(element_id, form_id)
//	{
//		var el = $(element_id);
//		var action = el.readAttribute('action');
//		var ajax_action_element_id = el.readAttribute('ajax_action_element_id');
//	
//		var params = { element_id: element_id };
//		var els = $$('#' + form_id + ' input');
//		els.each(function(e) { params[e.id] = e.value; });
//		els = $$('#' + form_id + ' textarea');
//		els.each(function(e) { params[e.id] = e.value; });
//		els = $$('#' + form_id + ' select');
//		els.each(function(e) { params[e.id] = e.value; });
//	
//		// If we have a comma separated list, we want to send the alert synchronously to each action
//		// (Doing this synchronously eliminates any race condition: The first call can update the data and
//		// the rest of the calls just update the page.
//		var actions = action.split(',');
//		var action_elements = ajax_action_element_id.split(',');
//		if (actions.length == 1)
//		{
//			new Ajax.Updater(ajax_action_element_id, action, {
//				parameters : params,
//				evalScripts : true,
//				onFailure : function(resp) { alert("Oops, there's been an error."); }
//			});
//		}
//		else
//		{
//			new Ajax.Updater(action_elements[0], actions[0], {
//				parameters : params,
//				evalScripts : true,
//				onComplete: function(resp) {
//					new Ajax.Updater(action_elements[1], actions[1], {
//						parameters : params,
//						evalScripts : true,
//						onFailure : function(resp) { alert("Oops, there's been an error."); }
//					});
//				},
//				onFailure : function(resp) { alert("Oops, there's been an error."); }
//			});
//		}
//		
//		Windows.closeAllModalWindows();
//	},
	
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

var _observer = {
  onResize: function(eventName, win) {
	var mce = $(win.element).down('.mceIframeContainer');
	if (mce != null)
	{
		var mcei = mce.down('iframe');
		mcei.setStyle({ height: '100%' });
		var mcel = $(win.element).down('.mceLayout');
		mcel.setStyle({ width: '' });

		// Height manipulation: needs to take the offset of the interior edit box, plus the offset to the 
		// larger edit box (that includes the toolbar), and the height of the OK button, plus some extra
		// for the window borders and a margin.
		var mcetd = mcel.up().up();	// get to the <td> element
		var top = mce.offsetTop + mcetd.offsetTop;
		var ok = $(win.element).down('.editor_ok_button');
		var margin = ok.offsetHeight + 30;
		var height = win.height - top - margin;
		
		// Width manipulation: just needs a margin
		var width = win.width - 10;
		mce.setStyle({ height: height + "px", width: width + 'px' });
	}
  }
}
Windows.addObserver(_observer);

//////////////////////////////////////////////////////////////////////////////////////////////////

// Create a small prompt dialog with one field, then send the user's response to the server by ajax.
function doSingleInputPrompt(titleStr, // The string that appears in the title bar
	promptStr, // The string that appears to the left of the input
	promptId, // The key that will be used in the params[] hash in the ajax call
	referenceElementId, // The element that the dialog will appear above
	actionElementIds, // The list of elements that should be updated by the ajax calls (comma separated)
	actions, // The list of urls that should be called by Ajax (should be the same number as above)
	hiddenDataHash, // Extra data that should be sent back to the server .eg.: $H({ key1: 'value1', key2: 'value2' })
	inputType,	// one of: 'text', 'select', or 'textarea'
	options	// This is a hash that contains whatever is needed by the inputType
		// text: null
		// select: array of strings that become the choices. 
		// textarea: { height: xx, width: yy }
	)
{
	// put up a Prototype window type dialog.
	InputDialog.prototype.prepareDomForEditing(referenceElementId, actionElementIds, actions);
	
	// First construct the dialog
	var dlg = new InputDialog(referenceElementId);
	hiddenDataHash.each(function(datum) {
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
			dlg.addTextArea(promptId, options.get('width'), options.get('height'));
			dlg._useRichEditor = false;
			width = options.get('width') + 10;
			height = options.get('height') + 60;
			break;
	}
		
	
	// Now, everything is initialized, fire up the dialog.
	var el = $(referenceElementId);
	var viewportWidth = getViewportWidth() + currentScrollPos()[0];
	var left = getX(el);
	if (left + width > viewportWidth)
		left = viewportWidth - width;
	var viewportHeight = getViewportHeight() + currentScrollPos()[1];
	var top = getY(el);
	if (top + height > viewportHeight)
		top = viewportHeight - height;
	dlg.show(titleStr, left, top, width, height, hiddenDataHash );
	setTimeout(function() { $(promptId).focus() }, 600);
}

