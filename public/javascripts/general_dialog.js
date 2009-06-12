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

/*global Class, $, $$, $H, Element */
/*global YAHOO */
/*global form_authenticity_token */
/*global RichTextEditor */

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
		
		var flash_id = this_id + '_flash';
		var dlg_id = this_id;
		var editors = [];
		var customList = [];
		
		var selectChange = function(event, param)
		{
			var This = $(this);
			var currSelection = This.value;
			var id = param.id;
			var el = $(id);
			el.value = currSelection; 
			
			if (param.callback)
				param.callback(id, currSelection);
		};

		var parent_id = 'modal_dlg_parent';
		var parent = $(parent_id);
		if (parent === null)
			parent = document.getElementsByTagName("body").item(0).appendChild(new Element('div', { id: parent_id, style: 'text-align:left;' }));
			
		this.getAllData = function() {
			var inputs = $$("#" + dlg_id + " input");
			var data = {};
			inputs.each(function(el) {
				if (el.type === 'checkbox') {
					data[el.id] = el.checked;
				} else if (el.type !== 'button') {
					data[el.id] = el.value;
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
				var id = el.id;
				var value = el.value;
				data[id] = value;
			});
			return data;
		};
		
		this.submitForm = function(id, action) {
			var form = $(id);
			form.writeAttribute({ action: action });
			form.submit();
		};

		this.setFlash = function(msg, is_error) {
			$(flash_id).update(msg);
			if (is_error) {
				$(flash_id).addClassName('flash_notice_error');
				$(flash_id).removeClassName('flash_notice_ok');
			} else {
				$(flash_id).addClassName('flash_notice_ok');
				$(flash_id).removeClassName('flash_notice_error');
			}
		};
		
		var handleCancel = function() {
		    this.cancel();
		};
		
		var panel = new YAHOO.widget.Dialog(this_id, {
			constraintoviewport: true,
			modal: true,
			close: (title !== undefined),
			draggable: (title !== undefined),
			underlay: 'shadow',
			buttons: null
		});
		
		if (title !== undefined)
			panel.setHeader(title);

		var klEsc = new YAHOO.util.KeyListener(document, { keys:27 },  							
			{ fn:handleCancel,
				scope:panel,
				correctScope:true }, "keyup" ); // keyup is used here because Safari won't recognize the ESC keydown event, which would normally be used by default
		panel.cfg.queueProperty("keylisteners", klEsc);

		// Create all the html for the dialog
		var listenerArray = [];
		var buttonArray = [];
		var body = new Element('div', { id: body_style });
		body.addClassName(body_style);
		var flash = new Element('div', { id: flash_id }).update(flash_notice);
		flash.addClassName("flash_notice_ok");
		body.appendChild(flash);
		
		pages.each(function(page) {
			var form = new Element('form', { id: page.page });
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
						elText.addClassName(subel.klass);
						if (subel.id !== undefined)
							elText.writeAttribute({ id: subel.id });
						row.appendChild(elText);
						// INPUT
					} else if (subel.input !== undefined) {
						var el1 = new Element('input', { id: subel.input, 'type': 'text' });
						el1.addClassName(subel.klass);
						if (subel.value !== undefined)
							el1.writeAttribute({value: subel.value });
						row.appendChild(el1);
						// PASSWORD
					} else if (subel.password !== undefined) {
						var el2 = new Element('input', { id: subel.password, 'type': 'password'});
						el2.addClassName(subel.klass);
						if (subel.value !== undefined)
							el2.writeAttribute({value: subel.value });
						row.appendChild(el2);
						// BUTTON
					} else if (subel.button !== undefined) {
						var input = new Element('input', { id: 'btn' + buttonArray.length, 'type': 'button', value: subel.button });
						row.appendChild(input);
						buttonArray.push({ id: 'btn' + buttonArray.length, event: 'click', klass: subel.klass, callback: subel.callback, param: { curr_page: page.page, destination: subel.url, dlg: This } });
						// PAGE LINK
					} else if (subel.page_link !== undefined) {
						var a = new Element('a', { id: 'a' + listenerArray.length, onclick: 'return false;', href: '#' }).update(subel.page_link);
						a.addClassName('nav_link');
						if (subel.klass)
							a.addClassName(subel.klass);
						row.appendChild(a);
						listenerArray.push({ id: 'a' + listenerArray.length, event: 'click', callback: subel.callback, param: { curr_page: page.page, destination: subel.new_page, dlg: This } });
						// SELECT
					} else if (subel.select !== undefined) {
						var selectValue = new Element('input', { id: subel.select, name: subel.select });
						if (subel.options) {
							var val = subel.value ? subel.value : subel.options[0].value;
							selectValue.writeAttribute('value', val);
						}
						selectValue.addClassName('hidden');
						row.appendChild(selectValue);
						var select = new Element('select', { id: 'sel' + listenerArray.length });
						if (subel.klass)
							select.addClassName(subel.klass);
						row.appendChild(select);
						listenerArray.push({ id: 'sel' + listenerArray.length, event: 'change', callback: selectChange, param: { id: subel.select, callback: subel.change } });
						if (subel.options) {
							subel.options.each(function(opt) {
								var opt = new Element('option', { value: opt.value}).update(opt.text);
								if (subel.value === opt.value)
									opt.writeAttribute('selected', 'selected');
								select.appendChild(opt);
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
						var checkbox = new Element('input', { id: subel.checkbox, 'type': "checkbox", value: subel.checkbox, name: subel.checkbox });
						if (subel.klass)
							checkbox.addClassName(subel.klass);
						row.appendChild(checkbox);
						// TEXTAREA
					} else if (subel.textarea !== undefined) {
						var wrapper = new Element('div');
						var textarea = new Element('textarea', { id: subel.textarea, name: subel.textarea });
						if (subel.klass) {
							textarea.addClassName(subel.klass);
							wrapper.addClassName(subel.klass);
						}
						if (subel.value !== undefined)
							textarea.update(subel.value);
						wrapper.appendChild(textarea);
						row.appendChild(wrapper);
						// IMAGE
					} else if (subel.image !== undefined) {
						var image = new Element('div', { id: subel.image + '_div' });
						var src = subel.value !== undefined ? subel.value : "";
						image.appendChild(new Element('img', { src: src, id: subel.image + "_img", alt: '' }));
						image.appendChild(new Element('input', { id: subel.image, type: 'file', name: subel.image }));
						if (subel.klass)
							image.addClassName(subel.klass);
						row.appendChild(image);
						row.appendChild(new Element('input', { id: 'authenticity_token', name: 'authenticity_token', type: 'hidden', value: form_authenticity_token }).update(form_authenticity_token));
						
						// We have to go through a bunch of hoops to get the file uploaded, since
						// you can't upload a file through Ajax.
						form.writeAttribute({ enctype: "multipart/form-data", target: "upload_target", method: 'post' });
						body.appendChild(new Element('iframe', { id: "upload_target", name: "upload_target", src: "#", style: "width:0;height:0;border:0px solid #fff;" }));

					}
				});
			});
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
			
			var ybtn = new YAHOO.widget.Button(btn.id, { onclick: { fn: fn, obj: btn.id, scope: this }});
			if (btn.klass)
				YAHOO.util.Event.onContentReady(btn.id, function() {$(btn.id).addClassName(btn.klass); }); 
		});
		// These are all the elements that can be turned on and off in the dialog.
		// All elements have switchable_element, and they each then have another class
		// that matches the value of the view parameter. Then this loop either hides or shows
		// each element.
		this.changePage = function(view, focus_el) {
			var els = $$('.switchable_element');
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
		
		this.initTextAreas =  function(toolbarGroups, linkDlgHandler) {
			var dlg = $(this_id);
			var w = parseInt(dlg.getStyle('width'), 10);
			var inner_el = dlg.down('.bd');
			var padL = parseInt(inner_el.getStyle('padding-left'));
			var padR = parseInt(inner_el.getStyle('padding-right'));
			var width = w - padL - padR;
			
			var textAreas = $$("#" + dlg_id + " textarea");
			textAreas.each( function(textArea) { 
				var editor = new RichTextEditor({ id: textArea.id, toolbarGroups: toolbarGroups, linkDlgHandler: linkDlgHandler, width: width });
				editor.attachToDialog(panel);
				editors.push(editor);
			}, this);
		};
		
	}
});

/////////////////////////////////////////////////////
// Here are some generic uses for the the above dialog
/////////////////////////////////////////////////////

var MessageBoxDlg = Class.create({
	initialize: function (title, message) {
		// This puts up a modal dialog that replaces the alert() call.
		this.class_type = 'MessageBoxDlg';	// for debugging

		// private variables
		var This = this;
		
		// privileged functions
		this.cancel = function(event, params)
		{
			params.dlg.cancel();
		};
		
		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { text: message, klass: 'new_exhibit_label' } ],
					[ { button: 'Cancel', callback: this.cancel } ]
				]
			};
		
		var params = { this_id: "message_box_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: title };
		var dlg = new GeneralDialog(params);
		dlg.changePage('layout', null);
		dlg.center();
	}
});

var ConfirmDlg = Class.create({
	initialize: function (title, message, okStr, cancelStr, action) {
		// This puts up a modal dialog that replaces the confirm() call.
		this.class_type = 'ConfirmDlg';	// for debugging

		// private variables
		var This = this;
		
		// privileged functions
		this.ok = function(event, params)
		{
			params.dlg.cancel();
			action();
		};
		
		this.cancel = function(event, params)
		{
			params.dlg.cancel();
		};
		
		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { text: message, klass: 'new_exhibit_label' } ],
					[ { button: okStr, callback: this.ok }, { button: cancelStr, callback: this.cancel } ]
				]
			};
		
		var params = { this_id: "confirm_box_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: title };
		var dlg = new GeneralDialog(params);
		dlg.changePage('layout', null);
		dlg.center();
	}
});

// el: the element to update
// action: the url to call
// params: the params for the url
// onComplete: what to call after the operation finishes
// onFailure: what to call if the operation fails.
function updateWithAjax(params)
{
	new Ajax.Updater(params.el, params.action, {
		parameters : params.params,
		evalScripts : true,
		onComplete : function(resp) {
			if(params.onComplete)
				params.onComplete(resp);
		},
		onFailure : function(resp) {
			if (params.onFailure)
				params.onFailure();
			else
				new MessageBoxDlg("Error", "Oops, there's been an error.");
		}
	});
}

var ConfirmAjaxDlg = Class.create({
	initialize: function (title, message, params) {
		// This puts up a confirmation dialog before doing an ajax update.
		this.class_type = 'ConfirmAjaxDlg';	// for debugging

		// private variables
		var This = this;
		
		var ok = function()
		{
			updateWithAjax(params);
		};
		
		new ConfirmDlg(title, message, "Yes", "No", ok);
	}
});

var ConfirmLinkDlg =  Class.create({
	initialize: function (el, title, message) {
		// This puts up a confirmation dialog before following a link. It is intended to be used as the onclick handler in a <a> tag.
		// Put the link you want to follow in the href property of the a-tag.
		this.class_type = 'ConfirmLinkDlg';	// for debugging

		// private variables
		var This = this;
		var link = el.href;
		
		var ok = function(event, params)
		{
			window.location = link;
		};
		
		new ConfirmDlg(title, message, "Yes", "No", ok);
	}
});
