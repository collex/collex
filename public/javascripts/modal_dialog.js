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


ModalDialog = Class.create();

ModalDialog.prototype = {
	initialize: function () {
	},
	
	_divId: null,
	dialog: null,
	editor: null,
	targetElement: null,
	formID: null,
	usesRichTextArea: false,
	_okFunction: null,
	_okObject: null,
	_linkDlgHandler: null,
	
	showPrompt: function(title, targetElement, form, left, top, width, height, extraButtons, okFunction, okObject) {
		
		this._okFunction = okFunction;
		this._okObject = okObject;
		
		this._divId = title.gsub(' ', '') + "_modal_dialog";
		this._createDiv(this._divId);

		//create Dialog:
		this.dialog = new YAHOO.widget.Dialog(this._divId, {
			x: left, y: top, width: width, height: height,
			constraintoviewport: true,
			modal: true
		});
		
		this._handleEsc();
		this._setButtons();
		this._renderForm(title, targetElement, form);
		this._setRichTextAreas(extraButtons);
		this.dialog.show();
		this._setResize(this._divId);
	},
	
	show: function(title, targetElement, form, left, top, width, height, extraButtons, linkDlgHandler) {
		
		this._linkDlgHandler = linkDlgHandler;
		this._divId = title.gsub(' ', '') + "_modal_dialog";
		this._createDiv(this._divId);

		//create Dialog:
		this.dialog = new YAHOO.widget.Dialog(this._divId, {
			x: left, y: top, width: width, height: height,
			constraintoviewport: true,
			modal: true
		});
		
		this._handleEsc();
		this._setButtons();
		this._renderForm(title, targetElement, form);
		this._setRichTextAreas(extraButtons);
		this.dialog.show();
		this._setResize(this._divId);
	},
	
	showLightbox: function(title, targetElement, form) {
		
		this._divId = title.gsub(' ', '') + "_modal_dialog";
		this._createDiv(this._divId);
		
		//create Dialog:
		this.dialog = new YAHOO.widget.Dialog(this._divId, {
			constraintoviewport: true,
			x: currentScrollPos()[0], y: currentScrollPos()[1],
			modal: true
		});
		
		this._handleEsc();
		this._setCancelButton();
		this._renderForm(title, targetElement, form);
	},
	
	center: function()
	{
		var div = $(this._divId).up();
		var w = parseInt(div.getStyle('width'));
		var h = parseInt(div.getStyle('height'));
		var vpHeight = getViewportHeight();
		var vpWidth = getViewportWidth();
		
		// Now that we see how big the image is, center it
		var left = (vpWidth - w)/2;
		var top = (vpHeight - h)/2;
		div.setStyle({ left: left + currentScrollPos()[0] + 'px', top: top + currentScrollPos()[1] + 'px' });
	},

	///////////////////////// private functions //////////////////////////////////////

	//if the user clicks "save", then we save the HTML
	//content of the RTE and submit the dialog:
	_handleSave: function() {
		
		if( this.usesRichTextArea )
			this.editor.saveHTML();
		
		this._sendToServer(this.targetElement, this.formID);
		this.dialog.hide();
		this.dialog.destroy();
	},

	//if the user clicks cancel, we call Dialog's
	//cancel method:
	_handleCancel: function() {
		this.dialog.cancel();
		this.dialog.destroy();
	},	
	
	_createDiv : function(id)
	{
		// if it already exists, destroy and recreate it
		if( $(id) ) {
			this.dialog.destroy();
		}

		var modalDialogDiv = new Element("div", { id: id });
		$$('body').first().appendChild(modalDialogDiv);
	},
	
	_handleEsc : function()
	{
		var klEsc = new YAHOO.util.KeyListener(document, { keys:27 },  							
			{ fn:this.dialog.hide,
				scope:this.dialog,
				correctScope:true }, "keyup" ); 
			// keyup is used here because Safari won't recognize the ESC
			// keydown event, which would normally be used by default
		this.dialog.cfg.queueProperty("keylisteners", klEsc);
	},
	
	_setButtons : function()
	{
		//set up buttons for the Dialog and wire them
		//up to our handlers:
		var myButtons = [ { text:"Save", handler: { fn: this._handleSave, obj: null, scope: this } 	},
			{ text:"Cancel", handler: { fn: this._handleCancel, obj: null, scope: this }, isDefault:true }];
		this.dialog.cfg.queueProperty("buttons", myButtons);
	},
	
	_setCancelButton : function()
	{
		//set up buttons for the Dialog and wire them
		//up to our handlers:
		var myButtons = [ { text:"Cancel", handler: { fn: this._handleCancel, obj: null, scope: this }, isDefault:true }];
		this.dialog.cfg.queueProperty("buttons", myButtons);
	},
	
	_toolbarSimple : {
		buttonType: 'advanced',
		draggable: false,
		buttons: [{
			group: 'textstyle',
			buttons: [{ 	type: 'push', label: 'Bold CTRL + SHIFT + B', value: 'bold' },
				{ type: 'push', 	label: 'Italic CTRL + SHIFT + I', value: 'italic' },
				{ type: 'push', 	label: 'Underline CTRL + SHIFT + U', value: 'underline' }]
		}]
	},
	
	_toolbarNoExtra : {
		buttonType: 'advanced',
		//titlebar: 'My tool',
		draggable: false,
		buttons: [{
			group: 'fontstyle',
			label: 'Font Name and Size',
			buttons: [{
				type: 'select', label: 'Arial', value: 'fontname', disabled: true,
				menu: [{ text: 'Arial', checked: true },
					{ text: 'Arial Black' },
					{ text: 'Comic Sans MS' },
					{ text: 'Courier New' },
					{ text: 'Lucida Console' },
					{ text: 'Tahoma' },
					{ text: 'Times New Roman' },
					{ text: 'Trebuchet MS' },
					{ text: 'Verdana' } ]},
				{ type: 'spin', label: '13', value: 'fontsize', range: [9, 75], disabled: true
			}]
		},
		{ type: 'separator' },
		{ group: 'textstyle', label: 'Font Style',
			buttons: [{ 	type: 'push', label: 'Bold CTRL + SHIFT + B', value: 'bold' },
				{ type: 'push', label: 'Italic CTRL + SHIFT + I', value: 'italic' },
				{ type: 'push', label: 'Underline CTRL + SHIFT + U', value: 'underline' }]
		}, 
		{ type: 'separator'	},
		{ group: 'indentlist',
			label: 'Lists',
			buttons: [{ type: 'push', label: 'Create an Unordered List', value: 'insertunorderedlist' },
				{ type: 'push', label: 'Create an Ordered List', value: 'insertorderedlist' }]
		},
		{ type: 'separator' },
		{ group: 'insertitem',
			label: 'Insert Item',
			buttons: [{ 	type: 'push', label: 'HTML Link CTRL + SHIFT + L', value: 'createlink', disabled: true }]
		}]
	},
	
	_toolbarWithAlignment : {
		buttonType: 'advanced',
		//titlebar: 'My tool',
		draggable: false,
		buttons: [{
			group: 'fontstyle',
			label: 'Font Name and Size',
			buttons: [{
				type: 'select', label: 'Arial', value: 'fontname', disabled: true,
				menu: [{ text: 'Arial', checked: true },
					{ text: 'Arial Black' },
					{ text: 'Comic Sans MS' },
					{ text: 'Courier New' },
					{ text: 'Lucida Console' },
					{ text: 'Tahoma' },
					{ text: 'Times New Roman' },
					{ text: 'Trebuchet MS' },
					{ text: 'Verdana' } ]},
				{ type: 'spin', label: '13', value: 'fontsize', range: [9, 75], disabled: true
			}]
		},
		{ type: 'separator' },
		{ group: 'textstyle', label: 'Font Style',
			buttons: [{ 	type: 'push', label: 'Bold CTRL + SHIFT + B', value: 'bold' },
				{ type: 'push', label: 'Italic CTRL + SHIFT + I', value: 'italic' },
				{ type: 'push', label: 'Underline CTRL + SHIFT + U', value: 'underline' }]
		}, 
	    { type: 'separator' }, 
	    { group: 'alignment', label: 'Alignment', 
	        buttons: [ 
	            { type: 'push', label: 'Align Left CTRL + SHIFT + [', value: 'justifyleft' }, 
	            { type: 'push', label: 'Align Center CTRL + SHIFT + |', value: 'justifycenter' }, 
	            { type: 'push', label: 'Align Right CTRL + SHIFT + ]', value: 'justifyright' }, 
	            { type: 'push', label: 'Justify', value: 'justifyfull' } 
	        ] 
	    }, 
		{ type: 'separator'	},
		{ group: 'indentlist',
			label: 'Lists',
			buttons: [{ type: 'push', label: 'Create an Unordered List', value: 'insertunorderedlist' },
				{ type: 'push', label: 'Create an Ordered List', value: 'insertorderedlist' }]
		},
		{ type: 'separator' },
		{ group: 'insertitem',
			label: 'Insert Item',
			buttons: [{ 	type: 'push', label: 'HTML Link CTRL + SHIFT + L', value: 'createlink', disabled: true }]
		}]
	},
	
	_toolbarWithDropCap : {
		buttonType: 'advanced',
		//titlebar: 'My tool',
		draggable: false,
		buttons: [{
			group: 'fontstyle',
			label: 'Font Name and Size',
			buttons: [{
				type: 'select', label: 'Arial', value: 'fontname', disabled: true,
				menu: [{ text: 'Arial', checked: true },
					{ text: 'Arial Black' },
					{ text: 'Comic Sans MS' },
					{ text: 'Courier New' },
					{ text: 'Lucida Console' },
					{ text: 'Tahoma' },
					{ text: 'Times New Roman' },
					{ text: 'Trebuchet MS' },
					{ text: 'Verdana' } ]},
				{ type: 'spin', label: '13', value: 'fontsize', range: [9, 75], disabled: true
			}]
		},
		{ type: 'separator' },
		{ group: 'textstyle', label: 'Font Style',
			buttons: [{ 	type: 'push', label: 'Bold CTRL + SHIFT + B', value: 'bold' },
				{ type: 'push', label: 'Italic CTRL + SHIFT + I', value: 'italic' },
				{ type: 'push', label: 'Underline CTRL + SHIFT + U', value: 'underline' },
				{ type: 'push', label: 'First Letter', value: 'firstletter' 	}]
		}, 
		{ type: 'separator'	},
		{ group: 'indentlist',
			label: 'Lists',
			buttons: [{ type: 'push', label: 'Create an Unordered List', value: 'insertunorderedlist' },
				{ type: 'push', label: 'Create an Ordered List', value: 'insertorderedlist' }]
		},
		{ type: 'separator' },
		{ group: 'insertitem',
			label: 'Insert Item',
			buttons: [{ 	type: 'push', label: 'HTML Link CTRL + SHIFT + L', value: 'createlink', disabled: true }]
		}]
	},
	
//	_setRichTextAreaTiny : function(textAreaId)
//	{
//		//create the RTE:
//		this.editor = new YAHOO.widget.SimpleEditor(textAreaId, {
//			  width: '400px',
//				height: '2em',
//				toolbar: this._toolbarSimple
//		});
//
//		//render the editor explicitly into a container
//		//within the Dialog's DOM:
//		this.editor.render();
//		
//		//RTE needs a little love to work in in a Dialog that can be 
//		//shown and hidden; we let it know that it's being
//		//shown/hidden so that it can recover from these actions:
//		this.dialog.showEvent.subscribe(this.editor.show, this.editor, true);
//		this.dialog.hideEvent.subscribe(this.editor.hide, this.editor, true);							
//		
//	    this.editor('afterRender', function() {
//			var toolbar = $(textAreaId + "_toolbar");
//			toolbar.setStyle({ position: 'absolute', right: '10px' });
//			var editArea = toolbar.next('.yui-editor-editable-container');
//			editArea.setStyle({ marginRight: '100px' });
//		}, this.editor, this);
//	},

	_processDropCap : function()
	{
	    this.editor.on('toolbarLoaded', function() { 
	         this.toolbar.on('firstletterClick', function(ev) {
				var html = this.getEditorHTML();
				// TODO-PER: how do you get the button to stay selected or unselected? Until then, just look for the class to see which to do.
				var sel = !html.include("drop_cap"); // !ev.button.isSelected
				if (sel)
				{
					// If there is a <p> that starts everything, then add the drop class to it, if it is not already there. If not, then add the p element.
					if (!html.include("drop_cap"))
					{
						if (!html.startsWith("<p"))
							html = "<p class='drop_cap'>" + html + "</p>";
						else
						{
							var firstp = html.substring(0, html.indexOf('>'));
							var classPos = firstp.indexOf('class=');
							if (classPos == -1)
								html = "<p class='drop_cap'" + html.substring(2);
							else
								html = html.substring(0, classPos+7) + "drop_cap" + html.substring(classPos+8);
						}
					}
				}
				else
				{
					// Remove the drop class whereever it appears.
					html = html.gsub("drop_cap", "");
				}
				this.setEditorHTML(html);
//					var _button = this.toolbar.getButtonByValue('firstletter'); 
//					_button._selected = true;
				//this.execCommand('inserthtml', "TEST");
	        }, this, true);
	    });
	},
	
	_setRichTextAreas : function(extraButtons)
	{
		var textAreas = $$('#'+this.formID+' textarea');
		
		this.usesRichTextArea = (textAreas.length > 0);
		
		// TODO-PER: Make this generic. Should be able to mix and match buttons. Right now there are only the following combos that are accepted.
		var toolbar = null;
		if (extraButtons == undefined)
			extraButtons = [];
			
		if (extraButtons.length == 0)
			toolbar = this._toolbarNoExtra;
		else if (extraButtons[0] == 'alignment')
			toolbar = this._toolbarWithAlignment;
		else if (extraButtons[0] == 'drop_cap')
			toolbar = this._toolbarWithDropCap;

		textAreas.each( function(textArea) { 
			//create the RTE:
			// TODO-PER: This only works if there is only one textarea in the form. Make this generic when the second textarea is added.
			this.editor = new YAHOO.widget.SimpleEditor(textArea.id, {
				  width: '702px',
					height: '200px',
					// TODO-PER: Can the CSS be read from a file, so it doesn't have to be repeated here? (Check out YUI Loader Utility)
					css: YAHOO.widget.SimpleEditor.prototype._defaultCSS + ' .linklike { color:#A60000; } .drop_cap:first-letter {	color:#999999;	float:left;	font-family:"Bell MT","Old English",Georgia,Times,serif;	font-size:420%;	line-height:0.85em;	margin-bottom:-0.15em;	margin-right:0.08em;} .drop_cap p:first-letter {	color:#999999;	float:left;	font-family:"Bell MT","Old English",Georgia,Times,serif;	font-size:420%;	line-height:0.85em;	margin-bottom:-0.15em;	margin-right:0.08em;}',
					toolbar: toolbar,
			});
			
			if (extraButtons.length > 0 && extraButtons[0] == 'drop_cap')
				this._processDropCap();

			//attach the Editor's reusable property-editor
			//panel to an element inside our main Dialog --
			//this allows it to get focus even when the Dialog
			//is modal:
			// this.editor.on('windowRender', function() {
			// 	document.getElementById('descriptionContainer').appendChild(this.get('panel').element);
			// });

			//render the editor explicitly into a container
			//within the Dialog's DOM:
			this.editor.render();
			
			//RTE needs a little love to work in in a Dialog that can be 
			//shown and hidden; we let it know that it's being
			//shown/hidden so that it can recover from these actions:
			this.dialog.showEvent.subscribe(this.editor.show, this.editor, true);
			this.dialog.hideEvent.subscribe(this.editor.hide, this.editor, true);
			
			// Replace the link dialog with our own.
			if (this._linkDlgHandler)
				this._initLinkDlg(this.editor, textArea.id + "_container");
		}, this);
	},
	
	_setResize: function(id)
	{
		// If there is a rich text editor on the form, then allow the dlg to be resized.
		if (this.usesRichTextArea)
		{
			var textAreas = $$('#'+this.formID+' textarea');
			var resizer = new YAHOO.util.Resize(id);
			resizer.subscribe( 'resize', this._dlgResized, textAreas[0].id, this);
		}
	},

	_renderForm: function(title, targetElement, form)
	{
		this.dialog.setHeader(title);
		this.targetElement = targetElement;
		this.formID = form.id;

		// var element = new Element("div", { id: 'descriptionContainer' });
		// form.appendChild(element);
		$(this._divId).appendChild(form);
		
		// this is a hack for IE6 compatibility, render the dialog late so that it works properly. 
		//document.getElementById(this._divId).style.display = "block";
		this.dialog.render();
		
		// fix the tab order: we don't want the close X in it.
		var closeX = $$('.container-close');
		if (closeX.length > 0)
			closeX[0].writeAttribute({ tabindex: 20 });
	},
	
	wrapSelection : function(tag)
	{
		//Focus the editor's window 
		this.editor._focusWindow(); 
		this.editor._createCurrentElement(tag);
		// PER: Don't know why the element is created with a spurious element "tag"
		this.editor.currentElement[0].setAttribute('tag', '');
		this.editor.currentElement[0].removeAttribute('tag');
		return this.editor.currentElement[0];
	},
	
	selectNode : function(node)
	{
		this.editor._selectNode(node);
	},

	_initLinkDlg : function(myEditor, id)
	{
		myEditor.on('toolbarLoaded', function() {
		    //When the toolbar is loaded, add a listener to the insertimage button
		    this.editor.toolbar.on('createlinkClick', function() {
				// We only want to allow the user a chance to make a link if they've selected something useful.
				// That is one of two things: more than one character in the same node (that is, there is no formatting),
				// or the cursor or selection is in an anchor node already.
				// In the second case, the current link is preselected when the dialog is shown.
				// If the user has selected something we can't use, then give a friendly message.
				// Also, if the user selected part of an existing anchor, then select the entire anchor.
				
				// be sure the selection doesn't go over different tags.
				var s = this.editor._getSelection();
				var single = (s.anchorNode == s.focusNode);
				if (!single)
				{
					alert("When creating a link, the selected text may not span across multiple text styles or other links. Please adjust your selection to create a link.");
					return false;
				}
				
				this._linkDlgHandler.onShowLinkDlg(this, id, s.focusNode.parentNode, (s.anchorOffset != s.focusOffset));

	            //This is important.. Return false here to not fire the rest of the listeners
	            return false;
		    }, this, true);
		}, this, true);
	},

	_dlgResized: function (event, elementIdToResize)
	{
		var el = $(elementIdToResize+"_container");
		//var elForm = el.up("." + this._divId + "_form");
		var elForm = $(this.formID);
		var fontSize = parseFloat(elForm.getStyle("fontSize"));
		var margin = parseInt(fontSize*2 + "");
		el.setStyle({ width: event.width - margin - 10 + 'px'});
		
		var elFt = $(this._divId).down('.ft');
		var ftHeight = parseInt(elFt.getStyle('height'));
		var elHd = $(this._divId).down('.hd');
		var hdHeight = parseInt(elHd.getStyle('height'));
		var elTb = el.down(".yui-toolbar-container");
		var tbHeight = parseInt(elTb.getStyle('height'));
		var yEl = getY(el);
		var yDlg = getY($(this._divId));
		var relPos = yEl - yDlg;
		
		var elHeight = el.down(".yui-editor-editable-container");
		elHeight.setStyle({ height: event.height - relPos - margin/2 - ftHeight - hdHeight - tbHeight + 'px'});
	},

	_sendToServer: function( element_id, form_id ) {
		var el = $(element_id);
	
		var params = { element_id: element_id };
		var els = $$('#' + form_id + ' input');
		els.each(function(e) { params[e.id] = e.value; });
		els = $$('#' + form_id + ' textarea');
		els.each(function(e) { params[e.id] = e.value; });
		els = $$('#' + form_id + ' select');
		els.each(function(e) { params[e.id] = e.value; });
		
		if (this._okFunction != null)
		{
			this._okFunction(	this._okObject, params);	
		}
		else
		{
			// We weren't given a function for ok, therefore we want to ajax the results back to the server.
			var action = el.readAttribute('action');
			var ajax_action_element_id = el.readAttribute('ajax_action_element_id');
			
			var onCompleteCallback = function() {
			  Try.these(
			    function() { initializeElementEditing() },
					function() {}
			  );
			}
		
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
					onComplete : onCompleteCallback,				
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
							onComplete : onCompleteCallback,						
							onFailure : function(resp) { alert("Oops, there's been an error."); }
						});
					},
					onFailure : function(resp) { alert("Oops, there's been an error."); }
				});
			}
		}
	}
}

