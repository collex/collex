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
/*global Class, $, $A, Element */
/*global MessageBoxDlg, RteInputDlg */
/*global setTimeout */
/*extern RichTextEditor */

(function() {
	var patchSimpleEditor = function() {
		//
		// Monkey patch to get the editor to return the real selection.
		//
		//var debugStr = "";

		// This searches the node for the number of previous siblings it has.
		YAHOO.widget.SimpleEditor.prototype.getNumSibs = function (node) {
			var sibs = 0;
			var x = node;

      while (x.previousSibling) {
        x = x.previousSibling;

        // Trim out space txt nodes that some browsers treat differently
        // firefox treats them as nodes, ie skips them
        if  (x.nodeType == 3 && x.wholeText.trim().length == 0) {
          continue;
        }

        // Don't count comment nodes as siblings. They are not counted in other places
        if  (x.nodeType == 8 ) {
          continue;
        }

        // if we got here, its a valid sibling. count it
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
				return { errorMsg: "Please try to select something different and attempt the operation again. [Problem: You cannot create a link when the selection is over different tags.]" };
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

		YAHOO.widget.SimpleEditor.prototype.correctOffsetForSubstitutedText = function(text, offset) {
			// The text that is input here potentially has & < > chars. If it does, then the offset will be off since the string that is eventually
			// returned will contain &amp; &lt; and &gt;. This adds to the offset to compensate.
			// Also, two or more spaces in a row are turned to &nbsp;
			// Also, if we are called with a node that doesn't have data, "text" will be undefined. You would think that the browser would set
			// the offset to zero in this case, but it doesn't.
			if (text === undefined)
				return 0;
			var str = "" + text;
			str = str.substr(0, offset);
			str = str.escapeHTML(str);
			return str.length;
		};

		// Get the user's selection in offsets into the raw HTML.
		// A hash is returned with the start and end positions, and an error string, if any.
		YAHOO.widget.SimpleEditor.prototype.getRawSelectionPosition = function (requireRange) {
			if (this.browser.opera) {
				return null;
			}

			// Use the editor's routine to get the selection. This will be really different between IE 6/7 and other browsers
			var val = null;
			var s = this._getSelection();
			if (this.browser.webkit) {
				if (s+'' === '') {
					s = null;
				}
			} else if (this.browser.ie) {
				// TODO-PER: This isn't right. It will match the first occurrance of the text selected. It's better than nothing, though.
				var rng = s.createRange();
				var selText = rng.htmlText;
				val = this.getEditorHTML();
				var idx = val.indexOf(selText);
				if (idx === -1)
					s.rangeCount = 2;
				else
					return { startPos: idx, endPos: idx + selText.length, selection: selText, errorMsg: null };
			} else {
				if (!s || (s === undefined))
					s = null;
				if (requireRange && (s.toString() === ''))
					s = null;
			}

			if (s === null)
				return { errorMsg: "Nothing is selected." };

			if (s.rangeCount !== 1)
				return { errorMsg: "You cannot create a link when more than one area is selected." };

			// get what we need out of the selection object
			var a = s.anchorNode;
			var aoff = this.correctOffsetForSubstitutedText(a.data, s.anchorOffset);
			var f = s.focusNode;
			var foff = this.correctOffsetForSubstitutedText(f.data, s.focusOffset);
			var selStr = s.toString();

			// In Firefox 3.0.7, at least, we sometimes aren't returned both sides of the selection. If we get at least
			// one side, we have the workaround that we can get the selection's text, and we have either the start
			// or the end of the selection, so we can figure it out (unless there are two repeated strings on either side of
			// the selection, like "abc|abc" where the bar is the selection point.)
			if (a.tagName === 'BODY' && f.tagName === 'BODY') {	// Neither side was returned. We have nothing to work with.
				// Unless the user had clicked the entire area, for instance with ctrl-A.
				if (f.textContent === selStr) {
					var contents = this.getEditorHTML();
					return { startPos: 0, endPos: contents.length, selection: contents, errorMsg: null};
				}
				return { errorMsg: "We're sorry. We can't figure out what you've selected. Try selecting a more than one character." };
			}

			// if we don't have the info in the selection for one side, we make that object null, and compensate below.
			var apos = (a.tagName === 'BODY') ? null : this.getXPathPosition(a);
			var fpos = (f.tagName === 'BODY') ? null : this.getXPathPosition(f);

			// Now parse the raw string to figure out where the xpaths created above (in aoff and foff) fall in the string.
			val = this.getEditorHTML().gsub('&nbsp;', ' ');
			var arr = this.splitHtmlIntoArray(val);

			// Now we go through the raw html, create xpath levels for each node, and
			// keep track of the number of characters consumed so that we can get a
			// character position of where the selection was in relation to the entire
			// raw html string.
			var aOffset = -1;
			var fOffset = -1;

			var arrLevels = [-1];
      var charCount = 0;
      var inComment = false;

      arr.each(function(i) {

        // skip blank entries
        if (i === "" ) {
          return;
        }

        // When in comments, check for end and accumulate txt length
        if ( inComment ) {
          if ( i.endsWith('-->')  ) {
            inComment = false;
          }
          charCount += i.length;
          return;
        }

        // If we find a comment flag it. accumulate len and skip the rest
        if ( i.startsWith('<!--') && i.endsWith('-->') == false ) {
          inComment = true;
          charCount += i.length;
          return;
        }

        // process remaining choices for this line
        if (i === "<br>" || i === "<hr>" || i.startsWith('<meta') || (i.startsWith('<!--') && i.endsWith('-->'))) { // the item is self-contained.
          arrLevels[arrLevels.length-1]++;
        } else if (i.substring(0, 2) === "</") {  // this array item is an end tag.
          arrLevels.pop();
        } else if (i.substring(0, 1) === "<" && i.substring(i.length-3) === "/>") { // the item is self contained
          arrLevels[arrLevels.length-1]++;
        } else if (i.substring(0, 1) === "<") { // this array item is a start tag.
          arrLevels[arrLevels.length-1]++;
          arrLevels.push(-1);
        } else {  // this array item is text. text is considered a node in the dom
          if ( i.trim().length > 0)  {
            arrLevels[arrLevels.length-1]++;
          }
        }

        // See if this one is a match. If so, we can save the accumulated characters used, plus the offset into this element.
        var levelStr = arrLevels.join(',');
        if (apos && apos.join(',') === levelStr) {
          aOffset = charCount + aoff;
        }

        if (fpos && fpos.join(',') === levelStr) {
          fOffset = charCount + foff;
        }

        // if we found an offset we are done. break out
        if ( aOffset > -1 || fOffset > -1) {
          throw $break;
        }

        // lastly, accumulate total position in doc
        charCount += i.length;

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

		YAHOO.widget.SimpleEditor.prototype.filter_safari = function (html) {
            if (this.browser.webkit) {
                //<span class="Apple-tab-span" style="white-space:pre">	</span>
                html = html.replace(/<span class="Apple-tab-span" style="white-space:pre">([^>])<\/span>/gi, '&nbsp;&nbsp;&nbsp;&nbsp;');
                html = html.replace(/Apple-style-span/gi, '');
                html = html.replace(/style="line-height: normal;"/gi, '');
                html = html.replace(/yui-wk-div/gi, '');
                html = html.replace(/yui-wk-p/gi, '');


                //Remove bogus LI's
                html = html.replace(/<li><\/li>/gi, '');
                html = html.replace(/<li> <\/li>/gi, '');
                html = html.replace(/<li>\s+<\/li>/gi, '');

				// HACK-PER: This is needed because the following code is incorrect in YUI 2.8.0. It will strip out the drop cap div, too.
				// We will assume that the drop cap is the most outer div, so we see if it starts with a div, then preserve it.
				var firstDiv = html.startsWith("<div");
				var needToReplace = false;
				var tempText1 = "<DROPCAPDIV>";
				var tempText2 = "</DROPCAPDIV>";
				if (firstDiv) {
					var lastDiv = html.lastIndexOf("</div>");
					if (lastDiv !== -1) {
						html = tempText1 + html.substring(4, lastDiv) + tempText2 + html.substring(lastDiv);
						needToReplace = true;
					}
				} else
					html = html.replace("<div class=\" \">", "");	//In case there was a drop cap, and the user deleted it.

				// The following code may remove
                //Remove bogus DIV's - updated from just removing the div's to replacing /div with a break
                if (this.get('ptags')) {
		            html = html.replace(/<div([^>]*)>/g, '<p$1>');
				    html = html.replace(/<\/div>/gi, '</p>');
                } else {
                    //html = html.replace(/<div>/gi, '<br>');
                    html = html.replace(/<div([^>]*)>([ tnr]*)<\/div>/gi, '<br>');
				    html = html.replace(/<\/div>/gi, '');
                }

				if (needToReplace) {
					html = html.replace(tempText1, "<div");
					html = html.replace(tempText2, "</div>");
				}
            }
            return html;
        };
	};

	// wait until SimpleEditor is created
	var waitForSimpleEditor = function() {
		if (YAHOO.widget.SimpleEditor === undefined)
			setTimeout(waitForSimpleEditor, 100);
		else
			patchSimpleEditor();
	};
	waitForSimpleEditor();
})();

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

var RichTextEditor = Class.create({
	initialize: function (params) {
		this.class_type = 'RichTextEditor';	// for debugging

		// private variables
		var This = this;
		var id = params.id;
		var toolbarGroups = params.toolbarGroups;
		var linkDlgHandler = params.linkDlgHandler;
		var footnote = params.footnote;
		var footnoteCallback = undefined;
		var populate_all = undefined;
		var populate_exhibit_only = undefined;
		var progress_img = undefined;
		if (footnote) {
			footnoteCallback = footnote.callback;
			populate_all = params.populate_all;
			populate_exhibit_only = params.populate_exhibit_only;
			progress_img = footnote.progress_img;
		}
		var bodyStyle = params.bodyStyle ? params.bodyStyle : '';

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
			buttons: [{ type: 'push', label: 'Bold CTRL + SHIFT + B', value: 'bold' },
				{ type: 'push', label: 'Italic CTRL + SHIFT + I', value: 'italic' },
				{ type: 'push', label: 'Underline CTRL + SHIFT + U', value: 'underline' },
				{ type: 'push', label: 'Strike Through', value: 'strikethrough' }]
		};

		var toolgroupFontStyleDropCap = {
			group: 'textstyle', label: 'Font Style',
			buttons: [{ type: 'push', label: 'Bold CTRL + SHIFT + B', value: 'bold' },
				{ type: 'push', label: 'Italic CTRL + SHIFT + I', value: 'italic' },
				{ type: 'push', label: 'Underline CTRL + SHIFT + U', value: 'underline' },
				{ type: 'push', label: 'Strike Through', value: 'strikethrough' },
				{ type: 'push', label: 'First Letter', value: 'firstletter' }]
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
			buttons: [{ type: 'push', label: 'HTML Link CTRL + SHIFT + L', value: 'createlink', disabled: true }]
		};

		var toolgroupLinkFootnote = {
			group: 'insertitem',
			label: 'Insert Item',
			buttons: [{ type: 'push', label: 'HTML Link CTRL + SHIFT + L', value: 'createlink', disabled: true },
				{ type: 'push', label: 'Insert Footnote', value: 'createfootnote' }]
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
						// We want to add the drop_cap class to the outer most div. Unfortunately, there may not be an outermost div.
						// If not, we just add one. If there is, we look for a class attribute. If that exists, add to it, if it doesn't then add the class attribute.
						if (!html.startsWith('<div')) {
							// There isn't an outer div, so just add it.
							html = "<div class='drop_cap'>" + html + "</div>";
						} else {
							// There is an outer div, so add the drop_cap class to it.
							var firstDiv = html.substring(0, html.indexOf('>'));
							var classPos = firstDiv.indexOf('class=');
							if (classPos === -1) {
								// There is no class attribute, so add one.
								html = '<div class="drop_cap" ' + html.substring(4) + '</div>';
							} else {
								// there is a class attribute, so add drop_cap to it
								html = html.substring(0, classPos+7) + 'drop_cap ' + html.substring(classPos+7);
							}
						}

// old way: probably can delete
//						if (!html.include("drop_cap"))
//						{
//							if (!html.startsWith("<p"))
//								html = "<div class='drop_cap'>" + html + "</div>";
//							else
//							{
//								var firstp = html.substring(0, html.indexOf('>'));
//								var classPos = firstp.indexOf('class=');
//								if (classPos === -1)
//									html = "<div class='drop_cap'" + html.substring(2);
//								else
//									html = html.substring(0, classPos+7) + "drop_cap " + html.substring(classPos+7);
//							}
//						}
					}
					else
					{
						// Remove the drop class whereever it appears.
						html = html.gsub("drop_cap", "");
					}
					This.updateContents(html);
//					this.setEditorHTML(html);
		        }, this, true);

		    });
		};

		var initFootnoteDlg = function()
		{
			if (footnote === undefined || footnote === null)
				return;

			var editor = This.editor;

//			var old_correctOffsetForSubstitutedText = function(text, offset) {
//				// The text we get from the RTE has escaped some values, so we need to look for all the & and add to the offset
//				// In other words, if the user sees the string: "one & two" and attempts to insert after the &, the offset will be 5,
//				// but the string we get from the editor is "one &amp; two", so we want to change the selection to 9.
//				var arr = text.split('&');
//				var currPos = 0;
//				var is_first = true;
//				var retValue = null;
//				arr.each(function(frag) {
//					if (retValue === null) {
//						if (is_first) {
//							currPos = frag.length;
//							is_first = false;
//						}
//						else {
//							// Offset by the size of the substitution
//							offset += frag.indexOf(';') + 1;	// increment by the size of the substitution, plus the final ';'
//							currPos += frag.length + 1;
//						}
//						if (offset <= currPos)
//							retValue = offset;	// We really just want to break out of the loop and return offset here, but the each() doesn't let us
//					}
//				});
//				return retValue === null ? offset : retValue;
//			};
//
//			var correctOffsetForSubstitutedText = function(text, offset) {
//				// The text we get from the RTE has escaped some values, so we need to look for all the & and add to the offset
//				// In other words, if the user sees the string: "one & two" and attempts to insert after the &, the offset will be 5,
//				// but the string we get from the editor is "one &amp; two", so we want to change the selection to 9.
//				// check to see if the selection is between & and ;, if so increment it. So search backwards for either a & or ; or the beginning.
//				for (var amp = offset; amp > 0; amp--) {
//					if (text[amp] === '&') {
//						// We found the &, so now find the ; so we know how much to add.
//						for (var semi = offset; semi < text.length; semi++)
//							if (text[semi] === ';')
//								return offset + semi - amp;
//						return offset;	// there was an & but no ;
//					}
//					if (text[amp] === ';') {
//						return offset;
//					}
//				}
//
//
//				var arr = text.split('&');
//				var currPos = 0;
//				var is_first = true;
//				var retValue = null;
//				arr.each(function(frag) {
//					if (retValue === null) {
//						if (is_first) {
//							currPos = frag.length;
//							is_first = false;
//						}
//						else {
//							// Offset by the size of the substitution
//							offset += frag.indexOf(';') + 1;	// increment by the size of the substitution, plus the final ';'
//							currPos += frag.length + 1;
//						}
//						if (offset <= currPos)
//							retValue = offset;	// We really just want to break out of the loop and return offset here, but the each() doesn't let us
//					}
//				});
//				return retValue;
//			};

			editor.on('toolbarLoaded', function() {	// 'this' is now the editor
			    //When the toolbar is loaded, add a listener to the insertimage button
			    editor.toolbar.on('createfootnoteClick', function() {
					var footnoteSelPos = null;
					var setFootnote = function(value) {
						var insertedText = footnoteCallback('add', value);
						var html = editor.getEditorHTML().gsub('&nbsp;', ' ');

						//footnoteSelPos = correctOffsetForSubstitutedText(html, footnoteSelPos);
						html = html.substr(0, footnoteSelPos) + insertedText + html.substr(footnoteSelPos);
						This.updateContents(html);
//						editor.setEditorHTML(html);
						};

					var result = editor.getRawSelectionPosition(false);
					if (!result) {
						new MessageBoxDlg("Error", "IE has not been implemented yet.");
						return false;
					}

					if (result.errorMsg) {
						new MessageBoxDlg("Error", result.errorMsg);
						return false;
					}

					footnoteSelPos = result.endPos;
//						var html = editor.getEditorHTML();
//						var sel1 = old_correctOffsetForSubstitutedText(html, footnoteSelPos);
//						var sel2 = correctOffsetForSubstitutedText(html, footnoteSelPos);
//						var str1 = html.substr(0, footnoteSelPos) + '*' + html.substr(footnoteSelPos);
//						var str2 = html.substr(0, sel1) + '*' + html.substr(sel1);
//						var str3 = html.substr(0, sel2) + '*' + html.substr(sel2);
//						alert("sel: " + footnoteSelPos + ' ' + sel1 + ' ' + sel2 + "\n|" + str1 + '|' + "\n\n|" + str2 + '|' + "\n\n|" + str3 + '|');
//						alert("sel: " + footnoteSelPos + "\n|" + str1 + '|');

					new RteInputDlg({ title: 'Add Footnote', okCallback: setFootnote, value: '', populate_urls: [ populate_exhibit_only, populate_all ], progress_img: progress_img });

					return true;
				}, this, true);

//			    editor.on('beforeEditorClick', function(ev) {
//					// for some reason, Prototype's $ isn't defined here.
//					var target = ev.ev.explicitOriginalTarget;
//					if (target === undefined) {
//						// For safari
//						target = ev.ev.target;
//					}
//					var cls = target.className;
//					if (cls === 'rte_footnote') {
//						hideTooltip();	// Safari doesn't give a mouseout at this point, so we need to force it.
//						var setFootnote = function(value) {
//							var insertedText = footnoteCallback('edit', value);
//							target.innerHTML = insertedText;
//							};
//
//						var deleteFootnote = function(event, params) {
//							params.dlg.cancel();
//							target.parentNode.removeChild(target);
//						};
//
//						var footnote = target.childNodes[0];	// this is the span that hides the footnote
//						new RteInputDlg({ title: 'Edit Footnote', okCallback: setFootnote, value: footnote.innerHTML, populate_nines_obj_url: populate_nines_obj_url, progress_img: progress_img, extraButton: { label: "Delete Footnote", callback: deleteFootnote } });
//
//					}
//					return true;
//				}, this, true);

			}, this, true);

			editor.on('editorContentLoaded', function() {
				This.initializeFootnoteEvents();

			}, this, true);
		};

		this.updateContents = function(html) {
			This.editor.setEditorHTML(html);
			//This.editor._getDoc().body.innerHTML = html;
      //This.editor.nodeChange();
			This.initializeFootnoteEvents();
		};

		this.initializeFootnoteEvents = function() {
			var ifr = $(id + '_editor');
			var doc = ifr.contentDocument;
			if (doc === undefined || doc === null)
				doc = ifr.contentWindow.document;
			var footnotes = [];
			var iterateChild = function(node) {
				$A(node.childNodes).each(function(child) {
					if (child.nodeName === 'A' && child.className.indexOf('rte_footnote') >= 0)
						footnotes.push(child);
					if (child.childNodes.length > 0)
						iterateChild(child);
				});
			};
			$A(doc.childNodes).each(function(child) {
				iterateChild(child);
			});

			var currTooltip = null;
			var hideTooltip = function() {
				if (currTooltip) {
					currTooltip.remove();
					currTooltip = null;
				}
			};

			var getX = function( oElement )
			{
				var iReturnValue = 0;
				while( oElement !== null ) {
					iReturnValue += oElement.offsetLeft;
					oElement = oElement.offsetParent;
				}
				return iReturnValue;
			};

			var getY = function( oElement )
			{
				var iReturnValue = 0;
				while( oElement !== null ) {
					iReturnValue += oElement.offsetTop;
					oElement = oElement.offsetParent;
				}
				return iReturnValue;
			};

			var showTooltip = function(ev) {
				var target = ev.target;
				if (target === undefined)	// Hack for IE
					target = this;
				$A(target.childNodes).each(function(child) {
					if (child.className.indexOf('tip') >= 0) {
						//var p = document.parentNode;
						var parent = $('gd_modal_dlg_parent');
						var x = getX(target) + getX(ifr.offsetParent) + 20;
						var y = getY(target) + getY(ifr.offsetParent) + 20;
						currTooltip =new Element('div', { style: 'z-index:500; border-radius: 3px; position: absolute; top:' + y + 'px; left:' + x + 'px; width:20em; border:1px solid #888; background-color: whitesmoke; color:#000; text-align: left; font-weight: normal; padding: .3em;'}).update(child.innerHTML);
						parent.appendChild(currTooltip);
					}
				});
			};

			var editTooltip = function(ev) {
				var target = ev.target;
				if (target === undefined)	// Hack for IE
					target = this;

				hideTooltip();	// Safari doesn't give a mouseout at this point, so we need to force it.
				var setFootnote = function(value) {
					var insertedText = footnoteCallback('edit', value);
					target.innerHTML = insertedText;
					};

				var deleteFootnote = function(event, params) {
					params.dlg.cancel();
					target.parentNode.removeChild(target);
				};

				var footnote = target.childNodes[0];	// this is the span that hides the footnote
				new RteInputDlg({ title: 'Edit Footnote', okCallback: setFootnote, value: footnote.innerHTML, populate_urls: [ populate_exhibit_only, populate_all ], progress_img: progress_img, extraButton: { label: "Delete Footnote", callback: deleteFootnote } });
			};

			footnotes.each(function(foot) {
				YAHOO.util.Event.addListener(foot, 'mouseover', showTooltip, null);
				YAHOO.util.Event.addListener(foot, 'mouseout', hideTooltip, null);
				YAHOO.util.Event.addListener(foot, 'click', editTooltip, null);
			});
		};

		var initLinkDlg = function()
		{
			if (linkDlgHandler === undefined || linkDlgHandler === null)
				return;

			var editor = This.editor;

//			editor.on('beforeEditorMouseDown', function(ev) {
//				var ctrl = ev.ev.ctrlKey;
//				var btn = ev.ev.button;
//				if (ctrl && btn === 0)
//					return false;
//				if (btn === 2)
//					return false;
//				return true;
//			}, this, true);

//		var oContextMenu = new YAHOO.widget.ContextMenu('contextMenu', {trigger: 'note_toolbar'});
//		oContextMenu.subscribe("beforeShow", function() {} );

			editor.on('editorKeyDown', function(ev) {
				var cleanPasted = function(pasted) {
					pasted = pasted.gsub("<br>", "\x02").gsub("<br/>", "\x02").gsub("<br />", "\x02");
					pasted = pasted.gsub(/<a(.*?)href="(.*?)"(.*?)>(.*?)<\/a>/, "\x03#{2}\x04#{4}\x05");
					pasted = pasted.gsub(/<span (.*?)class="ext_linklike" real_link="(.*?)"(.*?)>(.*?)<\/span>/, "\x03#{2}\x04#{4}\x05");
					pasted = pasted.gsub(/<span (.*?)class="nines_linklike" real_link="(.*?)"(.*?)>(.*?)<\/span>/, "\x06#{2}\x07#{4}\x08");
					pasted = pasted.gsub(/<span (.*?)real_link="(.*?)" class="ext_linklike"(.*?)>(.*?)<\/span>/, "\x03#{2}\x04#{4}\x05");
					pasted = pasted.gsub(/<span (.*?)real_link="(.*?)" class="nines_linklike"(.*?)>(.*?)<\/span>/, "\x06#{2}\x07#{4}\x08");
					pasted = pasted.stripTags().stripScripts().gsub('&nbsp;', '').escapeHTML();
					pasted = pasted.gsub("\x02", "<br/>");
					pasted = pasted.gsub(/\x03(.*?)\x04(.*?)\x05/, "<span class=\"ext_linklike\" real_link=\"#{1}\" title=\"External Link: #{1}\">#{2}</span>");
					pasted = pasted.gsub(/\x06(.*?)\x07(.*?)\x08/, "<span class=\"nines_linklike\" real_link=\"#{1}\" title=\"NINES Link: #{1}\">#{2}</span>");
					// links can come in three forms. If they are pasted from a web page, they will have the <a> tag. If they are pasted from the exhibit builder,
					// they will be one of two <span> types.
					// <a ... href="HREF" ...>DISPLAY</a>
					// <span class="ext_linklike" real_link="HREF" title="External Link: HREF">DISPLAY</span>
					// <span class="nines_linklike" real_link="HREF" title="NINES Object: HREF">DISPLAY</span>
					return pasted + ' ';
				};
				var ctrl = ev.ev.ctrlKey;
				var meta = ev.ev.metaKey;
				var key = ev.ev.keyCode;
				if (key === 86 && (ctrl || meta)) {
					var sel = editor.getRawSelectionPosition(false);
					var tempContents = editor.getEditorHTML();
					if (sel.errorMsg === undefined) {
						var startText = tempContents.substring(0, sel.startPos);
						var endText = tempContents.substring(sel.endPos);
						setTimeout(function(){
							var contents = editor.getEditorHTML();
							var pasted = cleanPasted(contents.substring(sel.startPos, contents.length-endText.length));
							This.updateContents(startText + pasted + endText);
						}, 10);
					} else {
						// The selection wasn't retrievable, so we have to compare the two strings to find the first difference and the last difference.
						setTimeout(function(){
							var contents = editor.getEditorHTML();
							var tagStart = null;
							for (var startPos = 0; startPos < tempContents.length; startPos++) {
								// We don't want to split tags, though, so keep track of whether we are in a tag and back up if so.
								if (tempContents[startPos] !== contents[startPos]) break;
								if (tempContents[startPos] === '<') tagStart = startPos;
								if (tempContents[startPos] === '>') tagStart = null;
							}
							if (tagStart !== null)
								startPos = tagStart;
							var oldEnd = tempContents.length-1;
							var newEnd = contents.length-1;
							while (1) {
								if (oldEnd < 0 || newEnd < 0) break;
								if (tempContents[oldEnd] !== contents[newEnd]) break;
								oldEnd--;
								newEnd--;
							}
							// If there is an open tag, we want to grab a few more chars until the close tag.
							var i = newEnd;
							while (i > 0 && contents[i] !== '>') {
								if (contents[i] === '<') {
									while (newEnd < contents.length && contents[newEnd] !== '>')
										newEnd++;
									break;
								}
								i--;
							}
							newEnd++;	// this is now set the first character that doesn't match, add one to put it at the last char that does.
							var startText = contents.substring(0, startPos);
							var pasted = cleanPasted(contents.substring(startPos, newEnd));
							var endText = contents.substring(newEnd);
							This.updateContents(startText + pasted + endText);
						}, 10);
					}
				}
				return true;
			}, this, true);

			editor.on('toolbarLoaded', function() {
			    //When the toolbar is loaded, add a listener to the insertimage button
			    editor.toolbar.on('createlinkClick', function() {

					// Get the selection object. Unfortunately, what is returned varies widely between browsers.
					var result = editor.getRawSelectionPosition(true);
					if (!result) {
						new MessageBoxDlg("Error", "IE has not been implemented yet.");
						//this.formatSelection();
						return false;
					}

					if (result.errorMsg) {
						new MessageBoxDlg("Error", result.errorMsg);
						return false;
					}

					linkDlgHandler.show(This, editor.getEditorHTML(), result.startPos, result.endPos);

		            //This is important.. Return false here to not fire the rest of the listeners
		            return false;
			    }, this, true);
			}, this, true);
		};

//		var setResize = function(id)
//		{
//			var editor = This.editor;
//
//			editor.on('editorContentLoaded', function() {
//				var resize = new YAHOO.util.Resize(editor.get('element_cont').get('element'), {
//				    handles: ['b', 'r', 'br'],
//				    autoRatio: true,
//				    status: false,
//				    proxy: true,
//				    setSize: false //This is where the magic happens
//				});
//				resize.on('startResize', function() {
//				    this.hide();
//				    this.set('disabled', true);
//				}, editor, true);
//				resize.on('resize', function(args) {
//				    var h = args.height;
//				    var th = (this.toolbar.get('element').clientHeight + 2); //It has a 1px border..
//				    var dh = 0; //(this.dompath.clientHeight + 1); //It has a 1px top border..
//				    var newH = (h - th - dh);
//				    this.set('width', args.width + 'px');
//				    this.set('height', newH + 'px');
//				    this.set('disabled', false);
//				    this.show();
//				}, editor, true);
//			});
//		};

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
				case 'link&footnote':
					toolbar.buttons.push(toolgroupLinkFootnote);
					break;
			}
		});

		//create the RTE:
		var width = params.width !== null ? params.width : 702;
		//var hoverCss = ".superscript { position: relative; bottom: 0.5em; color: #AC2E20; font-size: 0.8em; font-weight: bold; text-decoration: none;} .rte_footnote { background: url(/images/rte_footnote.jpg) top right no-repeat; padding-right: 9px; } a.rte_footnote{ position:relative; } a.rte_footnote:hover { z-index:25; } a.rte_footnote span { display: none; } a.rte_footnote:hover span.tip { display: block; position:absolute; top:1em; left:.2em; width:20em; border:1px solid #914C29; background-color: #F7ECDB; color:#000; text-align: left; font-weight: normal; padding: .3em; }";
		var hoverCss = " a.rte_footnote { background: url(/assets/rte_footnote.jpg) top right no-repeat; padding-right: 9px; cursor: pointer !important; } a.rte_footnote span { display: none; }";
		/*hoverCss += '  a.rte_footnote:hover span.tip { display: block; position:absolute;'
    hoverCss += '  top:1em;'
    hoverCss += '  left:.2em;'
    hoverCss += '  width:10em;'
    hoverCss += '  border:1px solid #914C29;'
    hoverCss += '  background-color: #F7ECDB;'
    hoverCss += '  color:#FF0000;'
    hoverCss += '  text-align: left;'
    hoverCss += '  font-weight: normal;'
    hoverCss += '  padding: .3em; }';*/
		var linkCss = ' a:link { color: #A60000 !important; text-decoration: none !important; } a:visited { color: #A60000 !important; text-decoration: none !important; } a:hover { color: #A60000 !important; text-decoration: none !important; } .nines_linklike { color: #A60000; background: url(../assets/nines/nines_link.jpg) center right no-repeat; padding-right: 13px; } .ext_linklike { color: #A60000; background: url(../assets/external_link.jpg) center right no-repeat; padding-right: 13px; }';
		var firstLetterCss = ' .drop_cap:first-letter {	color:#999999;	float:left;	font-family:"Bell MT","Old English",Georgia,Times,serif;	font-size:420%;	line-height:0.85em;	margin-bottom:-0.15em;	margin-right:0.08em;} .drop_cap p:first-letter {	color:#999999;	float:left;	font-family:"Bell MT","Old English",Georgia,Times,serif;	font-size:420%;	line-height:0.85em;	margin-bottom:-0.15em;	margin-right:0.08em;} ';

		this.editor = new YAHOO.widget.SimpleEditor(id, {
			  width: width + 'px',
				height: '200px',
				// TODO-PER: Can the CSS be read from a file, so it doesn't have to be repeated here? (Check out YUI Loader Utility)
				css: YAHOO.widget.SimpleEditor.prototype._defaultCSS + ' ' + bodyStyle + hoverCss + linkCss + firstLetterCss,
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
		initFootnoteDlg();

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
