// line.js
//
// This class contains no state itself, but serves to manipulate the array of TW.lines, both accessing it and modifying it.
// There should be no other access to the "TW.lines" variable outside this file.
//
// Requires a global variable 'TW.lines' to contain an array of all the line data. See typewright/documents/edit.html.erb for details on the structure.
// There are functions in this file that modify the TW.lines array. These are the modifications:
// 1) A new line can be inserted anywhere in the array.
// 2) A new element can be attached to a line. This is named "change" and is a hash of:
// { type: 'change' / 'correct' / 'delete'
//   text: new text,
//   words: word array;
// 3) A new element can be attached to a line. This is named "undo" and is a copy of the "change" element.
// 4) l, r, t, b can be modified, and the element .box_size = 'changed'

/*global TW */

jQuery(document).ready(function() {
	"use strict";
	TW.line = {
		//
		// TW.lines array routines
		//
		findLine: function(x, y) {
			// The input coordinates are the original scale
			for (var i = 0; i < TW.lines.length; i++) {
				var bx = TW.lines[i].l <= x;
				var bw = x <= TW.lines[i].r;
				var by = TW.lines[i].t <= y;
				var bh = y <= TW.lines[i].b;
				if (bx && bw && by && bh)
					return i;
			}
			return -1;
		},

		doInsert: function(num) {
			var before = num > 0 ? TW.lines[num - 1].num : 0;
			var after = (num < TW.lines.length) ? TW.lines[num].num : before + 1;
			// Figure out an approximate place to put the box. It should be horizontally all the way across, and start just
			// after the last item and end just before the next item.
			var t = (num > 0) ? parseInt(TW.lines[num - 1].b) + 1 : 1;
			var r = 1000;
			var b = (num < TW.lines.length) ? parseInt(TW.lines[num].t) : t + 30;
			var l = 1;
			if (b - t > 30) { // don't allow the box to get too tall, so limit it to the center of a large region.
				var mid = t + (b - t) / 2;
				t = mid - 15;
				b = mid + 15;
			}
			var newLine = before + (after - before) / 2;
			// TODO-PER: src should be set to the same thing as the lines around it, shouldn't it? Also, couldn't src be global -- it shouldn't change for each line?
			TW.lines.splice(num, 0, { src: "gale", l: l, t: t, r: r, b: b, words: [
				[ ]
			], text: [''], num: newLine, change: { type: 'insert', text: '', words: [] }, box_size: 'changed' });
		},

		isLast: function(num) { return num === TW.lines.length - 1; },
		isInRange: function(num) { return num >= 0 && num < TW.lines.length; },

		//
		// const routines
		//
		canUndo: function(num) { return TW.lines[num].change !== undefined; },
		canRedo: function(num) { return TW.lines[num].undo !== undefined; },
		hasChanged: function(num) { return (TW.lines[num].change && TW.lines[num].change.type === 'change') || (TW.lines[num].box_size === 'changed'); },
		getLastAction: function(num) {
			if (!TW.lines[num].actions)
				return null;
			return TW.lines[num].actions[TW.lines[num].actions.length-1];
		},
		getChangeType: function(num) {
			if (TW.lines[num].change)
				return TW.lines[num].change.type;
			if (TW.line.getLastAction(num) === 'delete')
				return 'delete';
			return null;
		},
		isJustDeleted: function(num) { return TW.lines[num].change && TW.lines[num].change.type === 'delete'; },
		isDeleted: function(num) {
			if (TW.line.isJustDeleted(num))
				return true;
			return TW.line.getLastAction(num) === 'delete';
		},
		getLineNum: function(num) { return TW.lines[num].num; },
//		getTextHistory: function(num) { return TW.lines[num].text.join("<br />"); },
		getStartingText: function(num) { return TW.lines[num].text[TW.lines[num].text.length - 1]; },
		getRect: function(num) { return { l: TW.lines[num].l, r: TW.lines[num].r, t: TW.lines[num].t, b: TW.lines[num].b }; },

		getCurrentText: function(num) {
			var ret;
			if (TW.lines[num].change && TW.lines[num].change.type === 'change')
				ret = TW.lines[num].change.text;
			else if (TW.line.isDeleted(num))
				ret = TW.lines[num].text[0];	// When an item is deleted, we want to show the original text crossed out.
			else
				ret = TW.lines[num].text[TW.lines[num].text.length - 1];
			if (ret === null || ret === undefined) ret = "";
			return ret;
		},

//		getCurrentWords: function(num) {
//			if (!this.isInRange(num))
//				return null;
//			if (TW.lines[num].change && TW.lines[num].change.type === 'change')
//				return TW.lines[num].change.words;
//			return TW.lines[num].words[TW.lines[num].words.length - 1];
//		},

		getAllHistory: function(num) {
			var line = TW.lines[num];
			if (line.text.length > 1) {
				var str = "<table><td class='tw_header'>Correction:</td><td td class='tw_header'>Editor:</td><td td class='tw_header'>Date:</td>";
				for (var i = 0; i < line.text.length; i++) {
					var text;
					switch (line.actions[i]) {
						case 'delete':
							text = '-- Deleted --';
							break;
						case 'correct':
							text = '-- Declared Correct --';
							break;
						case 'change':
							text = line.text[i];
							break;
						case 'insert':
							text = line.text[i];
							break;
						case 'original':
							text = line.text[i];
							break;
						case '':
							text = line.text[i];
							break;
						default:
							text = line.actions[i];
							break;
					}
					str += "<tr><td>" + text + "</td><td>" + line.authors[i] + "</td><td>" + line.dates[i] + "</td></tr>";
				}
				str += "</table>";
				return str;
			}
			return null;
		},

		//
		// modifying routines
		//
		doRegisterLineChange: function(num, newText) {
			// sets the line if there is something to set, and returns true if a change was made.
			var lastTextLocation = TW.lines[num].text.length - 1;
			var lastText = TW.lines[num].text[lastTextLocation];
			if (lastText === newText || (lastText === null && newText === '')) {
				if (TW.lines[num].change && TW.lines[num].change.type === 'change') {
					delete TW.lines[num].change;
					return true;
				}
			} else {
				var origWords = TW.lines[num].words[TW.lines[num].words.length - 1];
				TW.lines[num].change = { type: 'change', text: newText, words: TW.reparseWords(newText, origWords) };
				return true;
			}
			return false;
		},

		doUndo: function(num) {
			TW.lines[num].undo = TW.lines[num].change;
			delete TW.lines[num].change;
		},

		doRedo: function(num) {
			TW.lines[num].change = TW.lines[num].undo;
			delete TW.lines[num].undo;
		},

		doConfirm: function(num) {
			TW.lines[num].change = { type: 'correct' };
		},

		doDelete: function(num) {
			TW.lines[num].change = { type: 'delete' };
		},

		setRect: function(num, rect) {
			TW.lines[num].l = Math.round(rect.l);
			TW.lines[num].r = Math.round(rect.r);
			TW.lines[num].t = Math.round(rect.t);
			TW.lines[num].b = Math.round(rect.b);
			TW.lines[num].box_size = 'changed';
		},

		// Call this to get the form of the data that can be sent back to the server.
		serialize: function(num) {
			var params = {};

			if (TW.lines[num].change) {
				params.status = TW.lines[num].change.type;
				if (params.status === 'change') {
					params.words = TW.lines[num].words;
					params.words.push(TW.lines[num].change.words);
				} else if (params.status === 'insert') {
					params.words = [];
					params.words.push(TW.lines[num].change.words);
				}
				if (TW.lines[num].box_size === 'changed') {
					params.box = { l: TW.lines[num].l, r: TW.lines[num].r, t: TW.lines[num].t, b: TW.lines[num].b };
				}
			} else if (TW.lines[num].box_size === 'changed') {
				params.status = 'change';
				params.words = TW.lines[num].words;
				params.box = { l: TW.lines[num].l, r: TW.lines[num].r, t: TW.lines[num].t, b: TW.lines[num].b };
			}
			else {
				params.status = 'undo';
			}
			params.line = this.getLineNum(num);
			params.src = TW.lines[num].src;
			return params;
		}
	};
});
