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

var GeneralDialog = Class.create({
	initialize: function (params) {
		this.class_type = 'GeneralDialog';	// for debugging

		// private variables
		var This = this;
		var parent_id = params.parent_id;
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
		
		this.getAllData = function() {
			var inputs = $$("#" + dlg_id + " input");
			var data = {};
			inputs.each(function(el) {
				if (el.type !== 'button') {
					var id = el.id;
					var value = el.value;
					data[id] = value;
				}
			});
			return data;
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
		var body = new Element('div', { id: body_style });
		body.addClassName(body_style);
		var flash = new Element('div', { id: flash_id }).update(flash_notice);
		flash.addClassName("flash_notice_ok");
		body.appendChild(flash);
		
		pages.each(function(page) {
			var form = new Element('form');
			form.addClassName(page.page);	// IE doesn't seem to like the 'class' attribute in the Element, so we set the classes separately.
			form.addClassName("switchable_element");
			form.addClassName("hidden");
			body.appendChild(form);
			page.rows.each(function (el){
				var row = new Element('div');
				row.addClassName(row_style);
				form.appendChild(row);
				el.each(function (subel) {
					if (subel.text !== undefined) {
						var elText = new Element('span').update(subel.text);
						elText.addClassName(subel.klass);
						if (subel.id !== undefined)
							elText.writeAttribute({ id: subel.id });
						row.appendChild(elText);
					} else if (subel.input !== undefined) {
						var el1 = new Element('input', { id: subel.input, 'type': 'text' });
						el1.addClassName(subel.klass);
						if (subel.value !== undefined)
							el1.writeAttribute({value: subel.value });
						row.appendChild(el1);
					} else if (subel.password !== undefined) {
						var el2 = new Element('input', { id: subel.password, 'type': 'password'});
						el2.addClassName(subel.klass);
						if (subel.value !== undefined)
							el2.writeAttribute({value: subel.value });
						row.appendChild(el2);
					} else if (subel.button !== undefined) {
						var input = new Element('input', { id: 'btn' + listenerArray.length, 'type': 'button', value: subel.button });
						row.appendChild(input);
						listenerArray.push({ id: 'btn' + listenerArray.length, callback: subel.callback, param: { curr_page: page.page, destination: subel.url, dlg: This } });
					} else if (subel.page_link !== undefined) {
						var a = new Element('a', { id: 'a' + listenerArray.length, href: '#' }).update(subel.page_link);
						a.addClassName('nav_link');
						row.appendChild(a);
						listenerArray.push({ id: 'a' + listenerArray.length, callback: subel.callback, param: { curr_page: page.page, destination: subel.new_page, dlg: This } });
					}
				});
			});
		});

		panel.setBody(body);
		panel.render(parent_id);
		
		listenerArray.each(function (listen, i) {
			YAHOO.util.Event.addListener(listen.id, "click", listen.callback, listen.param); 
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
	}
});
