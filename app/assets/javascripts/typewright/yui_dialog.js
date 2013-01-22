/*global YUI */
/*extern dialogMaker */
/*global document */

//
// This module creates a consistent dialog look by passing a json object describing the dialog.
// Call it like this:
// dialogMaker.dialog({ config: obj, header: obj, body: obj, footer: obj });
//
// config:
//		id: unique id for this dialog
//		klass: string
//		action: string
//		div: string - id of place to write the results.
//		align: selector for an existing div
//		lineClass: class that all the line elements get
//		onsubmit: a function to call when the submit button is pressed
//
// header:
//		title: string
//
// body:
//		layout: array of line
//
// footer:
//		buttons: array of [ 'label', action, def ]
//		def: true if this control should be triggered with the enter key
//
// line: array of element
//
// element:
//		type: [label|select|input|hidden]
//		klass: string
//		focus: true if this control should start with the focus
//		if label
//			text: string
//		if input
//			name: string (can be in the format: a[b])
//			value: string (initial value)
//		if select
//			name: string (can be in the format: a[b])
//			value: string (initial value)
//			options: array of either strings, or [value, string]s
//
var dialogMaker = {};

YUI().use("overlay", 'node', 'io-base', 'querystring-stringify-simple', 'event-delegate', 'event-key', function(Y) {
	function ajaxCall(dlg, action, div, data) {
		var onSuccess = function(ioId, o){
			dlg.cancel();
			if(o.responseText !== undefined){
				Y.one('#'+div).set("innerHTML", o.responseText);
		    }
		};
		var onFailure = function(ioId, o){
			if (o.status === 500)
				dlg.setFlash("Internal Error: please contact site administrator", true);
			else
				dlg.setFlash(o.responseText, true);
		};
		Y.io(action, { method: 'POST', data: data, on: { success: onSuccess, failure: onFailure }});
	}

	function newEl(type, attributes) {
		var el = document.createElement(type);
		if (attributes) {
			for (var i = 0; i < attributes.length; i++)
				if (attributes[i][1])
					Y.one(el).setAttribute(attributes[i][0], attributes[i][1]);
		}
		return el;
	}
	function makeId(name) {
		if (name === undefined)
			return undefined;
		return name.replace(/\[/g, '_').replace(/\]/g, '');
	}
	var createAuthenticityInput = function(form) {
		var csrf_param = Y.one('meta[name=csrf-param]')._node.content;
		var csrf_token = Y.one('meta[name=csrf-token]')._node.content;
		form.appendChild(newEl('input', [[ 'id', csrf_param], ['type', 'hidden'], [ 'name', csrf_param], ['value', csrf_token ]]));
	};
	dialogMaker.dialog = function(params) {
		var This = this;
		dialogMaker.handleFormSubmit =  function() {
			try {
				dialogMaker.defaultAction(This);
			} catch (e) {}
			return false;
		};
		var form = newEl('form', [['id', params.config.id], ['action', params.config.action], ['method', 'POST'], ['onsubmit', "return dialogMaker.handleFormSubmit();"]]);
		createAuthenticityInput(form);
		var header = newEl('div');
		header.innerHTML = params.header.title;
		var flash = newEl('div', [[ 'name', 'dlgFlash'], [ 'id', 'dlgFlash' ]]);
		flash.className = 'hidden';
		form.appendChild(flash);
		var focusedEl = null;

		for (var i = 0; i < params.body.layout.length; i++) {
			var line = newEl('div');
			line.className = params.config.lineClass;
			for (var j = 0; j < params.body.layout[i].length; j++) {
				var item = params.body.layout[i][j];
				switch (item.type) {
					case 'label':
						var el1 = newEl('span', [[ 'name', item.name], [ 'id', makeId(item.name) ]]);
						el1.className = item.klass;
						el1.innerHTML = item.text;
						line.appendChild(el1);
						break;
					case 'input':
						var el2 = newEl('input', [[ 'name', item.name], [ 'id', makeId(item.name) ]]);
						el2.className = item.klass;
						line.appendChild(el2);
						if (item.focus)
							focusedEl = el2;
						break;
					case 'select':
						var el3 = newEl('select', [[ 'name', item.name], [ 'id', makeId(item.name) ]]);
						el3.className = item.klass;
						for (var k = 0; k < item.options.length; k++) {
							var option;
							if (item.options[k] instanceof Array) {
								option = newEl('option', [[ 'value', item.options[k][0]]]);
								option.innerHTML = item.options[k][1];
							} else {
								option = newEl('option');
								option.innerHTML = item.options[k];
							}
							el3.appendChild(option);
						}
						line.appendChild(el3);
						if (item.focus)
							focusedEl = el3;
						break;
				}
			}
			form.appendChild(line);
		}

		var footer = newEl('div');
		footer.className = 'yui3-dlg-footer';
		for (i = 0; i < params.footer.buttons.length; i++) {
			var typ = (params.config.div === undefined && params.footer.buttons[i].action === 'submit') ? 'submit' : 'button';
			var but = Y.one(newEl('input', [[ 'type', typ], [ 'value', params.footer.buttons[i].label ], [ 'data-index', ''+i ]]));
			footer.appendChild(but._node);
			if (params.footer.buttons[i].action === 'cancel') {
				but.on("click", function(e) {
					This.cancel();
					return false;
				});
			} else if (params.footer.buttons[i].action === 'submit') {
				if (params.config.div !== undefined) {
					but.on("click", function(e) {
						This.setFlash("Saving score...", false);
						var data = This.getAllData();
						if (params.config.onsubmit) {
							var notice = params.config.onsubmit(data);
							if (notice) {
								This.setFlash(notice, true);
								return;
							}
						}
						ajaxCall(This, params.config.action, params.config.div, data);
					});
				}
			} else {
				but.on("click", function(e) {
					var index = e.target._node.getAttribute('data-index');
					params.footer.buttons[parseInt(index)].action(This);
					return false;
				});
			}

			if (params.footer.buttons[i].def) {
				dialogMaker.defaultAction = params.footer.buttons[i].action;
				var enter = 13;

				Y.delegate('key', function(e) {
					e.halt();
					dialogMaker.defaultAction(This);
				}, 'body', '#'+params.config.id, 'down:'+enter, Y);
			}
		}
		form.appendChild(footer);

		var overlay = new Y.Overlay({
			visible:false,
			zIndex:10,
			headerContent: header,
			bodyContent: form
		});

		overlay.render();
        overlay.show();
		overlay.set("align", {
			node:params.config.align,
			points:[Y.WidgetPositionAlign.TL, Y.WidgetPositionAlign.BL]
		});
		if (focusedEl)
			focusedEl.focus();

		this.cancel = function() {
			overlay.hide();
			var form = Y.one("#" + params.config.id);
			var parent = form.ancestor(".yui3-overlay");
			parent.remove();
		};

		this.setFlash =  function(msg, isError) {
			var flash = Y.one("#dlgFlash");
			if (msg.length === 0)
				flash.addClass('hidden');
			else {
				flash.addClass(isError === false ? 'dlg_flash_ok' : 'dlg_flash_error');
				flash.set('innerHTML', msg);
				flash.removeClass('hidden');
			}
		};

		this.getAllData = function() {
			var data = {};
			var inputs = Y.all("#" + params.config.id + " input");
			inputs.each(function(el) {
				if (el._node.type === 'checkbox') {
					data[el._node.name] = el._node.checked;
				} else if (el._node.type === 'radio') {
					if (el._node.checked)
						data[el._node.name] = el._node.value;
				} else if (el._node.type !== 'button') {
					data[el._node.name] = el._node.value;
				}
			});

			var selects = Y.all("#" + params.config.id + " select");
			selects.each(function(el) {
				var sel = el._node.options[el._node.selectedIndex];
				if (sel.value)
					data[el._node.name] = sel.value;
				else
					data[el._node.name] = sel.text;
			});

//			editors.each(function(editor) {
//				editor.save();
//			});
//
//			customList.each(function(ctrl) {
//				var cl = ctrl.getSelection();
//				data[cl.field] = cl.value;
//			});

//			var textareas = $$("#" + dlg_id + " textarea");
//			textareas.each(function(el) {
//				var id = el.name;
//				var value = el.value;
//				data[id] = value;
//			});
			return data;
		};
	};
});
