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

/*global $H, Class, $, $$, Element, Ajax */
/*global YAHOO */
/*global document, setTimeout, window */
/*global form_authenticity_token */
/*global RichTextEditor, LinkDlgHandler */
/*extern ConfirmAjaxDlg, ConfirmDlg, ConfirmLinkDlg, GeneralDialog, MessageBoxDlg, RteInputDlg, TextInputDlg, recurseUpdateWithAjax, updateWithAjax, postLink */
/*extern showInLightbox, showPartialInLightBox, SelectInputDlg, ShowDivInLightbox, TextAreaInputDlg, singleInputDlg, initializeSelectCtrl, ProgressSpinnerDlg, ajaxWithProgressDlg, ajaxWithProgressSpinner */

var initializeSelectCtrl = function(select_el_id, curr_sel, onchange_callback)
{
	var oMenuButton1 = new YAHOO.widget.Button(select_el_id, {
		type: "menu",
		menu: select_el_id + "select"});

	// Pass this the id of a working select element, with its current selection already set.
//	var sel = $(select_el_id);
//	if (sel) {	// Initializing the select wipes out the original select id, so it if it there, then we haven't initialized.
//	var opt = sel.down('option', sel.selectedIndex);	// Get the currently selected item: that is set in the original HTML as the selection.
//	var start_text = opt.innerHTML;
//		var oMenuButton1 = new YAHOO.widget.Button({
//			id: "menu" + select_el_id,
//			name: "menu" + select_el_id,
//			label: "<span class=\"yui-button-label\">" + start_text + "</span>",
//			type: "menu",
//			menu: select_el_id,
//			container: select_el_id + "_wrapper"
//		});

		//	"selectedMenuItemChange" event handler for a Button that will set
		//	the Button's "label" attribute to the value of the "text"
		//	configuration property of the MenuItem that was clicked.
		var onSelectedMenuItemChange = function (event) {
			var oMenuItem = event.newValue;
			var new_text = oMenuItem.cfg.getProperty("text");
			this.set("label", ("<span class=\"yui-button-label\">" +
				new_text + "</span>"));
			if (curr_sel !== new_text) {
				onchange_callback(oMenuItem.value);
			}
		};

		//	Register a "selectedMenuItemChange" event handler that will sync the
		//	Button's "label" attribute to the MenuItem that was clicked.
		oMenuButton1.on("selectedMenuItemChange", onSelectedMenuItemChange);
//	}
};

var GeneralDialog = Class.create({
	initialize: function (params) {
		this.class_type = 'GeneralDialog';	// for debugging

		// private variables
		var This = this;
		var this_id = params.this_id;
		var pages = params.pages;
		var flash_notice = params.flash_notice;
		if (flash_notice === undefined)
			flash_notice = "";
		var body_style = params.body_style;
		var row_style = params.row_style;
		var title = params.title;
		var override_width = params.width;
		
		var flash_id = this_id + '_flash';
		var dlg_id = this_id;
		var editors = [];
		var customList = [];

		var currPage = null;
		var defaultAction = {};
		var defaultParam = {};
		
		var makeId = function(str) {
			// This checks to see if the id is of the form xxx[yyy]. If so, it replaces the first [ with _ and the second with nothing.
			return str.gsub('[', '_').gsub(']', '');
		};
		this.makeId = function(str) {
			return makeId(str);
		};
		var selectChange = function(event, param)
		{
			var This = $(this);
			var currSelection = This.value;
			var id = makeId(param.id);
			var el = $(id);
			el.value = currSelection; 
			
			if (param.callback)
				param.callback(id, currSelection);
		};

		var parent_id = 'modal_dlg_parent';
		var parent = $(parent_id);
		if (parent === null) {
			var main = document.getElementsByTagName("body").item(0);
			$(main).down('div').insert({before: new Element('div', {id: parent_id, style: 'text-align:left;'})});
		}

		this.getOuterDomElement = function() {
			return $(this_id);
		};

		this.getEditor = function(index) {
			return editors[index];
		};

		this.getAllData = function() {
			var inputs = $$("#" + dlg_id + " input");
			var data = {};
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
				data[cl.field] = cl.value;
			});
	
			var textareas = $$("#" + dlg_id + " textarea");
			textareas.each(function(el) {
				var id = el.name;
				var value = el.value;
				data[id] = value;
			});
			return data;
		};
		
		this.submitForm = function(id, action) {
			var form = $(id);
			form.writeAttribute({action: action, method: 'post'});
			form.appendChild(new Element('input', {id: 'authenticity_token', type: 'hidden', name: 'authenticity_token', value: form_authenticity_token}));
			form.submit();
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
					flash.addClassName('flash_notice_error');
					flash.removeClassName('flash_notice_ok');
				} else {
					flash.addClassName('flash_notice_ok');
					flash.removeClassName('flash_notice_error');
				}
			}
		};

		if (title !== undefined)
			panel.setHeader(title);

		var klEsc = new YAHOO.util.KeyListener(document, {keys:27},  							
			{fn:handleCancel,
				scope:panel,
				correctScope:true}, "keyup" ); // keyup is used here because Safari won't recognize the ESC keydown event, which would normally be used by default

		var klEnter = new YAHOO.util.KeyListener(document, {keys:13},
			{fn:function() {
					if (defaultAction[currPage])
						defaultAction[currPage](null, defaultParam[currPage]);
				},
				scope:panel,
				correctScope:true}, "keydown" );
		panel.cfg.queueProperty("keylisteners", [klEsc, klEnter]);

		// Create all the html for the dialog
		var listenerArray = [];
		var buttonArray = [];
		var body = new Element('div', {id: this_id + '_' + body_style});
		body.addClassName(body_style);
		var flash = new Element('div', {id: flash_id}).update(flash_notice);
		flash.addClassName("flash_notice_ok");
		body.appendChild(flash);

		var addButton = function(parent_el, text, klass, callback, page, url) {
			var input = new Element('input', {id: this_id + '_btn' + buttonArray.length, 'type': 'button', value: text});
			parent_el.appendChild(input);
			var buttonClass = klass;
			buttonArray.push({id: this_id + '_btn' + buttonArray.length, event: 'click', klass: buttonClass, callback: callback, param: {curr_page: page, destination: url, dlg: This}});
		};

		var addIconButton = function(parent_el, text, klass, callback, page, context) {
			var button_id = this_id + '_a' + listenerArray.length;
			var a = new Element('a', {id: button_id, title: text, onclick: 'return false;', href: '#'});
			if (klass)
				a.addClassName(klass);
			parent_el.appendChild(a);
			listenerArray.push({id: button_id, event: 'click', callback: callback, param: {curr_page: page.page, button_id: button_id, context: context, dlg: This}});
			return button_id;
		};

		var addInput = function(parent_el, text, klass, value) {
			var el1 = new Element('input', {id: makeId(text), 'type': 'text', name: text});
			if (klass)
				el1.addClassName(klass);
			if (value !== undefined)
				el1.writeAttribute({value: value});
			parent_el.appendChild(el1);
			return el1;
		};

		var addHidden = function(parent_el, id, klass, value) {
			var el0 = new Element('input', {id: makeId(id), name: id, 'type': 'hidden'});
			if (klass)
				el0.addClassName(klass);
			if (value !== undefined && value !== null)
				el0.writeAttribute({value: value});
			parent_el.appendChild(el0);
		};

		var addLink = function(parent_el, id, klass, text, callback, callback_params) {
			var a = new Element('a', {id: id + '_a' + listenerArray.length, onclick: 'return false;', href: '#'}).update(text);
			a.addClassName('nav_link');
			if (klass)
				a.addClassName(klass);
			parent_el.appendChild(a);
			listenerArray.push({id: id + '_a' + listenerArray.length, event: 'click', callback: callback, param: callback_params});
		};

		var styleButtonPushed = function(ev, params) {
			 var el = $(params.button_id);
			 var context = params.context;
			 var style = context.style;
			 var styleHash = {};
			 var hidden = $(context.dest + '_' + context.value);
			 if (el.hasClassName('pressed')) {
				 el.removeClassName('pressed');
				 styleHash[style] = '';
				 $(context.dest).setStyle(styleHash);
				 hidden.value = 0;
			 }
			 else {
				 el.addClassName('pressed');
				 styleHash[style] = context.value;
				 $(context.dest).setStyle(styleHash);
				 hidden.value = 1;
			 }
		};

		var filterEvent = function(ev, params) {
			var filterString = this.value.toLowerCase();
			if (ev.type === 'blur' && filterString === '') {
				$(this).addClassName('inputHintStyle');
				this.value = params.prompt;
			} else if (ev.type === 'focus'  && filterString === params.prompt) {
				this.value = '';
				$(this).removeClassName('inputHintStyle');
			} else if (ev.type === 'keyup') {
				params.callback(this.value);
			}
		};

		pages.each(function(page) {
			var form = new Element('form', {id: page.page});
			form.addClassName(page.page);	// IE doesn't seem to like the 'class' attribute in the Element, so we set the classes separately.
			form.addClassName("switchable_element");
			form.addClassName("hidden");
			body.appendChild(form);
			page.rows.each(function (el){
				var row = new Element('div');
				row.addClassName(row_style);
				form.appendChild(row);
				el.each(function (subel) {
					// TEXT
					if (subel.text !== undefined) {
						var elText = new Element('span').update(subel.text);
						if (subel.klass)
							elText.addClassName(subel.klass);
						if (subel.id !== undefined)
							elText.writeAttribute({id: makeId(subel.id)});
						row.appendChild(elText);
						// PICTURE
					} else if (subel.picture !== undefined) {
						var elPic = new Element('img', {src: subel.picture, alt: subel.picture});
						if (subel.klass)
							elPic.addClassName(subel.klass);
						if (subel.id !== undefined)
							elPic.writeAttribute({id: makeId(subel.id)});
						row.appendChild(elPic);
						// INPUT
					} else if (subel.input !== undefined) {
						addInput(row, subel.input, subel.klass, subel.value);
						// INPUT FILTER
					} else if (subel.inputFilter !== undefined) {
						var klass3 = 'inputHintStyle';
						if (subel.klass !== undefined)
							klass3 += " " + subel.klass;
						var el3 = addInput(row, subel.inputFilter, klass3, subel.value);
						el3.value = subel.prompt;
						listenerArray.push({id: subel.inputFilter, event: 'keyup', callback: filterEvent, param: {prompt: subel.prompt, callback: subel.callback}});
						listenerArray.push({id: subel.inputFilter, event: 'blur', callback: filterEvent, param: {prompt: subel.prompt, callback: subel.callback}});
						listenerArray.push({id: subel.inputFilter, event: 'focus', callback: filterEvent, param: {prompt: subel.prompt, callback: subel.callback}});
						// INPUT WITH STYLE
					} else if (subel.inputWithStyle !== undefined) {
						var el1 = addInput(row, subel.inputWithStyle, subel.klass, subel.value.text);
						addIconButton(row, 'Bold', 'bold_button' + (subel.value.isBold ? " pressed" : ""), styleButtonPushed, page, {dest: subel.inputWithStyle, style: 'fontWeight', value: 'bold'});
						addHidden(row, subel.inputWithStyle + '_bold', '', subel.value.isBold ? '1' : '0');
						addIconButton(row, 'Italic', 'italic_button' + (subel.value.isItalic ? " pressed" : ""), styleButtonPushed, page, {dest: subel.inputWithStyle, style: 'fontStyle', value: 'italic'});
						addHidden(row, subel.inputWithStyle + '_italic', '', subel.value.isItalic ? '1' : '0');
						addIconButton(row, 'Underline', 'underline_button' + (subel.value.isUnderline ? " pressed" : ""), styleButtonPushed, page, {dest: subel.inputWithStyle, style: 'textDecoration', value: 'underline'});
						addHidden(row, subel.inputWithStyle + '_underline', '', subel.value.isUnderline ? '1' : '0');
						if (subel.value.isBold)
							el1.setStyle({fontWeight: 'bold'});
						if (subel.value.isItalic)
							el1.setStyle({fontStyle: 'italic'});
						if (subel.value.isUnderline)
							el1.setStyle({textDecoration: 'underline'});
//{ input: 'caption1', value: values.caption1, klass: 'header_input' },
//						{ icon_button: 'Bold', klass: 'bold_button', callback: buttonPushed, context: { dest: 'caption1', style: 'fontWeight', value: 'bold' } }, { hidden: 'caption1_bold', value: values.caption1_bold },
//						{ icon_button: 'Italic', klass: 'italic_button', callback: buttonPushed, context: { dest: 'caption1', style: 'fontStyle', value: 'italic' } }, { hidden: 'caption1_italic', value: values.caption1_italic },
//						{ icon_button: 'Underline', klass: 'underline_button', callback: buttonPushed, context: { dest: 'caption1', style: 'textDecoration', value: 'underline' } }, { hidden: 'caption1_underline', value: values.caption1_underline },
						// HIDDEN
					} else if (subel.hidden !== undefined) {
						addHidden(row, subel.hidden, subel.klass, subel.value);
//						var el0 = new Element('input', { id: makeId(subel.hidden), name: subel.hidden, 'type': 'hidden' });
//						if (subel.klass)
//							el0.addClassName(subel.klass);
//						if (subel.value !== undefined && subel.value !== null)
//							el0.writeAttribute({value: subel.value });
//						row.appendChild(el0);
						// PASSWORD
					} else if (subel.password !== undefined) {
						var el2 = new Element('input', {id: makeId(subel.password), name: subel.password, 'type': 'password'});
						if (subel.klass)
							el2.addClassName(subel.klass);
						if (subel.value !== undefined && subel.value !== null)
							el2.writeAttribute({value: subel.value});
						row.appendChild(el2);
						// BUTTON
					} else if (subel.button !== undefined) {
//						var input = new Element('input', { id: this_id + '_btn' + buttonArray.length, 'type': 'button', value: subel.button });
//						row.appendChild(input);
						var buttonClass = subel.klass;
						if (subel.isDefault) {
							defaultAction[page.page] = subel.callback;
							defaultParam[page.page] = {curr_page: page.page, destination: subel.url, dlg: This};
							buttonClass = (buttonClass === undefined) ? "default" : buttonClass + " default" ;
						}
						addButton(row, subel.button, buttonClass, subel.callback, page.page, subel.url);
//						buttonArray.push({ id: this_id + '_btn' + buttonArray.length, event: 'click', klass: buttonClass, callback: subel.callback, param: { curr_page: page.page, destination: subel.url, dlg: This } });
						// ICON BUTTON
					} else if (subel.icon_button !== undefined) {
						addIconButton(row, subel.icon_button, subel.klass, subel.callback, page, subel.context);
//						var button_id = this_id + '_a' + listenerArray.length;
//						var a = new Element('a', { id: button_id, title: subel.icon_button, onclick: 'return false;', href: '#' });
//						if (subel.klass)
//							a.addClassName(subel.klass);
//						row.appendChild(a);
//						listenerArray.push({ id: button_id, event: 'click', callback: subel.callback, param: { curr_page: page.page, button_id: button_id, context: subel.context, dlg: This } });
						// PAGE LINK
					} else if (subel.page_link !== undefined) {
						addLink(row, this_id, subel.klass, subel.page_link,  subel.callback, {curr_page: page.page, destination: subel.new_page, dlg: This});

//						var a = new Element('a', { id: this_id + '_a' + listenerArray.length, onclick: 'return false;', href: '#' }).update(subel.page_link);
//						a.addClassName('nav_link');
//						if (subel.klass)
//							a.addClassName(subel.klass);
//						row.appendChild(a);
//						listenerArray.push({ id: this_id + '_a' + listenerArray.length, event: 'click', callback: subel.callback, param: { curr_page: page.page, destination: subel.new_page, dlg: This } });
						// SELECT
					} else if (subel.select !== undefined) {
						var selectValue = new Element('input', {id: makeId(subel.select), name: subel.select});
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
						listenerArray.push({id: this_id + '_sel' + listenerArray.length, event: 'change', callback: selectChange, param: {id: subel.select, callback: subel.change}});
						if (subel.options) {
							subel.options.each(function(opt) {
								var opt2 = new Element('option', {value: opt.value}).update(opt.text);
								if (subel.value === opt.value)
									opt2.writeAttribute('selected', 'selected');
								select.appendChild(opt2);
							});
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
						var checkbox = new Element('input', {id: makeId(subel.checkbox), 'type': "checkbox", value: '1', name: subel.checkbox});
						if (subel.klass)
							checkbox.addClassName(subel.klass);
						if (subel.value === '1')
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
									var cbox = new Element('input', {id: makeId(cbId), 'type': "checkbox", value: '1', name: cbId});
									if (subel.klass)
										cbox.addClassName(subel.klass);
									if (subel.selections.detect(fnDetect))
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
						var radioList = subel.buttons;
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
							var radioRow = new Element('tr');
							radioBody.appendChild(radioRow);
							var radioCol = new Element('td');
							radioRow.appendChild(radioCol);
							var elRadio = new Element('input', {id: makeId(radioId+'_'+radio.value), type: 'radio', value: radio.value, name: radioId});
							if (radioValue === radio.value)
								elRadio.writeAttribute('checked', 'true');
							radioCol.appendChild(elRadio);
							radioCol = new Element('td');
							radioRow.appendChild(radioCol);
							radioCol.appendChild(new Element('span').update(' ' + radio.text + '<br />'));
						});
						// TEXTAREA
					} else if (subel.textarea !== undefined) {
						var wrapper = new Element('div');
						var textarea = new Element('textarea', {id: makeId(subel.textarea), name: subel.textarea});
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
						var year = new Element('select', {id: makeId(subel.date.gsub('*', '1i')), name: subel.date.gsub('*', '(1i)')});
						for (var y = 2005; y < 2015; y++) {
							if (start_date[0] === '' + y)
								year.appendChild(new Element('option', {value: "" + y, selected: 'selected'}).update("" + y));
							else
								year.appendChild(new Element('option', {value: "" + y}).update("" + y));
						}
						var month = new Element('select', {id: makeId(subel.date.gsub('*', '2i')), name: subel.date.gsub('*', '(2i)')});
						var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
						var monthNums = [ '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'];
						for (var m = 0; m < months.length; m++) {
							if (start_date[1] === monthNums[m])
								month.appendChild(new Element('option', {value: m+1, selected: 'selected'}).update(months[m]));
							else
								month.appendChild(new Element('option', {value: m+1}).update(months[m]));
						}
						var day = new Element('select', {id: makeId(subel.date.gsub('*', '3i')), name: subel.date.gsub('*', '(3i)')});
						for (var d = 1; d <= 31; d++) {
							if (start_date[2] === (d<10?'0':'') + d)
								day.appendChild(new Element('option', {value: "" + d, selected: 'selected'}).update("" + d));
							else
								day.appendChild(new Element('option', {value: "" + d}).update("" + d));
						}
						row.appendChild(year);
						row.appendChild(month);
						row.appendChild(day);
						// IMAGE
					} else if (subel.image !== undefined) {
						var image = new Element('div', {id: makeId(subel.image) + '_div'});
						var src = (subel.value !== undefined  && subel.value !== null) ? subel.value : "";
						if (src.length > 0) {
							image.appendChild(new Element('img', {src: src, id: makeId(subel.image) + "_img", alt: ''}));
						}
//						if (subel.allowRemove === true) {
//							var removeCallback = function() {
//								// Need to delay hiding this because the Remove button itself will be hidden and that confuses the browser.
//								var hide_image = function() {
//									$('image_div').up().addClassName('hidden');
//								};
//								hide_image.delay(0.5);
//								$('removeImage').value = true;
//							};
//							addButton(image, "Remove", "image_remove", removeCallback, "", "");
//							addInput(image, 'removeImage', 'hidden', 'false');
//						}
						var createFileInput = function() {
							var file_input = new Element('input', {id: makeId(subel.image), type: 'file', name: subel.image});
							if (subel.size)
								file_input.writeAttribute({size: subel.size});
							return file_input;
						};
						var file_input = createFileInput();
						image.appendChild(file_input);
						if (subel.klass)
							image.addClassName(subel.klass);
						row.appendChild(image);
						var inputEl = new Element('input', {id: 'authenticity_token', name: 'authenticity_token', type: 'hidden', value: form_authenticity_token});
						row.appendChild(inputEl);
						if (subel.removeButton !== undefined) {
							var remove = function() {
								var el = $(makeId(subel.image));
								el.remove();
								var file_input = createFileInput();
								image.appendChild(file_input);
							};
							addLink(row, this_id, subel.klass, subel.removeButton,  remove, { });
						}
						
						// We have to go through a bunch of hoops to get the file uploaded, since
						// you can't upload a file through Ajax.
						form.writeAttribute({enctype: "multipart/form-data", target: "upload_target", method: 'post'});
						body.appendChild(new Element('iframe', {id: "upload_target", name: "upload_target", src: "#", style: "width:0;height:0;border:0px solid #fff;"}));
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
			setTimeout(function() {panel.destroy();}, 500);
		});
		
		listenerArray.each(function (listen) {
			YAHOO.util.Event.addListener(listen.id, listen.event, listen.callback, listen.param); 
		});
		
		buttonArray.each(function(btn){
			var fn = function(event, id) {
				var cb = btn.callback.bind($(id));
				cb(event, btn.param);
			};
			
			new YAHOO.widget.Button(btn.id, {onclick: {fn: fn, obj: btn.id, scope: this}});
			if (btn.klass)
				YAHOO.util.Event.onContentReady(btn.id, function() {$(btn.id).addClassName(btn.klass);}); 
		});

		customList.each(function(ctrl) {
			if (ctrl.delayedSetup)
				ctrl.delayedSetup();
		});

		// These are all the elements that can be turned on and off in the dialog.
		// All elements have switchable_element, and they each then have another class
		// that matches the value of the view parameter. Then this loop either hides or shows
		// each element.
		this.changePage = function(view, focus_el) {
			currPage = view;
			var els = $(this_id).select('.switchable_element');
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
			el.setStyle({left: x + 'px', top: y + 'px'});
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
			
			var textAreas = $$("#" + dlg_id + " textarea");
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

GeneralDialog.openInNewWindow = function(event, params) {
	window.open(params.destination, '_blank');
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
					[ {text: message, klass: 'message_box_label'} ],
					[ {rowClass: 'last_row'}, {button: 'Close', callback: GeneralDialog.cancelCallback, isDefault: true} ]
				]
			};
		
		var params = {this_id: "message_box_dlg", pages: [ dlgLayout ], body_style: "message_box_dlg", row_style: "message_box_row", title: title};
		var dlg = new GeneralDialog(params);
		dlg.changePage('layout', null);
		dlg.center();

		this.cancel = function() {dlg.cancel();};
	}
});

var ProgressSpinnerDlg = Class.create({
	initialize: function (message) {
		// This puts up a large spinner that can only be canceled through the ajax return status

		var dlgLayout = {
				page: 'layout',
				rows: [
					[ {text: ' ', klass: 'transparent_progress_spinner'} ],
					[ {rowClass: 'progress_label_row'}, {text: message, klass: 'transparent_progress_label'} ]
				]
			};

		var params = {this_id: "progress_spinner_dlg", pages: [ dlgLayout ], body_style: "progress_spinner_div", row_style: "progress_spinner_row"};
		var dlg = new GeneralDialog(params);
		dlg.changePage('layout', null);
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
					[ {custom: new Div(), klass: params.klass} ],
					[ {rowClass: 'last_row'}, {button: 'Close', callback: GeneralDialog.cancelCallback, isDefault: true} ]
				]
			};

		var dlgParams = {this_id: "lightbox_dlg", pages: [ dlgLayout ], body_style: "lightbox_dlg", row_style: "lightbox_row", title: params.title};
		var dlg = new GeneralDialog(dlgParams);
		dlg.changePage('layout', null);
		dlg.center();
		this.dlg = dlg;
	}
});

function showPartialInLightBox(ajax_url, title, progress_img)
{
	var divName = "lightbox";
	var div = new Element('div', { id: 'lightbox_contents' });
	div.setStyle({display: 'none' });
	var form = div.wrap('form', { id: divName + "_id"});
	var progress = new Element('center', { id: 'lightbox_img_spinner'});
	progress.addClassName('lightbox_img_spinner');
	progress.appendChild(new Element('div').update("Loading..."));
	progress.appendChild(new Element('img', { src: progress_img, alt: ''}));
	progress.appendChild(new Element('div').update("Please wait"));
	form.appendChild(progress);
	var lightbox = new ShowDivInLightbox({ title: title, div: form });
	new Ajax.Updater('lightbox_contents', ajax_url, {
		evalScripts : true,
		onComplete : function(resp) {
			var img_spinner = $('lightbox_img_spinner');
			if (img_spinner)
				img_spinner.remove();
			$('lightbox_contents').show();
			lightbox.dlg.center();
		},
		onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
	});
}

function showInLightbox(title, imageUrl, progress_img)
{
	var loaded = function() {
		var img_spinner = $('lightbox_img_spinner');
		if (img_spinner)
			img_spinner.remove();
		$('lightbox_img').show();
		lightbox.dlg.center();
	};

	var divName = "lightbox";
	var img = new Element('img', { id: 'lightbox_img', src: imageUrl, alt: ""});
	img.setStyle({display: 'none' });
	var form = img.wrap('form', { id: divName + "_id"});
	var progress = new Element('center', { id: 'lightbox_img_spinner'});
	progress.addClassName('lightbox_img_spinner');
	progress.appendChild(new Element('div').update("Image Loading..."));
	progress.appendChild(new Element('img', { src: progress_img, alt: ''}));
	progress.appendChild(new Element('div').update("Please wait"));
	form.appendChild(progress);
	var lightbox = new ShowDivInLightbox({ title: title, div: form });
	img.observe('load', loaded);
}

var ConfirmDlg = Class.create({
	initialize: function (title, message, okStr, cancelStr, action) {
		// This puts up a modal dialog that replaces the confirm() call.
		this.class_type = 'ConfirmDlg';	// for debugging

		// private variables
		//var This = this;
		
		// privileged functions
		this.ok = function(event, params)
		{
			params.dlg.cancel();
			action();
		};
		
		var dlgLayout = {
				page: 'layout',
				rows: [
					[ {text: message, klass: 'message_box_label'} ],
					[ {rowClass: 'last_row'}, {button: okStr, callback: this.ok, isDefault: true}, {button: cancelStr, callback: GeneralDialog.cancelCallback} ]
				]
			};
		
		var params = {this_id: "confirm_box_dlg", pages: [ dlgLayout ], body_style: "message_box_dlg", row_style: "message_box_row", title: title};
		var dlg = new GeneralDialog(params);
		dlg.changePage('layout', null);
		dlg.center();
	}
});

// el: the element to update
// action: the url to call
// params: the params for the url
// onSuccess: what to call after the operation successfully finishes
// onFailure: what to call if the operation fails.
function updateWithAjax(params)
{
	if (params.el === null)	// we want to redraw the entire screen
	{
		// Instead of replacing an element, we want to redraw the entire page. There seems to be some conflict
		// if the form is resubmitted, so duplicate the form.
		var new_form = new Element('form', {id: "temp_form", method: 'post', onsubmit: "this.submit();", action: params.action});
		new_form.observe('submit', "this.submit();");
		document.body.appendChild(new_form);
		$H(params.params).each(function (p) {new_form.appendChild(new Element('input', {name: p.key, value: p.value, id: p.key}));});

		//$(this.targetElement).appendChild(new Element('img', { src: "/images/ajax_loader.gif", alt: ''}));
		new_form.submit();

		return;
	}

	new Ajax.Updater({success: params.el, failure:'bit_bucket'}, params.action, {
		parameters : params.params,
		evalScripts : true,
		onSuccess : function(resp) {
			if(params.onSuccess)
				params.onSuccess(resp);
		},
		onFailure : function(resp) {
			if (params.onFailure)
				params.onFailure(resp);
			else
				new MessageBoxDlg("Ajax Error", resp.responseText);
		}
	});
}

// Parameters:
//	actions: An array of the URLs that will AJAXed, or a string containing a URL to be AJAXed, or a comma separated string of the URLs to be AJAXed.
//	els: An array of divs to update
//	onSuccess: A function to call if the ajax succeeds (optional)
//	onFailure: A function to call if the ajax fails (optional)
//	params: The hash that is sent back with the ajax call
//
function recurseUpdateWithAjax(actions, els, onSuccess, onFailure, params)
{
	if (typeof actions === 'string') {
		actions = actions.split(',');
	}
	if (typeof els === 'string') {
		els = els.split(',');
	}

	if (actions.length === 0) {
		if (onSuccess)
			onSuccess(params);
		return;
	}

	var action = actions.shift();
	var el = els.shift();
	var ajaxparams = {action: action, el: el, onSuccess: function(resp) {recurseUpdateWithAjax(actions, els, onSuccess, onFailure, params);}, onFailure: onFailure, params: params};
	updateWithAjax(ajaxparams);
}

var ajaxWithProgressDlg = function(actions, els, params, ajaxParams)
{
	var title = params.title;
	var waitMessage = params.waitMessage;
	var completeMessage = params.completeMessage;
	var dlg = null;

	var onSuccess = function(resp) {
		if (completeMessage === undefined)
			dlg.cancel();
		else {
			var el = $$(".message_box_label");
			if (el.length > 0)
				el[0].update(completeMessage);
		}
	};
	dlg = new MessageBoxDlg(title, waitMessage);
	recurseUpdateWithAjax(actions, els, onSuccess, null, ajaxParams);
};

var ajaxWithProgressSpinner = function(actions, els, params, ajaxParams)
{
	var waitMessage = params.waitMessage;
	var completeMessage = params.completeMessage;
	var dlg = null;

	var onSuccess = function(resp) {
		if (completeMessage === undefined)
			dlg.cancel();
		else {
			var el = $$(".message_box_label");
			if (el.length > 0)
				el[0].update(completeMessage);
		}
	};
	dlg = new ProgressSpinnerDlg(waitMessage);
	recurseUpdateWithAjax(actions, els, onSuccess, null, ajaxParams);
};

var ConfirmAjaxDlg = Class.create({
	initialize: function (title, message, params) {
		// This puts up a confirmation dialog before doing an ajax update.
		this.class_type = 'ConfirmAjaxDlg';	// for debugging

		// private variables
		//var This = this;
		
		var ok = function()
		{
			if (params.action !== undefined)
				updateWithAjax(params);
			else
				recurseUpdateWithAjax(params.actions, params.els, null, null, params.params);
		};
		
		new ConfirmDlg(title, message, "Yes", "No", ok);
	}
});

var postLink = function(link) {
	var f = document.createElement('form');
	f.style.display = 'none';
	document.body.appendChild(f);
	f.method = 'POST';
	f.action = link;
	var m = document.createElement('input');
	m.setAttribute('type', 'hidden');
	m.setAttribute('name', '_method');
	m.setAttribute('value', 'post');
	f.appendChild(m);
	f.submit();
};

var ConfirmLinkDlg =  Class.create({
	initialize: function (el, title, message) {
		// This puts up a confirmation dialog before following a link. It is intended to be used as the onclick handler in a <a> tag.
		// Put the link you want to follow in the href property of the a-tag.
		this.class_type = 'ConfirmLinkDlg';	// for debugging

		// private variables
		//var This = this;
		var link = el.href;
		
		var ok = function(event, params)
		{
			//window.location = link;
			// Post the link by creating a fake form.
			var f = document.createElement('form');
			f.style.display = 'none';
			$(el).parentNode.appendChild(f);
			f.method = 'POST';
			f.action = link;
			var m = document.createElement('input');
			m.setAttribute('type', 'hidden');
			m.setAttribute('name', '_method');
			m.setAttribute('value', 'post');
			f.appendChild(m);
			f.submit();
		};
		
		new ConfirmDlg(title, message, "Yes", "No", ok);
	}
});

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
//	body_style: The css style of the dialog. (default: message_box_dlg)
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
	var body_style = params.body_style === undefined ? "message_box_dlg": params.body_style;
	var populate = params.populate;

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
		recurseUpdateWithAjax(actions.clone(), target_els.clone(), addCancelToSuccess, onFailure, extraParams);
	};
	var onNotVerified = function(resp) {
		dlg.setFlash(resp.responseText, true);
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
			recurseUpdateWithAjax([ verifyUrl ], [ 'bit_bucket' ], onVerified, onNotVerified, extraParams);
		else {
			if (typeof actions === 'string')
				actions = [ actions ];
			if (typeof target_els === 'string')
				target_els = [ target_els ];
			else if (target_els === null || target_els === undefined)
				target_els = [ null ];
			recurseUpdateWithAjax(actions.clone(), target_els.clone(), addCancelToSuccess, onFailure, extraParams);
		}
	};

	var dlgLayout = {
			page: 'layout',
			rows: [
				[ {text: prompt, klass: 'text_input_dlg_label'}, input ]
			]
		};

	if (params.explanation_text)
		dlgLayout.rows.push([ {text: params.explanation_text, id: "postExplanation"}]);
	if (!params.noOk) {
		dlgLayout.rows.push([{rowClass: 'last_row'}, {button: okStr, callback: this.ok, isDefault: true}, {button: 'Cancel', callback: GeneralDialog.cancelCallback} ]);
		if (noDefault)
			dlgLayout.rows[1][1].isDefault = null;
	}
	
	var dlgparams = {this_id: "text_input_dlg", pages: [ dlgLayout ], body_style: body_style, row_style: "message_box_row", title: title};
	dlg = new GeneralDialog(dlgparams);
	dlg.changePage('layout', dlg.makeId(id));
	dlg.center();
	if (populate)
		populate(dlg);
};

// Parameters:
// value: The initial value when the dlg first appears (optional)
// inputKlass: The class for the input element
// + plus all the parameters for singleInputDlg.
//
var TextInputDlg = Class.create({
	initialize: function (params) {
		var id = params.id;
		var value = params.value;
		var klass = params.inputKlass === undefined ? 'text_input_dlg_input' : params.inputKlass;
		var input = {input: id, klass: klass, value: value};
		singleInputDlg(params, input);
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
		var input = {select: id, klass: 'select_dlg_input', options: options, value: value};

		var populate = function(dlg)
		{
			new Ajax.Request(populateUrl, { method: 'get', parameters: { },
				onSuccess : function(resp) {
					var vals = [];
					dlg.setFlash('', false);
					try {
						if (resp.responseText.length > 0)
							vals = resp.responseText.evalJSON(true);
					} catch (e) {
						new MessageBoxDlg("Error", e);
					}
					// We got all the users. Now put it on the dialog
					var sel_arr = $$('.select_dlg_input');
					var select = sel_arr[0];
					select.update('');
					vals = vals.sortBy(function(user) { return user.text; });
					vals.each(function(user) {
						select.appendChild(new Element('option', { value: user.value }).update(user.text));
					});
				},
				onFailure : function(resp) {
					dlg.setFlash(resp.responseText, true);
				}
			});
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
				$('postExplanation').update(valToExpl(new_value));
			};

			input.change = select_changed;
			params.explanation_text = valToExpl(value);
		}
		if (populateUrl)
			params.populate = populate;
		singleInputDlg(params, input);
	}
});

var TextAreaInputDlg = Class.create({
	initialize: function (params) {
		var id = params.id;
		var options = params.options;
		var value = params.value;
		var input = {textarea: id, klass: 'text_area_dlg_input', options: options, value: value};
		params.noDefault = true;
		singleInputDlg(params, input);
	}
});

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
			okCallback(data.textareaValue);
		};

		var dlgLayout = {
				page: 'layout',
				rows: [
					[ {textarea: 'textareaValue', value: value} ],
					[ {rowClass: 'last_row'}, {button: 'Ok', callback: this.ok, isDefault: true}, {button: 'Cancel', callback: GeneralDialog.cancelCallback} ]
				]
			};

		if (extraButton !== undefined)
			dlgLayout.rows[1].push({button: extraButton.label, callback: extraButton.callback});

		var dlgparams = {this_id: "text_input_dlg", pages: [ dlgLayout ], body_style: "message_box_dlg", row_style: "message_box_row", title: title};
		var dlg = new GeneralDialog(dlgparams);
		dlg.changePage('layout', null);
		dlg.initTextAreas({toolbarGroups: [ 'fontstyle', 'link' ], linkDlgHandler: new LinkDlgHandler(populate_urls, progress_img)});
		dlg.center();

		var input = $('textareaValue');
		input.select();
		input.focus();
	}
});
