// ------------------------------------------------------------------------
//     Copyright 2009 Applied Research in Patacriticism and the University of Virginia
// 
//     Licensed under the Apache License, Version 2.0 (the "License");
//     you may not use this file except in compliance with the License.
//     You may obtain a copy of the License at
// 
//         http://www.apache.org/licenses/LICENSE-2.0
// 
//     Unless required by applicable law or agreed to in writing, software
//     distributed under the License is distributed on an "AS IS" BASIS,
//     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//     See the License for the specific language governing permissions and
//     limitations under the License.
// ----------------------------------------------------------------------------

/*global RteInputDlg */
/*global $, $$, Element, Class */
/*global YAHOO */
/*extern FootnoteAbbrev, FootnotesInRte */

var FootnoteAbbrev = Class.create({
	initialize: function(params){
		var footnoteStr = params.startingValue;
		var field = params.field;
		var populate_all = params.populate_all;
		var populate_exhibit_only = params.populate_exhibit_only;
		var progress_img = params.progress_img;

		var klassEdit = null;

		var makeButton = function(id, text, hide, klass) {
			//<a id="illustration_dlg_a4" class="footnote_button" title="Add/Edit Footnote" onclick="return false;" href="#"/>
			var a = new Element('a', {id: field + '_' + id, title: text, onclick: 'return false;', href: '#'});
			a.addClassName(klass);
			if (hide)
				a.addClassName("hidden");
			return a;

//			var btn1 = new Element('span', { id: field + '_' + id });
//			var btn2 = new Element('span');
//			var btn3 = new Element('button', { type: 'button', tabindex: '0', id: field + '_' + id + '-button' }).update(text);
//			btn1.appendChild(btn2);
//			btn2.appendChild(btn3);
//			btn1.addClassName("yui-button yui-push-button");
//			if (hide)
//				btn1.addClassName("hidden");
//			btn2.addClassName("first-child");
//			return btn1;
		};

//		var makeFootnoteAbbrev = function(footnote) {
//			var str = footnote.stripTags();
//			if (str.length > 20)
//				str = str.substring(0, 20) + "...";
//			return str;
//		};

		var setFootnoteCtrl = function() {
			if (footnoteStr.length > 0) {
				$(field + '_add').addClassName('hidden');
				$(field + '_edit').removeClassName('hidden');
				$(field + '_remove').removeClassName('hidden');
				var a = $$('.' + klassEdit)[0];
				a.removeClassName('hidden');
				a.down('.tip').innerHTML = footnoteStr.stripTags();
				//$(field).removeClassName('hidden');
			} else {
				$(field + '_add').removeClassName('hidden');
				$(field + '_edit').addClassName('hidden');
				$(field + '_remove').addClassName('hidden');
				$$('.' + klassEdit)[0].addClassName('hidden');
				//$(field).addClassName('hidden');
			}
		};

		var setFootnote = function(value) {
			footnoteStr = value;
			//$(field).innerHTML = makeFootnoteAbbrev(footnoteStr);
			setFootnoteCtrl();
		};

		var addFootnote = function(event, params) {
			new RteInputDlg({title: 'Add Footnote', okCallback: setFootnote, value: footnoteStr, populate_urls: [ populate_exhibit_only, populate_all ], progress_img: progress_img});
			return false;
		};

		var editFootnote = function(event, params) {
			new RteInputDlg({title: 'Edit Footnote', okCallback: setFootnote, value: footnoteStr, populate_urls: [ populate_exhibit_only, populate_all ], progress_img: progress_img});
			return false;
		};

		var fnDeleteCallback = null;
		this.deleteCallback = function(fn) {
			fnDeleteCallback = fn;
		};

		var deleteFootnote = function(event, params) {
			footnoteStr = "";
			//$(field).innerHTML = makeFootnoteAbbrev(footnoteStr);
			setFootnoteCtrl();
			if (fnDeleteCallback)
				fnDeleteCallback(field);
			return false;
		};

		this.getMarkup = function() {
			var parent = new Element("div");
			parent.addClassName('footnote_abbrev_div');
			parent.appendChild(makeButton('add', 'Add Footnote', footnoteStr.length > 0, 'footnote_button'));
			parent.appendChild(makeButton('edit', 'Edit Footnote', footnoteStr.length === 0, 'footnote_button'));
			parent.appendChild(makeButton('remove', 'Delete Footnote', footnoteStr.length === 0, 'footnote_delete_button'));
//			var span = new Element('span', { id: field} ).update(makeFootnoteAbbrev(footnoteStr));
//			span.addClassName('footnote_abbrev');
//			parent.appendChild(span);
			return parent;
		};

		this.getSelection = function() {
			return {field: field, value: footnoteStr};
		};

		this.delayedSetup = function() {
			YAHOO.util.Event.addListener(field + '_' + 'add', 'click', addFootnote, null);
			YAHOO.util.Event.addListener(field + '_' + 'edit', 'click', editFootnote, null);
			YAHOO.util.Event.addListener(field + '_' + 'remove', 'click', deleteFootnote, null);
		};

		this.createEditButton = function(klass) {
			klassEdit = klass;
			if (footnoteStr.length > 0)
				return {link: "*<span class='tip'>" + footnoteStr.stripTags() + "</span>", klass: klass + ' footnote_tip', callback: editFootnote};
			else
				return {link: "*<span class='tip'></span>", klass: klass + ' footnote_tip hidden', callback: editFootnote};
		};
	}
});


//var addFootnoteDeleteCallback = function(dlg, footnoteDivs) {
//	var footnoteDeleteCallback = function(index) {
//		var id = "footnote_index_" + index;
//		var editor = dlg.getEditor(0);
//		var html = editor.editor.getEditorHTML();
//		var left = html.indexOf('<span id="'+id);
//		var mid = html.substr(left);
//		var right = mid.indexOf('</span>');
//		html = html.substr(0, left) + mid.substr(right+7);
//		editor.editor.setEditorHTML(html);
//
//	};
//	footnoteDivs.setFootnoteDeleteCallback(footnoteDeleteCallback);
//};


var FootnotesInRte = Class.create({
	initialize: function(){
		//var footnotes = [];

		var footnotePrefix = '<a href="#" onclick=\'return false; var footnote = $(this).next(); new MessageBoxDlg("Footnote", footnote.innerHTML); return false;\' class="superscript">';
		var footnotePrefixSafari = '<a href="#" onclick=\'return false; var footnote = $(this).next(); new MessageBoxDlg("Footnote", footnote.innerHTML); return false;\' class="superscript">';
		var footnotePrefixIE = '<A class=superscript onclick=\'return false; var footnote = $(this).next(); new MessageBoxDlg("Footnote", footnote.innerHTML); return false;\' href="#">';
		var footnoteMid = '</a><span class="hidden">';
		var footnoteMidIE = '</A><SPAN class=hidden>';
		var footnotePrefixAlt = '<a href="#" onclick="return false; var footnote = $(this).next(); new MessageBoxDlg(&quot;Footnote&quot;, footnote.innerHTML); return false;" class="superscript">';
		var footnoteClose = '</span>';

		var rteFootnotePrefix1 = '<a class="rte_footnote">';
		var rteFootnotePrefix2 = '<span>';
		var rteFootnoteMid = '</span><span class="tip"><span class="footnote_edit_hover">Click this footnote to edit</span>';
		var rteFootnoteClose1 = '</a>';
		var rteFootnoteClose2 = '</span>';

		var formatFootnoteForRteInner = function(str) {
			return rteFootnotePrefix2 + str + rteFootnoteMid + str.stripTags().truncate(40) + rteFootnoteClose2;
		};

		var formatFootnoteForRte = function(str) {
			return rteFootnotePrefix1 + formatFootnoteForRteInner(str) + rteFootnoteClose1;
		};

		var extractUpToMatchingSpan = function(text) {
			// this takes a string and returns the first part of it up to the </span>. This takes into account extra <span>...</span> pairs that are embedded.
			var arr = text.split('<');
			var left = "";
			var level = 0;
			for (var i = 0; i < arr.length; i++) {
				if (arr[i].startsWith('span') || arr[i].startsWith('SPAN')) {
					level++;
					left += '<' + arr[i];
				} else if (arr[i].startsWith('/span') || arr[i].startsWith('/SPAN')) {
					level--;
					if (level !== -1)
						left += '<' + arr[i];
					else
						break;
				} else {
					left += '<' + arr[i];
				}
			}
			left = left.substr(1);	// because we are placing '<' at the beginning of each concatination, we'll have an extra one at the beginning.

			var right = arr[i].substr(6);	// this is all the stuff after "/span>"
			for (var j = i+1; j < arr.length; j++) {
				right += '<' + arr[j];
			}
			
			return {left: left, right: right};
		};

		this.preprocessFootnotes = function(text) {
			// Preprocess the text to pull out the footnotes.
			// We will get something in the form: ...<a href="#" onclick='return false; var footnote = $(this).next(); new MessageBoxDlg("Footnote", footnote.innerHTML); return false;' class="superscript">%NUMBER%</a><span class="hidden">%FOOTNOTE%</span>...
			// We want to change it to:
			//	<a class="rte_footnote">
			//		<span>footnote</span>
			//		<span class="tip">tooltip</span>
			//	</a>
			// and extract the footnote to put in an array of strings.
			var arr = text.split(footnotePrefix);
			if (arr.length === 1)	// Hack for Safari: it preprocesses the string so we need to test for that, also.
				arr = text.split(footnotePrefixSafari);
			if (arr.length === 1)	// Hack for IE: It returns tags with capital letters
				arr = text.split(footnotePrefixIE);
			if (arr.length === 1)	// Hack: Try single quotes, too. Not sure why the format changed upstream.
				arr = text.split(footnotePrefixAlt);
			text = arr[0];
			for (var i = 1; i < arr.length; i++) {
				// each element starts with a number, which we don't need, and then has footnoteMid, then the footnote, then footnoteClose, then random text that we want to keep.
				var arr2 = arr[i].split(footnoteMid);
				if (arr2.length === 1)	// Hack for IE: It returns tags with capital letters
					arr2 = arr[i].split(footnoteMidIE);
				var parts = extractUpToMatchingSpan(arr2[1]);
				var footnote = parts.left;
				var restOfLine = parts.right;

				text += formatFootnoteForRte(footnote) + restOfLine;

		//		text += '<span id="footnote_index_' + i + '" class="superscript">@' + restOfLine;
			}
			return text;
		};

		this.postprocessFootnotes = function(text) {
			// Change the RTE's visual format for footnotes back into the format that is expected in the database.
			var arr = text.split(rteFootnotePrefix1+rteFootnotePrefix2);
			text = arr[0];
			for (var i = 1; i < arr.length; i++) {
				// each element of the arr now contains the footnote, then </span><span class="tip">tooltip</span></a>more text.
				var arr2 = arr[i].split("</span><span class=\"tip\">");
				var footnote = arr2[0];
				// arr2[1] now contains the tooltip, then </a>, then possibly some unrelated text that we need to carry along.
				var aIndex = arr2[1].indexOf("</a>") + 4;
				var more = arr2[1].substr(aIndex);
				text += footnotePrefix + '@' + footnoteMid + footnote + footnoteClose + more;
			}
			return text;
		};

//		var footnoteDeleteCallback = null;
//		this.setFootnoteDeleteCallback = function(fn) {
//			footnoteDeleteCallback = fn;
//		};
//
//		var deleteCallback = function(footnote_field) {
//			var arr = footnote_field.split('_');
//			var index = parseInt(arr[arr.length-1]);
//			var el = $(footnote_field).up();
//			el.hide();
//			footnotes[index] = null;
//			if (footnoteDeleteCallback)
//				footnoteDeleteCallback(index);
//		};

//		var parent = new Element("div");
//		var isInitializing = true;

		this.addFootnote = function(ty, str) {
			if (str.length === 0)	// let the user create blank footnotes if they want, but change it to a space so that there is actually a footnote there.
				str = " ";

			if (ty === 'add') {
				return formatFootnoteForRte(str);
//				var newFoot = new FootnoteAbbrev(str, field+'_'+(footnotes.length+1));
//				footnotes.push(newFoot);
//				parent.appendChild(newFoot.getMarkup());
//				if (!isInitializing)
//					newFoot.delayedSetup();
//				newFoot.deleteCallback(deleteCallback);
//				return footnotes.length;
			} else if (ty === 'edit') {
				return formatFootnoteForRteInner(str);
//				var setFootnote = function(value) {
//					alert("new footnote value would be: " + value);
//				};
//				var populate_nines_obj_url = '/forum/get_nines_obj_list';	// TODO-PER: pass this in
//				var progress_img = '/images/ajax_loader.gif';	// TODO-PER: pass this in
//				new RteInputDlg({ title: 'Edit Footnote', okCallback: setFootnote, value: str, populate_nines_obj_url: populate_nines_obj_url, progress_img: progress_img });
			}
			return "";
		};

//		footnoteStrs.each(function(str){
//			this.addFootnote(str);
//		}, this);
//		isInitializing = false;

//		this.getMarkup = function() {
////			footnotes.each(function(f){
////				parent.appendChild(f.getMarkup());
////			});
//			return parent;
//		};
//
//		this.getSelection = function() {
//			var value = [];
//			footnotes.each(function(f){
//				if (f) {
//					value.push(f.getSelection());
//				}
//			});
//			return { field: field, value: value.toJSON() };
//		};
//
//		this.delayedSetup = function() {
//			footnotes.each(function(f){
//				f.delayedSetup();
//			});
//		};
	}
});

