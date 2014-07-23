// line.js
//
// Requires the global variable 'currLine' to contain the current line number.
// Requires a global variable 'lines' to contain an array of all the line data, with each element containing { x:, y:, h:, w:, word: }

/*global lines */
/*global reparseWords */
/*extern line */

var line = {
	//
	// lines array routines
	//
	findLine: function(x, y) {
		// The input coordinates are the original scale
		for (var i = 0; i < lines.length; i++) {
			var bx = lines[i].l <= x;
			var bw = x <= lines[i].r;
			var by = lines[i].t <= y;
			var bh = y <= lines[i].b;
			if (bx && bw && by && bh)
				return i;
		}
		return -1;
	},

	doInsert: function(num) {
		var before = num > 0 ? lines[num-1].num : 0;
		var after = (num < lines.length) ? lines[num].num : before + 1;
		// Figure out an approximate place to put the box. It should be horizontally all the way across, and start just
		// after the last item and end just before the next item.
		var t = (num > 0) ? parseInt(lines[num-1].b) + 1 : 1;
		var r = 1000;
		var b = (num < lines.length) ? parseInt(lines[num].t) : t + 30;
		var l = 1;
		if (b - t > 30) { // don't allow the box to get too tall, so limit it to the center of a large region.
			var mid = t + (b - t) / 2;
			t = mid - 15;
			b = mid + 15;
		}
		var newLine = before + (after-before)/2;
		lines.splice(num, 0, { src:"gale", l:l, t:t, r:r, b:b, words: [[ ]], text: [''], num: newLine, change: { type: 'insert', text: '', words: [] }, box_size: 'changed' });
	},

   isLast: function(num) { return num === lines.length - 1; },
	isInRange: function(num) { return num >= 0 && num < lines.length; },

	//
	// const routines
	//
	canUndo: function(num) { return lines[num].change !== undefined; },
	canRedo: function(num) { return lines[num].undo !== undefined;	},
	hasChanged: function(num) { return (lines[num].change && lines[num].change.type === 'change') || (lines[num].box_size == 'changed'); },
	getChangeType: function(num) { return lines[num].change ? lines[num].change.type : null; },
	isDeleted: function(num) { return lines[num].change && lines[num].change.type === 'delete'; },
	getLineNum: function(num) { return lines[num].num; },
	getTextHistory: function(num) { return lines[num].text.join("<br />"); },
	getStartingText: function(num) { return lines[num].text[lines[num].text.length-1]; },
	getRect: function(num) { return { l: lines[num].l, r: lines[num].r, t: lines[num].t, b: lines[num].b }; },

	getCurrentText: function(num) {
		var ret;
		if (lines[num].change && lines[num].change.type === 'change')
			ret = lines[num].change.text;
		else
			ret = lines[num].text[lines[num].text.length-1];
		if (ret === null || ret === undefined) ret = "";
		return ret;
	},

	getCurrentWords: function(num) {
		if (!this.isInRange(num))
			return null;
		if (lines[num].change && lines[num].change.type === 'change')
			return lines[num].change.words;
		return lines[num].words[lines[num].words.length-1];
	},

	getAllHistory: function(num) {
		var line = lines[num];
		if (line.text.length > 1) {
			var str = "<table><td class='tw_header'>Correction:</td><td td class='tw_header'>Editor:</td><td td class='tw_header'>Date:</td>";
			for (var i = 0; i < line.text.length; i++) {
				var text;
				switch (line.actions[i]) {
					case 'delete': text = '-- Deleted --'; break;
					case 'correct': text = '-- Declared Correct --'; break;
					case 'change': text = line.text[i]; break;
					case 'insert': text = line.text[i]; break;
					case 'original': text = line.text[i]; break;
					case '': text = line.text[i]; break;
					default: text = line.actions[i]; break;
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
		var lastTextLocation = lines[num].text.length-1;
		var lastText = lines[num].text[lastTextLocation];
		if (lastText === newText || (lastText === null && newText === '')) {
			if (lines[num].change && lines[num].change.type === 'change') {
				delete lines[num].change;
				return true;
			}
		} else {
			var origWords = lines[num].words[lines[num].words.length-1];
			lines[num].change = { type: 'change', text: newText, words: reparseWords(newText, origWords) };
			return true;
		}
		return false;
	},

	doUndo: function(num) {
		lines[num].undo = lines[num].change;
		delete lines[num].change;
	},

	doRedo: function(num) {
		lines[num].change = lines[num].undo;
		delete lines[num].undo;
	},

	doConfirm: function(num) {
		lines[num].change = { type: 'correct' };
	},

	doDelete: function(num) {
		lines[num].change = { type: 'delete' };
	},

	setRect: function(num, rect) {
		lines[num].l = Math.round(rect.l);
		lines[num].r = Math.round(rect.r);
		lines[num].t = Math.round(rect.t);
		lines[num].b = Math.round(rect.b);
		lines[num].box_size = 'changed';
	},

	// Call this to get the form of the data that can be sent back to the server.
	serialize: function(num) {
		var params = {};

		if (lines[num].change) {
			params.status = lines[num].change.type;
			if (params.status === 'change' ) {
            params.words = lines[num].words;
            params.words.push( lines[num].change.words );
         } else if ( params.status === 'insert' ) {
            params.words = [];
            params.words.push( lines[num].change.words );
         }
			if (lines[num].box_size === 'changed') {
				params.box = { l:lines[num].l, r:lines[num].r, t:lines[num].t, b:lines[num].b };
			}
		} else if (lines[num].box_size === 'changed') {
			params.status = 'change';
			params.words = lines[num].words;
			params.box = { l:lines[num].l, r:lines[num].r, t:lines[num].t, b:lines[num].b };
		}
		else {
			params.status = 'undo';
		}
		params.line = this.getLineNum(num);
      params.src = lines[num].src;
		return params;
	}
};
