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
/*global $, Element, Class */
/*global YAHOO */
/*extern FootnoteAbbrev */

var FootnoteAbbrev = Class.create({
	initialize: function(footnoteStr, field){

		var makeButton = function(id, text, hide) {
			var btn1 = new Element('span', { id: field + '_' + id });
			var btn2 = new Element('span');
			var btn3 = new Element('button', { type: 'button', tabindex: '0', id: field + '_' + id + '-button' }).update(text);
			btn1.appendChild(btn2);
			btn2.appendChild(btn3);
			btn1.addClassName("yui-button yui-push-button");
			if (hide)
				btn1.addClassName("hidden");
			btn2.addClassName("first-child");
			return btn1;
		};

		var makeFootnoteAbbrev = function(footnote) {
			var str = footnote.stripTags();
			if (str.length > 20)
				str = str.substring(0, 20) + "...";
			return str;
		};

		var setFootnoteCtrl = function() {
			if (footnoteStr.length > 0) {
				$(field + '_add').addClassName('hidden');
				$(field + '_edit').removeClassName('hidden');
				$(field + '_remove').removeClassName('hidden');
				$(field).removeClassName('hidden');
			} else {
				$(field + '_add').removeClassName('hidden');
				$(field + '_edit').addClassName('hidden');
				$(field + '_remove').addClassName('hidden');
				$(field).addClassName('hidden');
			}
		};

		var setFootnote = function(value) {
			footnoteStr = value;
			$(field).innerHTML = makeFootnoteAbbrev(footnoteStr);
			setFootnoteCtrl();
		};

		var populate_nines_obj_url = '/forum/get_nines_obj_list';	// TODO-PER: pass this in
		var progress_img = '/images/ajax_loader.gif';	// TODO-PER: pass this in
		var addFootnote = function(event, params) {
			new RteInputDlg({ title: 'Add Footnote', okCallback: setFootnote, value: footnoteStr, populate_nines_obj_url: populate_nines_obj_url, progress_img: progress_img });
		};

		var editFootnote = function(event, params) {
			new RteInputDlg({ title: 'Edit Footnote', okCallback: setFootnote, value: footnoteStr, populate_nines_obj_url: populate_nines_obj_url, progress_img: progress_img });
		};

		var fnDeleteCallback = null;
		this.deleteCallback = function(fn) {
			fnDeleteCallback = fn;
		};

		var deleteFootnote = function(event, params) {
			footnoteStr = "";
			$(field).innerHTML = makeFootnoteAbbrev(footnoteStr);
			setFootnoteCtrl();
			if (fnDeleteCallback)
				fnDeleteCallback(field);
		};

		this.getMarkup = function() {
			var parent = new Element("div");
			parent.addClassName('footnote_abbrev_div');
			parent.appendChild(makeButton('add', 'Add Footnote', footnoteStr.length > 0));
			parent.appendChild(makeButton('edit', 'Edit Footnote', footnoteStr.length === 0));
			parent.appendChild(makeButton('remove', 'X', footnoteStr.length === 0));
			var span = new Element('span', { id: field} ).update(makeFootnoteAbbrev(footnoteStr));
			span.addClassName('footnote_abbrev');
			parent.appendChild(span);
			return parent;
		};

		this.getSelection = function() {
			return { field: field, value: footnoteStr };
		};

		this.delayedSetup = function() {
			YAHOO.util.Event.addListener(field + '_' + 'add', 'click', addFootnote, null);
			YAHOO.util.Event.addListener(field + '_' + 'edit', 'click', editFootnote, null);
			YAHOO.util.Event.addListener(field + '_' + 'remove', 'click', deleteFootnote, null);
		};
	}
});

var FootnoteAbbrevArray = Class.create({
	initialize: function(footnoteStrs, field){
		var footnotes = [];

		var footnoteDeleteCallback = null;
		this.setFootnoteDeleteCallback = function(fn) {
			footnoteDeleteCallback = fn;
		};

		var deleteCallback = function(footnote_field) {
			var arr = footnote_field.split('_');
			var index = parseInt(arr[arr.length-1]);
			var el = $(footnote_field).up();
			el.hide();
			footnotes[index] = null;
			if (footnoteDeleteCallback)
				footnoteDeleteCallback(index);
		};

		var parent = new Element("div");
		footnoteStrs.each(function(str){
			footnotes.push(new FootnoteAbbrev(str, field+'_'+(footnotes.length+1)));
			footnotes[footnotes.length-1].deleteCallback(deleteCallback);
		});

		this.getMarkup = function() {
			footnotes.each(function(f){
				parent.appendChild(f.getMarkup());
			});
			return parent;
		};

		this.getSelection = function() {
			var value = [];
			footnotes.each(function(f){
				if (f) {
					value.push(f.getSelection());
				}
			});
			return { field: field, value: value.toJSON() };
		};

		this.delayedSetup = function() {
			footnotes.each(function(f){
				f.delayedSetup();
			});
		};

		this.addFootnote = function(str) {
			var newFoot = new FootnoteAbbrev(str, field+'_'+(footnotes.length+1));
			footnotes.push(newFoot);
			parent.appendChild(newFoot.getMarkup());
			newFoot.delayedSetup();
			newFoot.deleteCallback(deleteCallback);
			return footnotes.length;
		};
	}
});

