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

/*global Class, $, $$, Element */
/*global YAHOO */
/*global Ajax */
/*global document, setTimeout, window */
/*global RichTextEditor, LinkDlgHandler */
/*global formatFailureMsg, serverAction */
/*extern GeneralDialog, genericAjaxFail, initializeSelectCtrl, dlgAjax, ConfirmDlg3 */
/*extern MessageBoxDlg, RteInputDlg, TextInputDlg, SelectInputDlg, singleInputDlg */
/*extern showInLightbox, showPartialInLightBox, ShowDivInLightbox */

// TODO-PER: temporary entry points until I can figure out what is wrong with simulate()
window.escFxn = null;
window.dlgThis = null;
window.enterFxn = null;

var initializeSelectCtrl = function(select_el_id, curr_sel, onchange_callback)
{
	var oMenuButton1 = new YAHOO.widget.Button(select_el_id, {
		type: "menu",
		menu: select_el_id + "select",
		selectedMenuItem: new YAHOO.widget.MenuItem(curr_sel)});

		//	"selectedMenuItemChange" event handler for a Button that will set
		//	the Button's "label" attribute to the value of the "text"
		//	configuration property of the MenuItem that was clicked.
		var onSelectedMenuItemChange = function (event) {
			var oMenuItem = event.newValue;
			var new_text = oMenuItem.cfg.getProperty("text");
			this.set("label", ("<span class=\"yui-button-label\">" +
				new_text + "</span>"));
			oMenuButton1.currSelectedValue = oMenuItem.value;	// TODO-PER: Don't know how to set this consistently in the control. There's probably an easier way.
//			if (curr_sel !== new_text) {
				onchange_callback(oMenuItem.value);
//			}
		};

		oMenuButton1.setSelection = function(id) {
			oMenuButton1.currSelectedValue = id;	// TODO-PER: Don't know how to set this consistently in the control. There's probably an easier way.
			oMenuButton1.get("selectedMenuItem").value = id;
		};

		//	Register a "selectedMenuItemChange" event handler that will sync the
		//	Button's "label" attribute to the MenuItem that was clicked.
		oMenuButton1.on("selectedMenuItemChange", onSelectedMenuItemChange);
		oMenuButton1.currSelectedValue = curr_sel;	// TODO-PER: Don't know how to set this consistently in the control. There's probably an easier way.
		return oMenuButton1;
};

// GeneralDialog params:
//	this_id: the id of this dialog
//	title (opt): the title; if blank, then no title bar appears.
//	width (opt): the width
//	flash_notice (opt): the initial message to put in the flash message
//	body_style (opt):	class to attach to the body
//	row_style (opt): class to attach to each row
//	focus (opt): the id to initially have focused
//	pages: array of pages
//
//	the page represents one form and only one is displayed at a time.
//	page: the id, name, and class to apply to the form.
//	rows: array describing each row.
//
//	row: array of elements to place in the row
//
//	element:
//
// text: whatToDisplay, klass (opt): classToAttach, id (opt): idOfElement [creates <span>]
// picture: src and alt, alt (opt): alt, klass (opt): classToAttach, id (opt): idOfElement [creates <img>]
// input: id and name, klass (opt): classToAttach, value (opt): initial value [creates <input type='text'>]
// inputFilter: id and name, klass (opt): classToAttach, value (opt): initial value, prompt: text when not focused, callback: function for each event [creates <input type='text'>]
// inputWithStyle: id and name, klass (opt): classToAttach, value (opt): { text: initial value, isBold: bool, isItalic: bool, isUnderline: bool }  [creates <input type='text'><button><button><button>]
// autocomplete: id and name, klass (opt): classToAttach, token (opt): character used to tokenize inout string, value (opt): initial value, url: callback
// hidden: id and name, klass (opt): classToAttach, value: initial value [creates <input type='hidden'>]
// password: id and name, klass (opt): classToAttach, value (opt): initial value [creates <input type='password'>]
// button: text on button, klass (opt): classToAttach, isDefault (opt): bool, isSubmit** (opt): bool, url** (opt): parameter passed to callback, callback: function to call when pressed [creates:<button>]
// colorpick: id and name, klass (opt), value (opt): initial color value displayed
// link: text on link, klass (opt): classToAttach, arg0 (opt): parameter passed to callback, callback: function to call when pressed, title (opt): tooltip [creates:<a>]
// select: id and name, klass (opt): classToAttach, callback (opt): function to call when selection changes, arg0: argument passed to callback, options (opt): array of { text: , value: }, value (opt): the initial selection [creates: <select>]
// custom: object that contains the control [defines functions: getMarkup(), getSelection()], klass (opt): classToAttach [creates: whatever the object wants]
// checkbox: id or name, klass (opt): classToAttach, value (opt): '1' if initially selected [creates: <input type=checkbox><span>]
// checkboxList: prefix of id and name, klass (opt): classToAttach, columns (opt): number of columns, items: array of either text, or [ id, text ], selections: array of initially selected items [creates: <table><tbody><tr><td><input type=checkbox><span>]
// radioList: id and name, klass (opt): classToAttach, options: array of { text: value: }, value (opt): initial selection [creates:<table><tbody><tr><td><input type=radio><span>]
// textarea: id and name, klass (opt): classToAttach, value (opt): initial value [creates:<textarea>]
// date: template for id and name, value (opt): initial value (expressed as 'yyyy-mm-dd .*') [creates: <select><select><select>]
// image: id and name, value (opt): src for current image, alt (opt): alt, size (opt): size of input box, klass(opt): class for encompassing div, removeButton (opt): link for button to remove current image. [creates: <div><img><input type=file><a></div>]
// file: id and name, size (opt): size of input box, klass(opt): class for encompassing div, no_iframe (opt): true if no iframe should be created
// rowClass: adds a class name to the current row
// TODO: button(does isSubmit work?),
//
// Member functions:
//	getOuterDomElement(): gets the outer wrapper div
//	getEditor(index): gets the index'th textarea
//	getAllData(): returns an array of all values that the user have filled in as [ {id: value:}].
//	getTitle(): returns the title of this dialog
//	setFlash(msg, is_error): sets the flash message at the top of the dialog.
//	changePage(view, focus_el): sets one page visible and the others hidden, and focuses a particular element
//	cancel(): cancels the dialog
//	center(): centers the dialog
//	initTextAreas({ toolbarGroups: linkDlgHandler: footnote: bodyStyle: onlyClass: only change textareas with this class}): changes textareas to RTE
//
//	Static functions:
//	makeId(name): removes brackets so that it is a legal html id
//	cancelCallback(event, params)
//	openInNewWindow(event, params)
//
// classes used:
//	hidden
//	clear_both
//	gd_flash_notice_error
//	gd_flash_notice_ok
//	gd_bold_button
//	gd_italic_button
//	gd_underline_button
//	gd_pressed
//	gd_input_hint_style
//	gd_switchable_element
//	gd_upload_target
//	gd_year
//	gd_month
//	gd_day
//
//	gd_message_box_label
//	gd_message_box_dlg
//	gd_message_box_row
//	gd_last_row
//
//	gd_lightbox_dlg
//	gd_lightbox_row
//	gd_lightbox_img_spinner
//
//	gd_transparent_progress_spinner
//	gd_transparent_progress_label
//	gd_progress_label_row
//	gd_progress_spinner_div
//	gd_progress_spinner_row
//
//	gd_text_input_dlg_label
//	gd_text_input_dlg_input
//	gd_select_dlg_input
//
//	ids used:
//		gd_modal_dlg_parent
//		gd_upload_target
//		all ids that begin with this_id
//
//		gd_message_box_dlg
//		gd_lightbox_dlg
//		gd_lightbox_contents
//		gd_lightbox_img_spinner
//		gd_lightbox_img
//		gd_lightbox_id
//		gd_progress_spinner_dlg
//		gd_bit_bucket
//		gd_postExplanation
//		gd_text_input_dlg
//		gd_select_dlg_input
//		gd_textareaValue
//

var GeneralDialog = Class.create({
	initialize: function (params) {
		this.class_type = 'GeneralDialog';	// for debugging

		// private variables
		var This = this;
		var this_id = params.this_id;
		var pages = params.pages;
		var initial_focus = params.focus;
		var flash_notice = params.flash_notice;
		if (flash_notice === undefined)
			flash_notice = "";
		var body_style = params.body_style ? params.body_style : '';
		var row_style = params.row_style;
		var title = params.title;
		var override_width = params.width;
		
		var flash_id = this_id + '_flash';
		var editors = [];
		var customList = [];

		var currPage = null;
		var defaultAction = {};
		var defaultParam = {};
		
		// A list of calls that should be made after the dialog is rendered
		var deferredCalls = [];
		
		// A wrapper class used to schedule a call with params in
		// the deferred call list. All objects in the list will
		/// get the executed() method called after the dialog is rendered
		var DeferredCall = Class.create({
         initialize: function (params) {
            var fn_call = params.fn_call;
            var call_params = params.call_params;
            
             this.execute = function() {
                fn_call(call_params);
             };
         }
      });

		var createAuthenticityInput = function(form) {
			var csrf_param = $$('meta[name=csrf-param]')[0].content;
			var csrf_token = $$('meta[name=csrf-token]')[0].content;
			form.appendChild(new Element('input', { id: csrf_param, type: 'hidden', name: csrf_param, value: csrf_token }));
		};
		
		var selectChange = function(event, param)
		{
			var This = $(this);
			var currSelection = This.value;
			var id = GeneralDialog.makeId(param.id);
			var el = $(id);
			el.value = currSelection;

			if (param.callback)
				param.callback(id, currSelection, param.arg0);
		};

		var initSelectCtrl = function(id, options, curr_sel, onchange_callback, arg0, container)
		{
			var selectValue = new Element('input', {id: GeneralDialog.makeId(id), name: id});
			if (options && options.length > 0) {
				var val = (curr_sel !== undefined  && curr_sel !== null) ? curr_sel : options[0].value;
				selectValue.writeAttribute('value', val);
			}
			selectValue.addClassName('hidden');
			container.appendChild(selectValue);
			var oMenuButton5 = null;

			//	"click" event handler for each item in the Button's menu
			var onMenuItemClick = function (p_sType, p_aArgs, p_oItem) {
				var sText = p_oItem.cfg.getProperty("text");
				//YAHOO.log("[MenuItem Properties] text: " + sText + ", value: " + p_oItem.value);
				oMenuButton5.set("label", sText);
				selectValue.writeAttribute('value', p_oItem.value);
				if (onchange_callback)
					onchange_callback(id, p_oItem.value, arg0);
			};

			//	Create an array of YAHOO.widget.MenuItem configuration properties
			var aMenuButton5Menu = [];
			var label = "";
			if (options) {
				for (var i = 0; i < options.length; i++) {
					aMenuButton5Menu.push({ text: options[i].text, value: options[i].value, onclick: { fn: onMenuItemClick }});
					if (options[i].value === curr_sel)
						label = options[i].text;
				}
			}

			//	Instantiate a Menu Button using the array of YAHOO.widget.MenuItem
			//	configuration properties as the value for the "menu"
			//	configuration attribute.
			oMenuButton5 = new YAHOO.widget.Button({ type: "menu", label: label, name: id, menu: aMenuButton5Menu, container: container, lazyloadmenu: false });
			return oMenuButton5;
		};

		var parent_id = 'gd_modal_dlg_parent';
		var parent = $(parent_id);
		if (parent === null) {
			var main = document.getElementsByTagName("body").item(0);
			$(main).down('div').insert({ before: new Element('div', { id: parent_id, style: 'text-align:left;' }) });
		}

		this.getOuterDomElement = function() {
			return $(this_id);
		};

		this.getEditor = function(index) {
			return editors[index];
		};

		this.getAllData = function() {
			var inputs = $$("#" + this_id + " input");
			var csrf_param = $$('meta[name=csrf-param]')[0].content;
			var csrf_token = $$('meta[name=csrf-token]')[0].content;

			var data = { };
			data[csrf_param] = csrf_token;
			inputs.each(function(el) {
				if (el.type === 'checkbox') {
					data[el.name] = el.checked;
				} else if (el.type === 'radio') {
					if (el.checked)
						data[el.name] = el.value;
				} else if (el.type !== 'button') {
					data[el.name] = el.value;
				}
			});
			
			editors.each(function(editor) {
				editor.save();
			});
			
			customList.each(function(ctrl) {
				var cl = ctrl.getSelection();
				if (cl.field)
					data[cl.field] = cl.value;
			});
	
			var textareas = $$("#" + this_id + " textarea");
			textareas.each(function(el) {
				var id = el.name;
				var value = el.value;
				data[id] = value;
			});
			return data;
		};
		
		this.getTitle = function() {
			return title;
		};
		
		var handleCancel = function() {
		    this.cancel();
		};
		
		var panel = new YAHOO.widget.Dialog(this_id, {
			constraintoviewport: true,
			width: override_width,
			modal: true,
			close: (title !== undefined),
			draggable: (title !== undefined),
			underlay: 'shadow',
			buttons: null
		});
		
		this.setFlash = function(msg, is_error) {
			var flash = $(flash_id);
			if (flash) {	// If the user canceled before this message came in, the element may not exist. That's ok, just ignore it.
				if (panel)
					panel.show();	// This is because Safari closes the dialog when the user hits enter. We need to bring it back if the user's not finished with it.
				flash.update(msg);
				if (is_error) {
					flash.addClassName('gd_flash_notice_error');
					flash.removeClassName('gd_flash_notice_ok');
				} else {
					flash.addClassName('gd_flash_notice_ok');
					flash.removeClassName('gd_flash_notice_error');
				}
			}
		};

		if (title !== undefined)
			panel.setHeader(title);

		var klEsc = new YAHOO.util.KeyListener(document, { keys:27 },
			{ fn:handleCancel,
				scope:panel,
				correctScope:true }, "keyup" ); // keyup is used here because Safari won't recognize the ESC keydown event, which would normally be used by default

		var defaultFxn = function() {
			if (defaultAction[currPage])
				defaultAction[currPage](null, defaultParam[currPage]);
		};

		var klEnter = new YAHOO.util.KeyListener(document, {keys:13},
			{fn:defaultFxn,
				scope:panel,
				correctScope:true}, "keydown" );
		window.escFxn = handleCancel;
		window.enterFxn = defaultFxn;
		window.dlgThis = panel;
		panel.cfg.queueProperty("keylisteners", [klEsc, klEnter]);

		// Create all the html for the dialog
		var listenerArray = [];
		var buttonArray = [];
		var body = new Element('div', { id: this_id + '_' + body_style });
		body.addClassName(body_style);
		var flash = new Element('div', { id: flash_id }).update(flash_notice);
		flash.addClassName("gd_flash_notice_ok");
		body.appendChild(flash);

		var addButton = function(parent_el, text, klass, callback, page, url, typ) {
			var input = new Element('input', { id: this_id + '_btn' + buttonArray.length, 'type': typ, value: text });
			parent_el.appendChild(input);
			var buttonClass = klass;
			buttonArray.push({ id: this_id + '_btn' + buttonArray.length, event: 'click', klass: buttonClass, callback: callback, param: { curr_page: page, arg0: url, dlg: This } });
		};

		var addInput = function(parent_el, text, klass, value) {
			var el1 = new Element('input', { id: GeneralDialog.makeId(text), 'type': 'text', name: text });
			if (klass)
				el1.addClassName(klass);
			if (value !== undefined)
				el1.writeAttribute({value: value });
			parent_el.appendChild(el1);
			return el1;
		};

		var initAutoComplete = function( params ) {
           new Ajax.Autocompleter(params.input_id, params.results_id, params.url, {minChars:1});
        };
		
		var addAutocomplete = function(parent_el, id, klass, url, token, value) {

         var ac_id = GeneralDialog.makeId(id);
         var ac_div_id = ac_id+"_wrapper";
         var ac_div = new Element('div', { id: ac_div_id} );
         if (klass !== undefined)
             ac_div.addClassName(klass);
            
         // add the input box
         var ac_input = new Element('input', { id: ac_id, 'type': 'text', name:  id});
         if (value !== undefined)
            ac_input.writeAttribute({value: value });
         ac_div.appendChild(ac_input);
         
         // add the dropdown autocomplete matches list
         var ac_dd_id = ac_id+"_dd";
         var ac_dd_div = new Element('div', { id: ac_dd_id });
         ac_dd_div.addClassName("gd_autocomplete");
         ac_div.appendChild(ac_dd_div);
         
         // add the whole autocomplete div to the parent
         parent_el.appendChild(ac_div);
         
         //add a new call to init the autocomplete ajax after the dialog is rendered
         deferredCalls.push( new DeferredCall( {fn_call: initAutoComplete, call_params: {input_id: ac_id, results_id: ac_dd_id, url: url, token: token} }) );
		};
		
		// Add a colorpicker button to the dialog
		var addColorPick = function(parent_el, id, klass, callback, value) {
		   // TODO
      }
   
		var addHidden = function(parent_el, id, klass, value) {
			var el0 = new Element('input', { id: GeneralDialog.makeId(id), name: id, 'type': 'hidden' });
			if (klass)
				el0.addClassName(klass);
			if (value !== undefined && value !== null)
				el0.writeAttribute({value: value });
			parent_el.appendChild(el0);
		};

		var addLink = function(parent_el, klass, text, callback, callback_params, title) {
			var p = { id: this_id + '_a' + listenerArray.length, onclick: 'return false;', href: '#' };
			if (title)
				p.title = title;
			var a = new Element('a', p).update(text);
			//a.addClassName('nav_link');
			if (klass)
				a.addClassName(klass);
			parent_el.appendChild(a);
			listenerArray.push({ id: this_id + '_a' + listenerArray.length, event: 'click', callback: callback, param: callback_params });
		};

		var addIconButton = function(parent_el, text, klass, callback, page, context) {
			var button_id = this_id + '_a' + listenerArray.length;
			addLink(parent_el, klass, '', callback, { curr_page: page.page, button_id: button_id, context: context, dlg: This }, text);
		};

		var styleButtonPushed = function(ev, params) {
			 var el = $(params.button_id);
			 var context = params.context;
			 var style = context.style;
			 var styleHash = {};
			 var hidden = $(context.dest + '_' + context.value);
			 if (el.hasClassName('gd_pressed')) {
				 el.removeClassName('gd_pressed');
				 styleHash[style] = '';
				 $(context.dest).setStyle(styleHash);
				 hidden.value = 0;
			 }
			 else {
				 el.addClassName('gd_pressed');
				 styleHash[style] = context.value;
				 $(context.dest).setStyle(styleHash);
				 hidden.value = 1;
			 }
		};

		var filterEvent = function(ev, params) {
			var filterString = this.value;	//TODO-PER: why was this lowercased? .toLowerCase();
			if (ev.type === 'blur' && filterString === '') {
				$(this).addClassName('gd_input_hint_style');
				this.value = params.prompt;
			} else if (ev.type === 'focus'  && filterString === params.prompt) {
				this.value = '';
				$(this).removeClassName('gd_input_hint_style');
			} else if (ev.type === 'keyup') {
				params.callback(this.value);
			}
		};

		pages.each(function(page) {
			var form = new Element('form', { id: page.page, name: page.page });
			form.addClassName(page.page);	// IE doesn't seem to like the 'class' attribute in the Element, so we set the classes separately.
			form.addClassName("gd_switchable_element");
			if (pages.length > 1)
				form.addClassName("hidden");
			else
				currPage = page.page;
			body.appendChild(form);
			page.rows.each(function (el){
				var row = new Element('div');
				if (row_style)
					row.addClassName(row_style);
				form.appendChild(row);
				el.each(function (subel) {
						// TEXT
					if (subel.text !== undefined) {
						var elText = new Element('span').update(subel.text);
						if (subel.klass)
							elText.addClassName(subel.klass);
						if (subel.id !== undefined)
							elText.writeAttribute({ id: GeneralDialog.makeId(subel.id) });
						row.appendChild(elText);
						// PICTURE
					} else if (subel.picture !== undefined) {
						var picAlt = subel.alt ? subel.alt : subel.picture;
						var elPic = new Element('img', {src: subel.picture, alt: picAlt});
						if (subel.klass)
							elPic.addClassName(subel.klass);
						if (subel.id !== undefined)
							elPic.writeAttribute({id: GeneralDialog.makeId(subel.id)});
						row.appendChild(elPic);
						// INPUT
					} else if (subel.input !== undefined) {
						addInput(row, subel.input, subel.klass, subel.value);
						// INPUT FILTER
					} else if (subel.inputFilter !== undefined) {
						var klass3 = 'gd_input_hint_style';
						if (subel.klass !== undefined)
							klass3 += " " + subel.klass;
						var el3 = addInput(row, subel.inputFilter, klass3, subel.value);
						el3.value = subel.prompt;
						listenerArray.push({ id: subel.inputFilter, event: 'keyup', callback: filterEvent, param: { prompt: subel.prompt, callback: subel.callback } });
						listenerArray.push({ id: subel.inputFilter, event: 'blur', callback: filterEvent, param: { prompt: subel.prompt, callback: subel.callback } });
						listenerArray.push({ id: subel.inputFilter, event: 'focus', callback: filterEvent, param: { prompt: subel.prompt, callback: subel.callback } });
						// INPUT WITH STYLE
					} else if (subel.inputWithStyle !== undefined) {
						var iwsValue = subel.value ? subel.value : { text: '', isBold: false, isItalic: false, isUnderline: false };
						var el1 = addInput(row, subel.inputWithStyle, subel.klass, iwsValue.text);
						addIconButton(row, 'Bold', 'gd_bold_button' + (iwsValue.isBold ? " gd_pressed" : ""), styleButtonPushed, page, { dest: subel.inputWithStyle, style: 'fontWeight', value: 'bold' });
						addHidden(row, subel.inputWithStyle + '_bold', '', iwsValue.isBold ? '1' : '0');
						addIconButton(row, 'Italic', 'gd_italic_button' + (iwsValue.isItalic ? " gd_pressed" : ""), styleButtonPushed, page, { dest: subel.inputWithStyle, style: 'fontStyle', value: 'italic' });
						addHidden(row, subel.inputWithStyle + '_italic', '', iwsValue.isItalic ? '1' : '0');
						addIconButton(row, 'Underline', 'gd_underline_button' + (iwsValue.isUnderline ? " gd_pressed" : ""), styleButtonPushed, page, { dest: subel.inputWithStyle, style: 'textDecoration', value: 'underline' });
						addHidden(row, subel.inputWithStyle + '_underline', '', iwsValue.isUnderline ? '1' : '0');
						if (iwsValue.isBold)
							el1.setStyle({ fontWeight: 'bold' });
						if (iwsValue.isItalic)
							el1.setStyle({ fontStyle: 'italic' });
						if (iwsValue.isUnderline)
							el1.setStyle({ textDecoration: 'underline' });
						// AUTOCOMPLETE
					} else if ( subel.autocomplete !== undefined ) {
					    addAutocomplete(row, subel.autocomplete, subel.klass, subel.url, subel.token, subel.value);
					    // HIDDEN
					} else if (subel.hidden !== undefined) {
						addHidden(row, subel.hidden, subel.klass, subel.value);
						// PASSWORD
					} else if (subel.password !== undefined) {
						var el2 = new Element('input', { id: GeneralDialog.makeId(subel.password), name: subel.password, 'type': 'password'});
						if (subel.klass)
							el2.addClassName(subel.klass);
						if (subel.value !== undefined && subel.value !== null)
							el2.writeAttribute({value: subel.value });
						row.appendChild(el2);
						// COLORPICK
               } else if ( subel.colorpick !== undefined ) {
                   addColorPick(row, subel.colorpick, subel.klass, subel.callback, subel.value);
						// BUTTON
					} else if (subel.button !== undefined) {
						var buttonClass = subel.klass;
						if (subel.isDefault) {
							defaultAction[page.page] = subel.callback;
							defaultParam[page.page] = { curr_page: page.page, arg0: subel.arg0, dlg: This };
							buttonClass = (buttonClass === undefined) ? "default" : buttonClass + " default" ;
						}
						addButton(row, subel.button, buttonClass, subel.callback, page.page, subel.arg0, subel.isSubmit === true ? 'submit' : 'button');
						// ICON BUTTON
					} else if (subel.icon_button !== undefined) {
						addIconButton(row, subel.icon_button, subel.klass, subel.callback, page, subel.context);
						// LINK
					} else if (subel.link !== undefined) {
						addLink(row, subel.klass, subel.link,  subel.callback, { curr_page: page.page, arg0: subel.arg0, dlg: This }, subel.title);
						// SELECT
					} else if (subel.select !== undefined) {
						if (window.mockAjax)	// TODO-PER: Consolidate these two -- eventually style the select control instead of using the default.
							initSelectCtrl(subel.select, subel.options, subel.value, subel.callback, subel.arg0, row);
						else {
							var selectValue = new Element('input', {id: GeneralDialog.makeId(subel.select), name: subel.select});
							if (subel.options && subel.options.length > 0) {
								var val = (subel.value !== undefined  && subel.value !== null) ? subel.value : subel.options[0].value;
								selectValue.writeAttribute('value', val);
							}
							selectValue.addClassName('hidden');
							row.appendChild(selectValue);
							var select = new Element('select', {id: this_id + '_sel' + listenerArray.length});
							if (subel.klass)
								select.addClassName(subel.klass);
							row.appendChild(select);
							listenerArray.push({id: this_id + '_sel' + listenerArray.length, event: 'change', callback: selectChange, param: {id: subel.select, callback: subel.callback, arg0: subel.arg0}});
							if (subel.options) {
								subel.options.each(function(opt) {
									var opt2 = new Element('option', {value: opt.value}).update(opt.text);
									if (subel.value === opt.value)
										opt2.writeAttribute('selected', 'selected');
									select.appendChild(opt2);
								});
							}
						}
						// CUSTOM
					} else if (subel.custom !== undefined) {
						var custom = subel.custom;
						customList.push(subel.custom);
						var div = custom.getMarkup();
						if (subel.klass)
							div.addClassName(subel.klass);
						row.appendChild(div);
						// CHECKBOX
					} else if (subel.checkbox !== undefined) {
						var checkbox = new Element('input', { id: GeneralDialog.makeId(subel.checkbox), 'type': "checkbox", value: '1', name: subel.checkbox });
						if (subel.klass)
							checkbox.addClassName(subel.klass);
						if (subel.value === '1' || subel.value === true)
							checkbox.checked = true;
						row.appendChild(checkbox);
						// CHECKBOX LIST
					} else if (subel.checkboxList !== undefined) {
						var tb = new Element('table');
						var tbody = new Element('tbody');
						tb.appendChild(tbody);
						var numCols = subel.columns ? subel.columns : 1;
						if (numCols <= 0) numCols = 1;
						var numRows = Math.ceil(subel.items.length / numCols);
						var checkbox_id = null;
						var fnDetect = function(it)  {return checkbox_id === it;};
						for (var i = 0; i < numRows; i++) {
							var cbRow = new Element('tr');
							tb.appendChild(cbRow);
							for (var j = 0; j < numCols; j++){
								var itemNum = j*numRows+i;
								if (itemNum < subel.items.length) {
									var item = subel.items[itemNum];
									checkbox_id = item;
									var checkbox_text = item;
									if (typeof item !== 'string') {
										checkbox_id = item[0];
										checkbox_text = item[1];
									}
									var cbCol = new Element('td', {style : 'padding: 0 0.5em 0 0.5em;'});
									var cbId = subel.checkboxList+'['+checkbox_id+']';
									var cbox = new Element('input', {id: GeneralDialog.makeId(cbId), 'type': "checkbox", value: '1', name: cbId});
									if (subel.klass)
										cbox.addClassName(subel.klass);
									if (subel.selections && subel.selections.detect(fnDetect))
										cbox.checked = true;
									cbCol.appendChild(cbox);
									var lbl = new Element('span').update(checkbox_text);
									cbCol.appendChild(lbl);
									cbRow.appendChild(cbCol);
								}
							}
							row.appendChild(tb);
						}
						// RADIO LIST
					} else if (subel.radioList !== undefined) {
						var radioList = subel.options;
						var radioId = subel.radioList;
						var radioValue = subel.value;
						var radioKlass = subel.klass;
						var radioTable = new Element('table');
						if (radioKlass)
							radioTable.addClassName(radioKlass);
						row.appendChild(radioTable);
						var radioBody = new Element('tbody');
						radioTable.appendChild(radioBody);
						radioList.each(function(radio) {
							var rlText = radio;
							var rlValue = radio;
							if (typeof radio !== 'string') {
								rlText = radio.text;
								rlValue = radio.value;
							}
							var radioRow = new Element('tr');
							radioBody.appendChild(radioRow);
							var radioCol = new Element('td');
							radioRow.appendChild(radioCol);
							var elRadio = new Element('input', {id: GeneralDialog.makeId(radioId+'_'+rlValue), type: 'radio', value: rlValue, name: radioId});
							if (radioValue === rlValue)
								elRadio.writeAttribute('checked', 'true');
							radioCol.appendChild(elRadio);
							radioCol = new Element('td');
							radioRow.appendChild(radioCol);
							radioCol.appendChild(new Element('span').update(' ' + rlText + '<br />'));
						});
						// TEXTAREA
					} else if (subel.textarea !== undefined) {
						var wrapper = new Element('div');
						var textarea = new Element('textarea', { id: GeneralDialog.makeId(subel.textarea), name: subel.textarea });
						if (subel.klass) {
							textarea.addClassName(subel.klass);
							wrapper.addClassName(subel.klass);
						}
						if (subel.value !== undefined && subel.value !== null) {
							// The string probably has some extra stuff at the beginning and end, so we'll get rid of that first
							var v = subel.value.strip();
							v = v.escapeHTML();	// Need to escape this to get the tags to be transferred in Safari.
							textarea.update(v);
						}
						wrapper.appendChild(textarea);
						row.appendChild(wrapper);
						// DATE
					} else if (subel.date !== undefined) {
						var start_date = (subel.value) ? subel.value.split(' ')[0].split('-') : ['', '', ''];
						var year = new Element('select', { id: GeneralDialog.makeId(subel.date.gsub('*', '1i')), name: subel.date.gsub('*', '(1i)') });
						for (var y = 2005; y < 2015; y++) {
							if (start_date[0] === '' + y)
								year.appendChild(new Element('option', { value: "" + y, selected: 'selected' }).update("" + y));
							else
								year.appendChild(new Element('option', { value: "" + y }).update("" + y));
						}
						var month = new Element('select', { id: GeneralDialog.makeId(subel.date.gsub('*', '2i')), name: subel.date.gsub('*', '(2i)') });
						var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
						var monthNums = [ '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'];
						for (var m = 0; m < months.length; m++) {
							if (start_date[1] === monthNums[m])
								month.appendChild(new Element('option', { value: m+1, selected: 'selected' }).update(months[m]));
							else
								month.appendChild(new Element('option', { value: m+1 }).update(months[m]));
						}
						var day = new Element('select', { id: GeneralDialog.makeId(subel.date.gsub('*', '3i')), name: subel.date.gsub('*', '(3i)') });
						for (var d = 1; d <= 31; d++) {
							if (start_date[2] === (d<10?'0':'') + d)
								day.appendChild(new Element('option', { value: "" + d, selected: 'selected' }).update("" + d));
							else
								day.appendChild(new Element('option', { value: "" + d }).update("" + d));
						}
						var dateClass = subel.klass ? subel.klass + ' ' : '';
						year.addClassName(dateClass + 'gd_year');
						month.addClassName(dateClass + 'gd_month');
						day.addClassName(dateClass + 'gd_day');
						row.appendChild(year);
						row.appendChild(month);
						row.appendChild(day);
						// IMAGE
					} else if (subel.image !== undefined) {
						var image = new Element('div', { id: GeneralDialog.makeId(subel.image) + '_div' });
						var src = (subel.value !== undefined  && subel.value !== null) ? subel.value : "";
						if (src.length > 0) {
							var imgAlt = subel.alt ? subel.alt : src;
							image.appendChild(new Element('img', { src: src, id: GeneralDialog.makeId(subel.image) + "_img", alt: imgAlt }));
						}
						var createFileInput = function() {
							var file_input = new Element('input', { id: GeneralDialog.makeId(subel.image), type: 'file', name: subel.image });
							if (subel.size)
								file_input.writeAttribute({ size: subel.size});
							return file_input;
						};
						var file_input = createFileInput();
						image.appendChild(file_input);
						if (subel.klass)
							image.addClassName(subel.klass);
						row.appendChild(image);
						createAuthenticityInput(row);
						if (subel.removeButton !== undefined) {
							var remove = function() {
								var el = $(GeneralDialog.makeId(subel.image));
								el.remove();
								el = $(GeneralDialog.makeId(subel.image) + "_img");
								if (el)
									el.src = '';
								var file_input = createFileInput();
								image.appendChild(file_input);
							};
							addLink(row, this_id, null, subel.removeButton,  remove, { });
						}
						
						// We have to go through a bunch of hoops to get the file uploaded, since
						// you can't upload a file through Ajax.
						form.writeAttribute({ enctype: "multipart/form-data", target: "gd_upload_target", method: 'post' });
						$(parent_id).appendChild(new Element('iframe', { id: "gd_upload_target", name: "gd_upload_target", src: "", style: "display:none;width:0;height:0;border:0px solid #fff;" }));
						// FILE INPUT
					} else if (subel.file !== undefined) {
						var file_input2 = new Element('input', { id: GeneralDialog.makeId(subel.file), type: 'file', name: subel.file });
							if (subel.size)
								file_input2.writeAttribute({ size: subel.size});
						row.appendChild(file_input2);
						if (subel.klass)
							file_input2.addClassName(subel.klass);
						row.appendChild(file_input2);
						createAuthenticityInput(row);

						// We have to go through a bunch of hoops to get the file uploaded, since
						// you can't upload a file through Ajax.
						if (subel.no_iframe)
							form.writeAttribute({ enctype: "multipart/form-data", method: 'post' });
						else {
							form.writeAttribute({ enctype: "multipart/form-data", target: "gd_upload_target", method: 'post' });
							$(parent_id).appendChild(new Element('iframe', { id: "gd_upload_target", name: "gd_upload_target", src: "#", style: "display:none;width:0;height:0;border:0px solid #fff;" }));
						}
						// ROW CLASS
					} else if (subel.rowClass !== undefined) {
						row.addClassName(subel.rowClass);
					}
				});
			});
			var row = new Element('div');
			row.addClassName('clear_both');
			form.appendChild(row);
		});

		panel.setBody(body);
		panel.render(parent_id);

		panel.cancelEvent.subscribe(function(e, a, o){
			setTimeout(function() { panel.destroy(); }, 500);
		});
		
		listenerArray.each(function (listen) {
			YAHOO.util.Event.addListener(listen.id, listen.event, listen.callback, listen.param); 
		});
		
		buttonArray.each(function(btn){
			var fn = function(event, id) {
				var cb = btn.callback.bind($(id));
				cb(event, btn.param);
			};

			var typ = $(btn.id).type;
			new YAHOO.widget.Button(btn.id, { onclick: { fn: fn, obj: btn.id, scope: this }});
			if (btn.klass)
				YAHOO.util.Event.onContentReady(btn.id, function() {$(btn.id).addClassName(btn.klass); });
			YAHOO.util.Event.onContentReady(btn.id, function() {$(btn.id+'-button').type = typ; });
		});

		customList.each(function(ctrl) {
			if (ctrl.delayedSetup)
				ctrl.delayedSetup();
		});
		
		// execute all deferred calls now
		deferredCalls.each( function(fn_call) {
		    fn_call.execute();
		});

		if (initial_focus && $(initial_focus))
			$(initial_focus).focus();

		// These are all the elements that can be turned on and off in the dialog.
		// All elements have gd_switchable_element, and they each then have another class
		// that matches the value of the view parameter. Then this loop either hides or shows
		// each element.
		this.changePage = function(view, focus_el) {
			currPage = view;
			var els = $(this_id).select('.gd_switchable_element');
			els.each(function (el) {
				if (el.hasClassName(view))
					el.removeClassName('hidden');
				else
					el.addClassName('hidden');
			});
			
			if (focus_el && $(focus_el))
				$(focus_el).focus();
		};
		
		this.cancel = function() {
			panel.cancel();
		};
		
		this.center = function() {
			var dlg = $(this_id);
			var w = parseInt(dlg.getStyle('width'), 10);
			var h = parseInt(dlg.getStyle('height'), 10);
			var vw = YAHOO.util.Dom.getViewportWidth();
			var vh = YAHOO.util.Dom.getViewportHeight();
			var x = (vw - w) / 2;
			var y = (vh - h) / 2;
			x += YAHOO.util.Dom.getDocumentScrollLeft();
			y += YAHOO.util.Dom.getDocumentScrollTop();
			if (x < 0) x = 0;
			if (y < 0) y = 0;
			var el = dlg.up();
			el.setStyle({ left: x + 'px', top: y + 'px'});
		};
		
		this.initTextAreas =  function(params) {
			var toolbarGroups = params.toolbarGroups;
			var linkDlgHandler = params.linkDlgHandler;
			var footnote = params.footnote;
			var bodyStyle = params.bodyStyle;
			var onlyClass = params.onlyClass;

			var dlg = $(this_id);
			var w = parseInt(dlg.getStyle('width'), 10);
			var inner_el = dlg.down('.bd');
			var padL = parseInt(inner_el.getStyle('padding-left'));
			var padR = parseInt(inner_el.getStyle('padding-right'));
			var width = w - padL - padR;
			
			var textAreas = $$("#" + this_id + " textarea");
			textAreas.each( function(textArea) {
				if (onlyClass === undefined || textArea.hasClassName(onlyClass)) {
					var editor = new RichTextEditor({id: textArea.id, toolbarGroups: toolbarGroups, linkDlgHandler: linkDlgHandler, width: width, footnote: footnote, populate_exhibit_only: linkDlgHandler.getPopulateUrls()[0], populate_all: linkDlgHandler.getPopulateUrls()[1],  bodyStyle: bodyStyle});
					editor.attachToDialog(panel);
					editors.push(editor);
				}
			}, this);
		};
		
	}
});

GeneralDialog.cancelCallback = function(event, params) {
	params.dlg.cancel();
};

GeneralDialog.makeId = function(str) {
	// This checks to see if the id is of the form xxx[yyy]. If so, it replaces the first [ with _ and the second with nothing.
	return str.gsub(/\[/, '_').gsub(']', '');
};

/////////////////////////////////////////////////////
// Here are some generic uses for the the above dialog
/////////////////////////////////////////////////////

var MessageBoxDlg = Class.create({
	initialize: function (title, message) {
		// This puts up a modal dialog that replaces the alert() call.
		this.class_type = 'MessageBoxDlg';	// for debugging

		// private variables
		//var This = this;
		
		// privileged functions
		
		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { text: message, klass: 'gd_message_box_label' } ],
					[ { rowClass: 'gd_last_row' }, { button: 'Close', callback: GeneralDialog.cancelCallback, isDefault: true } ]
				]
			};
		
		var params = { this_id: "gd_message_box_dlg", pages: [ dlgLayout ], body_style: "gd_message_box_dlg", row_style: "gd_message_box_row", title: title };
		var dlg = new GeneralDialog(params);
		//dlg.changePage('layout', null);
		dlg.center();

		this.cancel = function() {dlg.cancel();};
	}
});

// Parameters:
// id: the element's id that should be shown in the light box
// div: a Prototype structure of the dom elements that should be shown.
// klass: the css class that should be applied to that element
// title: the title of the lightbox
//
var ShowDivInLightbox = Class.create({
	initialize: function (params) {
		this.class_type = 'ShowDivInLightbox';	// for debugging

		// private variables
		//var This = this;
		var Div = Class.create({
			id: params.id,
			div: params.div,
			getMarkup: function() {
				if (this.div)
					return this.div;
				
				var str = $(this.id).innerHTML;
				var div = new Element('div').update(str);
				//div.addClassName(params.klass);
				return div;
			}
		});

		// privileged functions

		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { custom: new Div(), klass: params.klass } ],
					[ { rowClass: 'gd_last_row' }, { button: 'Close', callback: GeneralDialog.cancelCallback, isDefault: true } ]
				]
			};

		var dlgParams = { this_id: "gd_lightbox_dlg", pages: [ dlgLayout ], body_style: "gd_lightbox_dlg", row_style: "gd_lightbox_row", title: params.title };
		var dlg = new GeneralDialog(dlgParams);
		//dlg.changePage('layout', null);
		dlg.center();
		this.dlg = dlg;
	}
});

function showPartialInLightBox(ajax_url, title, progress_img)
{
	var div = new Element('div', { id: 'gd_lightbox_contents' });
	//div.setStyle({display: 'none' });
	var form = div.wrap('div', { id: "gd_lightbox_id"});
	var progress = new Element('center', { id: 'gd_lightbox_img_spinner'});
	progress.addClassName('gd_lightbox_img_spinner');
	progress.appendChild(new Element('div').update("Loading..."));
	progress.appendChild(new Element('img', { src: progress_img, alt: ''}));
	progress.appendChild(new Element('div').update("Please wait"));
	form.appendChild(progress);
	var lightbox = new ShowDivInLightbox({ title: title, div: form });
	var onComplete = function(resp) {
			var img_spinner = $('gd_lightbox_img_spinner');
			if (img_spinner)
				img_spinner.remove();
			$('gd_lightbox_contents').show();
			lightbox.dlg.center();
	};
	var onFailure = function(resp) {
			var img_spinner = $('gd_lightbox_img_spinner');
			if (img_spinner)
				img_spinner.remove();
			$('gd_lightbox_contents').update(formatFailureMsg(resp, ajax_url));
			$('gd_lightbox_contents').setStyle({ width: '450px', color: 'red' });
			$('gd_lightbox_contents').show();
			lightbox.dlg.center();
	};
	serverAction({ action: { actions: ajax_url, els: 'gd_lightbox_contents', params: {}, onSuccess: onComplete, onFailure: onFailure } });
	//ajaxCall({action: ajax_url, params: {}, el: 'gd_lightbox_contents', onSuccess: onComplete, onFailure: onFailure });
}

function showInLightbox(params)
{
	var title = params.title;
	var imageUrl = params.img;
	var progress_img = params.spinner;
	var size = params.size; // width (optional): the max width for the div. Anything larger will have scrollbars.
	// If the size is set, then the div wrapping the img is set to the size initially. There is a margin between that div and
	// the outer dialog, which has the resize controls.

	var lightbox = null;
	var loaded = function() {
		var img_spinner = $('gd_lightbox_img_spinner');
		if (img_spinner)
			img_spinner.remove();
		var image = $('gd_lightbox_img');
		image.show();
		if (size && (image.width > size || image.height > size)) {
			var resizeDiv = $('gd_lightbox_dlg');
			var marginX = parseInt(resizeDiv.getStyle('width')) - image.width;
			var marginY = parseInt(resizeDiv.getStyle('height')) - image.height;
			var constrainX = (image.width > image.height);	// Constrain by the larger size
			var origWidth = image.width;
			var origHeight = image.height;
			if (constrainX)
				image.width = size;
			else
				image.height = size;
			var onResize = function(e) {
				if (constrainX)
					image.width = e.width - marginX;
				else
					image.height = e.height - marginY;
			};
			var resize = null;
			if (constrainX)
				resize = new YAHOO.util.Resize('gd_lightbox_dlg', { maxWidth: origWidth+marginX, minWidth: 140, ratio: true, handles: [ 'br' ] });
			else
				resize = new YAHOO.util.Resize('gd_lightbox_dlg', { maxHeight: origHeight+marginY+16, minHeight: 140, ratio: true, handles: [ 'br' ] });	// add a little extra for the grabber bar height.
			resize.on('resize', onResize);
			$('gd_lightbox_dlg_h').setStyle({ whiteSpace: 'nowrap', overflow: 'hidden' });
		}
		lightbox.dlg.center();
	};

	var divName = "lightbox";
	var img = new Element('img', { id: 'gd_lightbox_img', alt: ""});
	img.setStyle({display: 'none' });
	var form = img.wrap('div', { id: divName + "_id"});

	var progress = new Element('center', { id: 'gd_lightbox_img_spinner'});
	progress.addClassName('gd_lightbox_img_spinner');
	progress.appendChild(new Element('div').update("Image Loading..."));
	progress.appendChild(new Element('img', { src: progress_img, alt: ''}));
	progress.appendChild(new Element('div').update("Please wait"));
	form.appendChild(progress);
	lightbox = new ShowDivInLightbox({ title: title, div: form });
	img.observe('load', loaded);
	img.setAttribute('src', imageUrl);
}

var ConfirmDlg3 = Class.create({
	initialize: function (title, message, yesStr, noStr, cancelStr, yesAction, noAction) {
		// This puts up a modal dialog that replaces the confirm() call.

		this.yes = function(event, params)
		{
			params.dlg.cancel();
			yesAction();
		};

		this.no = function(event, params)
		{
			params.dlg.cancel();
			noAction();
		};

		var dlgLayout = {
				page: 'layout',
				rows: [
					[ {rowClass: 'gd_confirm_msg_row'}, {text: message, klass: 'gd_confirm_label'} ],
					[ {rowClass: 'gd_last_row'}, {button: yesStr, callback: this.yes, isDefault: true}, {button: noStr, callback: this.no}, {button: cancelStr, callback: GeneralDialog.cancelCallback} ]
				]
			};

		var params = {this_id: "gd_confirm_dlg", pages: [ dlgLayout ], body_style: "gd_confirm_dlg", row_style: "gd_confirm_row", title: title};
		var dlg = new GeneralDialog(params);
		//dlg.changePage('layout', null);
		dlg.center();
	}
});

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Parameters:
//	title: The title of the dialog.
//	prompt: Text that appears just above or to the left of the input control.
//	id: The id that is sent to the server with the value the user enters.
//	okStr: The text on the button that sends the data to the server. (Default: 'Ok')
//	actions: An array of the URLs that will AJAXed, or a string containing a URL to be AJAXed, or a comma separated string of the URLs to be AJAXed.
//	onSuccess: A function to call with one parameter: the response object from Ajax, after the operation was successful and the dlg is dismissed. (optional)
//	onFailure: A function to call with one parameter: the response object from Ajax, if the operation was unsuccessfull the dlg is not dismissed. (optional)
//	target_els: null, if this should not be Ajax, but should PUT the form instead, or the same format as the actions parameters. This is a list of ids to <div> that will be updated by the ajax calls.
//	extraParams: This is a hash that is passed directly through the Ajax call to the server. (optional)
//	noDefault: if this is true, then there is no default button; that is, the enter key will do nothing. (default: false)
//	pleaseWaitMsg: This is the flash message that appears when the Ajax call is in progress. (default: "Please wait...")
//	verify: This is a URL to call to verify the user's parameters. If the response comes back with a status of 200, then the actions are performed, otherwise the text that is returned is displayed as a flash message. (optional)
//	verifyFxn: A function that is called when the user hits ok and before any Ajax call is made. The data that will be Ajaxed is passed as a hash. It returns null if the parameters are ok, or a string that should be displayed if there is a problem (optional)
//	body_style: The css style of the dialog. (default: gd_message_box_dlg)
//	populate: This is a function that is called after the dlg appears. The dlg object is passed to it. (optional)
//
var singleInputDlg = function(params, input) {
	var title = params.title;
	var prompt = params.prompt;
	var id = params.id;
	var okStr = params.okStr ? params.okStr : 'Ok';
	var actions = params.actions;
	var onSuccess = params.onSuccess;
	var onFailure = params.onFailure;
	var target_els = params.target_els;
	var extraParams = params.extraParams ? params.extraParams : {};
	var noDefault = params.noDefault;
	var pleaseWaitMsg = params.pleaseWaitMsg ? params.pleaseWaitMsg : "Please wait...";
	var dlg = null;
	var verifyUrl = params.verify;
	var verifyFxn = params.verifyFxn;
	var body_style = params.body_style === undefined ? "gd_message_box_dlg": params.body_style;
	var populate = params.populate;
	var explanation_klass = params.explanation_klass;

	// This puts up a modal dialog that asks for a single line of input, then Ajax's that to the server.
	this.class_type = 'singleInputDlg';	// for debugging

	// private variables
	//var This = this;
	var addCancelToSuccess = function(resp) {
		dlg.cancel();
		if(onSuccess)
			onSuccess(resp);
	};

	var onVerified = function(params) {
		var vact = actions;
		if (!Object.isArray(vact))
			vact = [ vact ];
		var vels = target_els;
		if (!Object.isArray(vels))
			vels = [ vels ];

		serverAction({action:{actions: vact.clone(), els: vels.clone(), onSuccess: addCancelToSuccess, dlg: dlg, onFailure: onFailure, params: extraParams}});
	};
	// privileged functions
	this.ok = function(event, params2)
	{
		params2.dlg.setFlash(pleaseWaitMsg, false);
		// Recursively run through the list of actions we were passed.
		var data = params2.dlg.getAllData();
		extraParams[id] = data[id];
		if (verifyFxn) {
			var errMsg = verifyFxn(extraParams);
			if (errMsg) {
				params2.dlg.setFlash(errMsg, true);
				return;
			}
		}
		if (verifyUrl)
			serverAction({action:{actions: verifyUrl, els: 'gd_bit_bucket', onSuccess: onVerified, dlg: dlg, params: extraParams}});
		else {
			if (!Object.isArray(actions))
				actions = [ actions ];
			if (typeof target_els === 'string')
				target_els = [ target_els ];
			else if (target_els === null || target_els === undefined)
				target_els = [ null ];
			serverAction({action:{actions: actions.clone(), els: target_els.clone(), onSuccess: addCancelToSuccess, dlg: dlg, onFailure: onFailure, params: extraParams}});
		}
	};

	var dlgLayout = {
			page: 'layout',
			rows: [
				[ { text: prompt, klass: 'gd_text_input_dlg_label' }, input ]
			]
		};

	if (params.explanation_text)
	   dlgLayout.rows.push([ {text: params.explanation_text, id: "gd_postExplanation", klass: explanation_klass}]);
	if (!params.noOk) {
		dlgLayout.rows.push([{rowClass: 'gd_last_row'}, {button: okStr, callback: this.ok, isDefault: true}, {button: 'Cancel', callback: GeneralDialog.cancelCallback} ]);
		if (noDefault)
			dlgLayout.rows[1][1].isDefault = null;
	} else {
		dlgLayout.rows.push([{rowClass: 'gd_last_row'}, {button: 'Cancel', callback: GeneralDialog.cancelCallback, isDefault: true} ]);
		if (noDefault)
			dlgLayout.rows[1][0].isDefault = null;
	}
	
	var dlgparams = {this_id: "gd_text_input_dlg", pages: [ dlgLayout ], body_style: body_style, row_style: "gd_message_box_row", title: title, focus: GeneralDialog.makeId(id)};
	dlg = new GeneralDialog(dlgparams);
	//dlg.changePage('layout', dlg.makeId(id));
	dlg.center();
	if (populate)
		populate(dlg);
};

// Parameters:
// id: The name that is passed to the server with the data.
// value: The initial value when the dlg first appears (optional)
// inputKlass: The class for the input element
// autocompleteParams (opt): autocomplete params - url: callback url, token (opt): char used to tokenize input
// + plus all the parameters for singleInputDlg.
//
var TextInputDlg = Class.create({
	initialize: function (params) {
		var id = params.id;
		var value = params.value;
		var klass = params.inputKlass === undefined ? 'gd_text_input_dlg_input' : params.inputKlass;
		var autocompleteParams = params.autocompleteParams;
		
		if ( autocompleteParams )
		{
      var ac_input = {autocomplete: id, klass: klass, url: autocompleteParams.url, token: autocompleteParams.token};
      singleInputDlg(params, ac_input);   
		}
		else
		{
		  var input = {input: id, klass: klass, value: value};
      singleInputDlg(params, input);  
		}
	}
});

// Parameters:
// options: Array of hash values: { text: 'the displayed value', value: 'the value returned to the server' }
// value: The initial value when the dlg first appears (optional)
// explanation: An array of strings that corresponds to the options above. When the user changes the selection, then the value automatically appears.
// populateUrl: If you want to make an Ajax call to fill the select box, pass a url here. The options parameter will generally just contain a placeholder in this case.
// + plus all the parameters for singleInputDlg.
//
var SelectInputDlg = Class.create({
	initialize: function (params) {
		var id = params.id;
		var options = params.options;
		var explanation = params.explanation;
		var value = params.value;
		var populateUrl = params.populateUrl;
		var input = {select: id, klass: 'gd_select_dlg_input', options: options, value: value};

		var populate = function(dlg)
		{
			var onSuccess = function(resp) {
				var vals = [];
				dlg.setFlash('', false);
				try {
					if (resp.responseText.length > 0)
						vals = resp.responseText.evalJSON(true);
				} catch (e) {
					dlg.setFlash(e, true);
					return;
				}
				// We got all options. Now put them on the dialog
				var sel_arr = $$('.gd_select_dlg_input');
				var select = sel_arr[0];
				select.update('');
				vals = vals.sortBy(function(user) { return user.text; });
				vals.each(function(user) {
					select.appendChild(new Element('option', { value: user.value }).update(user.text));
				});
			};
			var onFailure = function(resp) {
				genericAjaxFail(dlg, resp, populateUrl);
			};
			serverAction({ action: { actions: populateUrl, els: 'gd_bit_bucket', onSuccess: onSuccess, onFailure: onFailure, params: params.extraParams } });
		};

		if (explanation) {
			var valToExpl = function(value) {
				for (var i = 0; i < options.length; i++) {
					if (options[i].value === value)
						return explanation[i];
				}
				return explanation[0];
			};

			var select_changed = function(field, new_value) {
				$('gd_postExplanation').update(valToExpl(new_value));
			};

			input.callback = select_changed;
			params.explanation_text = valToExpl(value);
		}
		if (populateUrl)
			params.populate = populate;
		singleInputDlg(params, input);
	}
});

// TODO-PER: This isn't used anywhere
//var TextAreaInputDlg = Class.create({
//	initialize: function (params) {
//		var id = params.id;
//		var options = params.options;
//		var value = params.value;
//		var input = {textarea: id, klass: 'text_area_dlg_input', options: options, value: value};
//		params.noDefault = true;
//		singleInputDlg(params, input);
//	}
//});

// Parameters:
// title: The title of the dialog.
// okCallback: A function that is called after the user presses ok and after the dialog has been dismissed.
// value: The starting value when the dialog is first shown.
// populate_urls: What to call to get the objects for the Link toolbar button.
// progress_img: The progress image to show while populating the Link dialog.
// extraButton: { label: the name of the button, callback: a function that is called when the user pushes the button }.
//
var RteInputDlg = Class.create({
	initialize: function (params) {
		var title = params.title;
		var okCallback = params.okCallback;
		var value = params.value;
		var populate_urls = params.populate_urls;

		var progress_img = params.progress_img;
		var extraButton = params.extraButton;

		// This puts up a modal dialog that asks for a input from an RTE, then calls the okCallback when the user presses ok.
		this.class_type = 'RteInputDlg';	// for debugging

		// private variables
		//var This = this;

		// privileged functions
		this.ok = function(event, params)
		{
			params.dlg.cancel();

			var data = params.dlg.getAllData();
			okCallback(data.gd_textareaValue);
		};

		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { textarea: 'gd_textareaValue', value: value } ],
					[ { rowClass: 'gd_last_row' }, { button: 'Ok', callback: this.ok }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
				]
			};

		if (extraButton !== undefined)
			dlgLayout.rows[1].push({ button: extraButton.label, callback: extraButton.callback });

		var dlgparams = { this_id: "gd_text_input_dlg", pages: [ dlgLayout ], body_style: "gd_message_box_dlg", row_style: "gd_message_box_row", title: title };
		var dlg = new GeneralDialog(dlgparams);
		//dlg.changePage('layout', null);
		dlg.initTextAreas({ toolbarGroups: [ 'fontstyle', 'link' ], linkDlgHandler: new LinkDlgHandler(populate_urls, progress_img) });
		dlg.center();

		var input = $('gd_textareaValue');
		input.select();
		input.focus();
	}
});

function dlgAjax(dlg, actions, els, params) {
	var onSuccess = function(resp) {
		dlg.cancel();
	};
	var onFailure = function(resp) {
		dlg.setFlash(resp.responseText, true);
	};
	serverAction({ action: { actions: actions, els: els, params: params, onSuccess: onSuccess, onFailure: onFailure }});
}

function genericAjaxFail(dlg, resp, action) {
	var text = formatFailureMsg(resp, action);
	if (dlg)
		dlg.setFlash(text, true);
	else
		new MessageBoxDlg("Communication Error", text);
}
