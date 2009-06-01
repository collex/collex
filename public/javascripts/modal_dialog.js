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

/*global YAHOO */
/*global Class, $, $$, $H, Ajax */

//
// Monkey patch to get the editor to return the real selection.
//
var debugStr = "";

// This searches the node for the number of previous siblings it has.
YAHOO.widget.SimpleEditor.prototype.getNumSibs = function (node) {
	var sibs = 0;
	var x = node;
	while (x.previousSibling) {
		x = x.previousSibling;
		sibs++;
	}
	return sibs;	
};

YAHOO.widget.SimpleEditor.prototype.getXPathPosition = function (node) {
	// This figures out the xpath of the element in the node.
	// It traces back through all the parentNodes, and all the previousSiblings.
	// The position of each level is the number of siblings before it.
	var siblings = this.getNumSibs(node);
	var parents = [];
	var x = node;
	while (x.parentNode.tagName !== 'BODY') {
		if (x.parentNode)
			parents.push(this.getNumSibs(x.parentNode));
		x = x.parentNode;
	}

	// We discovered the parent's positions by working backwards, so we want to reverse the array before returning it.
	var xpath = [];
	for (var i = parents.length-1; i >= 0; i-- )
		xpath.push(parents[i]);
	
	// And add the current node's position, too.
	xpath.push(siblings);
				
	return xpath;
};

YAHOO.widget.SimpleEditor.prototype.checkStringForMatchingTags = function (str) {
	var level = 0;
	for (var i = 0; i < str.length-1; i++) {
		if (str[i] === '<') {
			if (str[i+1] === '/')
				level--;
			else
				level++;
		}
		if (level < 0)	// if there is an end tag before a start tag
			return false;
	}
	return level === 0;
};

YAHOO.widget.SimpleEditor.prototype.splitHtmlIntoArray = function (str) {
	// Split the string into an array where each element is a string containing either text, a start tag, or an end tag
	var arr = str.split('<');
	arr = arr.map(function(i) { return '<' + i; });
	// We don't want a blank first element, and we don't want the "<" on the first element.
	if (arr[0] === '<')
		arr.shift();
	else
		arr[0] = arr[0].substring(1);	// Don't want the < on the first element
	
	// split out the tags from the text that follows.
	var arr2 = [];
	for (var i = 0; i < arr.length; i++) {	// move close tags to the element above
		if (arr[i].indexOf('>') > 0) {
			var x = arr[i].split('>');
			arr2.push(x[0] + '>');
			arr2.push(x[1]);
		}
		else
			arr2.push(arr[i]);
	}
	
	return arr2;
};

YAHOO.widget.SimpleEditor.prototype.excludeOuterTagsFromSelection = function (val, aOffset, fOffset) {
	// Get rid of any tags in the front.
	while (val[aOffset] === '<') {
		aOffset = aOffset + val.substring(aOffset).indexOf('>') + 1;
	}
	
	// Get rid of any tags in the back.
	var x = val[fOffset-1];
	while (val[fOffset-1] === '>') {
		fOffset = val.substring(0, fOffset-1).lastIndexOf('<');
	}
	return { aOffset: aOffset, fOffset: fOffset };
};

YAHOO.widget.SimpleEditor.prototype.canInsertTagsAroundSelection = function (val, aOffset, fOffset) {
	// Be sure that the two insertion points will make legal HTML code. We do that by making sure that there are the same
	// number of start and end tags inside the selection.
	var selection = val.substring(aOffset, fOffset);
	var match = this.checkStringForMatchingTags(selection);
	
	if (!match) {
		// Get rid of the bounding tags and try again.
		var newSel = this.excludeOuterTagsFromSelection(val, aOffset, fOffset);
		aOffset = newSel.aOffset;
		fOffset = newSel.fOffset;
		selection = val.substring(aOffset, fOffset);
		match = this.checkStringForMatchingTags(selection);
	}
	
	if (!match) {
		// The user selected in the middle of a couple of different levels of nodes. This would
		// create illegal HTML if we tried to inject start and end tags there.
		return { errorMsg: "You cannot create a link when the selection is over different levels. [" + selection + ']' };
	}
	
	return { aOffset: aOffset, fOffset: fOffset, selection: selection, errorMsg: null };
};

// This fixes a bug in FF 3.0.7 where sometimes only one side of the selection is returned.
YAHOO.widget.SimpleEditor.prototype.guessSelectionEnd = function (val, selStart, selStr) {
	var ln = (selStr+'').length;	// Without adding an empty string, the length function returns "undefined" on FF 3.0.7
	var v = val.substring(selStart-ln, selStart);
	if (v === selStr)
		return selStart - ln;
	v = val.substring(selStart, selStart+ln);
	if (v === selStr)
		return selStart + ln;
	return -1;
};

// Get the user's selection in offsets into the raw HTML.
// A hash is returned with the start and end positions, and an error string, if any.
YAHOO.widget.SimpleEditor.prototype.getRawSelectionPosition = function () {
	if (this.browser.opera) {
		return null;
	}
	
	// Use the editor's routine to get the selection. This will be really different between IE 6/7 and other browsers
	var s = this._getSelection();
	if (this.browser.webkit) {
		if (s+'' === '') {
			s = null;
		}
	} else if (this.browser.ie) {
		// TODO-PER: This isn't right. It will match the first occurrance of the text selected. It's better than nothing, though.
		var rng = s.createRange();
		var selText = rng.htmlText;
		var val = this.getEditorHTML();
		var idx = val.indexOf(selText);
		if (idx === -1)
			s.rangeCount = 2;
		else
			return { startPos: idx, endPos: idx + selText.length, selection: selText, errorMsg: null };
	} else {
		if (!s || (s.toString() === '') || (s === undefined)) {
			s = null;
		}
	}

	if (s.rangeCount !== 1)
		return { errorMsg: "You cannot create a link when more than one area is selected." };
	
	// get what we need out of the selection object
	var a = s.anchorNode;
	var aoff = s.anchorOffset;
	var f = s.focusNode;
	var foff = s.focusOffset;
	var selStr = s.toString();
	
	// In Firefox 3.0.7, at least, we sometimes aren't returned both sides of the selection. If we get at least
	// one side, we have the workaround that we can get the selection's text, and we have either the start
	// or the end of the selection, so we can figure it out (unless there are two repeated strings on either side of
	// the selection, like "abc|abc" where the bar is the selection point.)
	if (a.tagName === 'BODY' && f.tagName === 'BODY')	// Neither side was returned. We have nothing to work with.
		return { errorMsg: "The selection cannot be determined. Try selecting in a different way." };
	
	// if we don't have the info in the selection for one side, we make that object null, and compensate below.
	var apos = (a.tagName === 'BODY') ? null : this.getXPathPosition(a);
	var fpos = (f.tagName === 'BODY') ? null : this.getXPathPosition(f);

	// Now parse the raw string to figure out where the xpaths created above (in aoff and foff) fall in the string.
	var val = this.getEditorHTML();
	var arr = this.splitHtmlIntoArray(val);

	// Now we go through the raw html, create xpath levels for each node, and
	// keep track of the number of characters consumed so that we can get a
	// character position of where the selection was in relation to the entire
	// raw html string.
	var aOffset = -1;
	var fOffset = -1;
	
	var arrLevels = [ -1 ];
	var ty = "";
	var charCount = 0;
	debugStr = "";
	arr.each(function(i) {
		if (i === "<br>") { // the item is self-contained.
			arrLevels[arrLevels.length-1]++;
		} else if (i.substring(0, 2) === "</") {	// this array item is an end tag.
			arrLevels.pop();
		} else if (i.substring(0, 1) === "<" && i.substring(i.length-3) === "/>") { // the item is self contained
			arrLevels[arrLevels.length-1]++;
		} else if (i.substring(0, 1) === "<") {	// this array item is a start tag.
			arrLevels[arrLevels.length-1]++;
			arrLevels.push(-1);
		} else if (i === "" ){	// The item is empty, so don't count it.
		} else {	// this array item is text.
			arrLevels[arrLevels.length-1]++;
		}
		
		// See if this one is a match. If so, we can save the accumulated characters used, plus the offset into this element.
		var match = "";
		var levelStr = arrLevels.join(',');
		if (apos && apos.join(',') === levelStr)
			aOffset = charCount + aoff;
		if (fpos && fpos.join(',') === levelStr)
			fOffset = charCount + foff;
		
		charCount += i.length;
		debugStr += arrLevels.join(',') + "&nbsp;&nbsp;&nbsp;&nbsp;" + i.escapeHTML() + "<br />";
	});
	
	// If either offset is missing, try to figure it out by using the selection string.
	if (aOffset === -1) {
		aOffset = this.guessSelectionEnd(val, fOffset, selStr);
	}
	if (fOffset === -1) {
		fOffset = this.guessSelectionEnd(val, aOffset, selStr);
	}
	
	// Switch the anchor and the focus in case the user selected from right to left
	if (aOffset > fOffset) {
		var x = aOffset;
		aOffset = fOffset;
		fOffset = x;
	}
	
	var ret = this.canInsertTagsAroundSelection(val, aOffset, fOffset);
	if (ret.errorMsg) {
		// The user selected in the middle of a couple of different levels of nodes. This would
		// create illegal HTML if we tried to inject start and end tags there.
		return { errorMsg: ret.errorMsg };
	}

	return { startPos: ret.aOffset, endPos: ret.fOffset, selection: ret.selection, errorMsg: null };
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

var RichTextEditor = Class.create({
	initialize: function (params) {
		this.class_type = 'RichTextEditor';	// for debugging

		// private variables
		var This = this;
		var id = params.id;
		var toolbarGroups = params.toolbarGroups;
		var linkDlgHandler = params.linkDlgHandler;

		var toolgroupFont = {
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
		};
		
		var toolgroupFontStyle = {
			group: 'textstyle', label: 'Font Style',
			buttons: [{ 	type: 'push', label: 'Bold CTRL + SHIFT + B', value: 'bold' },
				{ type: 'push', 	label: 'Italic CTRL + SHIFT + I', value: 'italic' },
				{ type: 'push', 	label: 'Underline CTRL + SHIFT + U', value: 'underline' }]
		};
		
		var toolgroupFontStyleDropCap = {
			group: 'textstyle', label: 'Font Style',
			buttons: [{ 	type: 'push', label: 'Bold CTRL + SHIFT + B', value: 'bold' },
				{ type: 'push', 	label: 'Italic CTRL + SHIFT + I', value: 'italic' },
				{ type: 'push', 	label: 'Underline CTRL + SHIFT + U', value: 'underline' },
				{ type: 'push', label: 'First Letter', value: 'firstletter' 	}]
		};

		var toolgroupAlignment = {
			group: 'alignment', label: 'Alignment', 
	        buttons: [ 
	            { type: 'push', label: 'Align Left CTRL + SHIFT + [', value: 'justifyleft' }, 
	            { type: 'push', label: 'Align Center CTRL + SHIFT + |', value: 'justifycenter' }, 
	            { type: 'push', label: 'Align Right CTRL + SHIFT + ]', value: 'justifyright' }, 
	            { type: 'push', label: 'Justify', value: 'justifyfull' } 
	        ] 
	    };

		var toolgroupList = {
			group: 'indentlist',
			label: 'Lists',
			buttons: [{ type: 'push', label: 'Create an Unordered List', value: 'insertunorderedlist' },
				{ type: 'push', label: 'Create an Ordered List', value: 'insertorderedlist' }]
		};
		
		var toolgroupLink = {
			group: 'insertitem',
			label: 'Insert Item',
			buttons: [{ 	type: 'push', label: 'HTML Link CTRL + SHIFT + L', value: 'createlink', disabled: true }]
		};
		
		var toolgroupSeparator = {
			type: 'separator'
		};

		// private functions
		var processDropCap = function()
		{
			var editor = This.editor;

		    editor.on('toolbarLoaded', function() { 
		         this.toolbar.on('firstletterClick', function(ev) {	// 'this' is now the editor
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
								if (classPos === -1)
									html = "<p class='drop_cap'" + html.substring(2);
								else
									html = html.substring(0, classPos+7) + "drop_cap " + html.substring(classPos+7);
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
		};
		
		var initLinkDlg = function()
		{
			if (linkDlgHandler === undefined || linkDlgHandler === null)
				return;
				
			var editor = This.editor;

			editor.on('toolbarLoaded', function() {
			    //When the toolbar is loaded, add a listener to the insertimage button
			    editor.toolbar.on('createlinkClick', function() {
					
					// Get the selection object. Unfortunately, what is returned varies widely between browsers.
					var result = editor.getRawSelectionPosition();
					if (!result) {
						new MessageBoxDlg("Error", "IE has not been implemented yet.");
						//this.formatSelection();
						return false;
					}
	
					if (result.errorMsg) {
						new MessageBoxDlg("Error", result.errorMsg);
						return false;
					}
					
					linkDlgHandler.show(This, id + "_container", editor.getEditorHTML(), result.startPos, result.endPos);
					
		            //This is important.. Return false here to not fire the rest of the listeners
		            return false;
			    }, this, true);
			}, this, true);
		};

		var setResize = function(id)
		{
			var editor = This.editor;

			editor.on('editorContentLoaded', function() { 
				var resize = new YAHOO.util.Resize(editor.get('element_cont').get('element'), {
				    handles: ['b', 'r', 'br'],
				    autoRatio: true,
				    status: false,
				    proxy: true,
				    setSize: false //This is where the magic happens
				});
				resize.on('startResize', function() {
				    this.hide();
				    this.set('disabled', true);
				}, editor, true);
				resize.on('resize', function(args) {
				    var h = args.height;
				    var th = (this.toolbar.get('element').clientHeight + 2); //It has a 1px border..
				    var dh = 0; //(this.dompath.clientHeight + 1); //It has a 1px top border..
				    var newH = (h - th - dh);
				    this.set('width', args.width + 'px');
				    this.set('height', newH + 'px');
				    this.set('disabled', false);
				    this.show();
				}, editor, true);
			});
		};
	
		// privileged methods
		this.attachToDialog = function(dialog) {
			//RTE needs a little love to work in in a Dialog that can be 
			//shown and hidden; we let it know that it's being
			//shown/hidden so that it can recover from these actions:
			dialog.showEvent.subscribe(this.editor.show, this.editor, true);
			dialog.hideEvent.subscribe(this.editor.hide, this.editor, true);
		};
		
		// This puts the edited content back in the original textArea so it can be send back to the server.
		this.save = function() {
			var b = this.editor._getDoc().body;
			if (b !== undefined) {
				this.editor.cleanHTML();
				this.editor.saveHTML();
			}
		};
		
		//
		// constructor code
		//
		
		// TODO-PER: Make this generic. Should be able to mix and match buttons. Right now there are only the following combos that are accepted.
		var toolbar = {
			buttonType: 'advanced',
			draggable: false,
			buttons: []
		};
		
		var hasDropCap = false;
		var isFirst = true;
		toolbarGroups.each(function(group) {
			if (!isFirst)
				toolbar.buttons.push(toolgroupSeparator);
			isFirst = false;

			switch (group)
			{
				case 'font':
					toolbar.buttons.push(toolgroupFont);
					break;
				case 'fontstyle':
					toolbar.buttons.push(toolgroupFontStyle);
					break;
				case 'dropcap':
					hasDropCap = true;
					toolbar.buttons.push(toolgroupFontStyleDropCap);
					break;
				case 'alignment':
					toolbar.buttons.push(toolgroupAlignment);
					break;
				case 'list':
					toolbar.buttons.push(toolgroupList);
					break;
				case 'link':
					toolbar.buttons.push(toolgroupLink);
					break;
			}
		});

		//create the RTE:
		var width = params.width != null ? params.width : 702;
		this.editor = new YAHOO.widget.SimpleEditor(id, {
			  width: width + 'px',
				height: '200px',
				// TODO-PER: Can the CSS be read from a file, so it doesn't have to be repeated here? (Check out YUI Loader Utility)
				css: YAHOO.widget.SimpleEditor.prototype._defaultCSS + ' a:link { color: #A60000 !important; text-decoration: none !important; } a:visited { color: #A60000 !important; text-decoration: none !important; } a:hover { color: #A60000 !important; text-decoration: none !important; } .nines_linklike { color: #A60000; background: url(../images/nines_link.jpg) center right no-repeat; padding-right: 13px; } .ext_linklike { 	color: #A60000; background: url(../images/external_link.jpg) center right no-repeat; padding-right: 13px; } .drop_cap:first-letter {	color:#999999;	float:left;	font-family:"Bell MT","Old English",Georgia,Times,serif;	font-size:420%;	line-height:0.85em;	margin-bottom:-0.15em;	margin-right:0.08em;} .drop_cap p:first-letter {	color:#999999;	float:left;	font-family:"Bell MT","Old English",Georgia,Times,serif;	font-size:420%;	line-height:0.85em;	margin-bottom:-0.15em;	margin-right:0.08em;}',
				toolbar: toolbar,
	            //dompath: true,
	            animate: true
		});

		if (hasDropCap)
			processDropCap();

		//render the editor explicitly into a container
		//within the Dialog's DOM:
		this.editor.render();
		
		// Replace the link dialog with our own.
		initLinkDlg();
		
		// Add the resizing widgets
		//setResize();
	}
});
	
	//	dumpObj : function (obj, indent)
	//	{
	//		var str = "";
	//		var tab = "";
	//		for (var i = 0; i < indent; i++)
	//			tab += "&nbsp;&nbsp;&nbsp;&nbsp;";
	//			
	//		for (x in obj) {
	//			if (obj[x])
	//				var ty = "x" + obj[x].constructor;
	//			else
	//				var ty = "null null";
	//			var arr = ty.split(' ');
	//			ty = arr[1].replace("(", "");
	//			ty = ty.replace(")", "");
	//			ty = ty.replace(']', "");
	//			if (ty === 'String')
	//				str += tab + ty + ' ' + x + '=' + obj[x].escapeHTML() + "<br />";
	//			else
	//				str += tab + ty + ' ' + x + '=' + obj[x] + "<br />";
	//			if ((ty == 'Text' || ty == 'TextConstructor') && indent == 0) {	// Text for Firefox, TextConstructor for Safari
	//				str += this.dumpObj(obj[x], 1);
	//			}
	//		}
	//		return str;
	//	},
		
	//	formatSelection: function () {
	//        var selectedText = this.editor._getSelection().createRange().text;
	//        
	//        if (selectedText != "") {
	//            var newText = "[" + selectedText + "]";
	//            this.editor._getSelection().createRange().text = newText;
	//        }
	//    },
	//	});

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

var ModalDialog = Class.create();

ModalDialog.prototype = {
	initialize: function () {
		this.editors = [];
	},
	
	_type: "ModalDialog",

	_divId: null,
	dialog: null,
	targetElement: null,
	formID: null,
	_okFunction: null,
	_okObject: null,
	_linkDlgHandler: null,
	_cancelCallback: null,
	_cancelThis: null,
	_onCompleteCallback:null,
	_saveButtonName: 'Save',
	
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
		
		YAHOO.util.Event.on(YAHOO.util.Dom.getElementsByClassName("container-close", "a", this._divId), "click", this._handleCancel, this, true);
	},
	
	show: function(title, targetElement, form, left, top, width, height, extraButtons, linkDlgHandler, noButtons, cancelCallback, cancelThis) {
		
		this._cancelCallback = cancelCallback;
		this._cancelThis = cancelThis;
		this._linkDlgHandler = linkDlgHandler;
		this._divId = title.gsub(' ', '') + "_modal_dialog";
		this._createDiv(this._divId);

		//create Dialog:
		this.dialog = new YAHOO.widget.Dialog(this._divId, {
			x: left, y: top, //width: width, height: height,
			constraintoviewport: true,
			modal: true
		});
		
		this._handleEsc();
		if (!noButtons)
			this._setButtons();
		this._renderForm(title, targetElement, form);
		this._setRichTextAreas(extraButtons);
		this.dialog.show();
		
		YAHOO.util.Event.on(YAHOO.util.Dom.getElementsByClassName("container-close", "a", this._divId), "click", this._handleCancel, this, true);
	},
	
	showLightbox: function(title, targetElement, form, left, top) {
		
		this._divId = title.gsub(' ', '') + "_modal_dialog";
		this._createDiv(this._divId);
		
		//create Dialog:
		this.dialog = new YAHOO.widget.Dialog(this._divId, {
			//constraintoviewport: true,
			//x: currentScrollPos()[0], y: currentScrollPos()[1],
			x: left, y: top,
			modal: true
		});
		
		this._handleEsc();
		this._setCancelButton();
		this._renderForm(title, targetElement, form);
		
		YAHOO.util.Event.on(YAHOO.util.Dom.getElementsByClassName("container-close", "a", this._divId), "click", this._handleCancel, this, true);
	},
	
	setCompleteCallback: function(callBack)
	{
		this._onCompleteCallback = callBack;
	},
	
	setSaveButton: function(name) {
		this._saveButtonName = name;
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
		
		this.editors.each(function(editor) {
			editor.save();
		})

		this._sendToServer(this.targetElement, this.formID);
		this.dialog.hide();
		this.dialog.destroy();
	},

	//if the user clicks cancel, we call Dialog's
	//cancel method:
	_handleCancel: function() {
		this.dialog.cancel();
		YAHOO.lang.later(500, this.dialog, this.dialog.destroy, null, false);	// Delay destroy to fix crash in IE7 when X is clicked
		if (this._cancelCallback)
		{
			this._cancelCallback(this._cancelThis);
		}
	},	
	
	_createDiv : function(id)
	{
		// if it already exists, destroy and recreate it
//		if( $(id) ) {
//			this.dialog.destroy();
//		}

		var modalDialogDiv = new Element("div", { id: id });
		$$('body').first().appendChild(modalDialogDiv);
	},
	
	_handleEsc : function()
	{
		var klEsc = new YAHOO.util.KeyListener(document, { keys:27 },  							
			{ fn:this._handleCancel,
				scope:this,
				correctScope:true }, "keyup" ); 
			// keyup is used here because Safari won't recognize the ESC
			// keydown event, which would normally be used by default
		this.dialog.cfg.queueProperty("keylisteners", klEsc);
	},
	
	_setButtons : function()
	{
		//set up buttons for the Dialog and wire them
		//up to our handlers:
		var myButtons = [ { text: this._saveButtonName, handler: { fn: this._handleSave, obj: null, scope: this }, isDefault:true 	},
			{ text:"Cancel", handler: { fn: this._handleCancel, obj: null, scope: this } }];
		this.dialog.cfg.queueProperty("buttons", myButtons);
	},
	
	_setCancelButton : function()
	{
		//set up buttons for the Dialog and wire them
		//up to our handlers:
		var myButtons = [ { text:"Cancel", handler: { fn: this._handleCancel, obj: null, scope: this }, isDefault:true }];
		this.dialog.cfg.queueProperty("buttons", myButtons);
	},
	
	_setRichTextAreas : function(extraButtons)
	{
		var textAreas = $$('#'+this.formID+' textarea');
		
		textAreas.each( function(textArea) { 
			var editor = new RichTextEditor({ id: textArea.id, toolbarGroups: extraButtons, linkDlgHandler: this._linkDlgHandler });
			editor.attachToDialog(this.dialog);
			this.editors.push(editor);
		}, this);
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

	_sendToServer: function( element_id, form_id ) {
		var el = $(element_id);
	
		var params = { element_id: element_id };
		var els = $$('#' + form_id + ' input');
		els.each(function(e) { params[e.id] = e.value; });
		els = $$('#' + form_id + ' textarea');
		els.each(function(e) { params[e.id] = e.value; });
		els = $$('#' + form_id + ' select');
		els.each(function(e) { params[e.id] = e.value.unescapeHTML(); });
		
		if (this._okFunction != null)
		{
			this._okFunction(	this._okObject, params);	
		}
		else
		{
			// We weren't given a function for ok, therefore we want to ajax the results back to the server.
			var action = el.readAttribute('action');
			var ajax_action_element_id = el.readAttribute('ajax_action_element_id');
			
			if (ajax_action_element_id == "")
			{
				// Instead of replacing an element, we want to redraw the entire page. There seems to be some conflict
				// if the form is resubmitted, so duplicate the form.
				new_form = new Element('form', { id: form_id + "2", method: 'post', onsubmit: "this.submit();", action: action });
				new_form.observe('submit', "this.submit();");
				document.body.appendChild(new_form);
				$H(params).each(function (p) { new_form.appendChild(new Element('input', { name: p.key, value: p.value, id: p.key })); });

				$(this.targetElement).appendChild(new Element('img', { src: "/images/ajax_loader.gif", alt: ''}));
				new_form.submit();
				
				return;
			}
		
			// If we have a comma separated list, we want to send the request synchronously to each action
			// (Doing this synchronously eliminates any race condition: The first call can update the data and
			// the rest of the calls just update the page.
			var actions = action.split(',');
			var action_elements = ajax_action_element_id.split(',');
			if (actions.length == 1)
			{
				new Ajax.Updater(ajax_action_element_id, action, {
					parameters : params,
					evalScripts : true,
					onComplete : this._onCompleteCallback,				
					onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
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
							onComplete : this._onCompleteCallback,						
							onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
						});
					},
					onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
				});
			}
		}
	}
}

