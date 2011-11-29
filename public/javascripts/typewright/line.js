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
		var after = lines[num].num;
		var newLine = before + (after-before)/2;
		lines.splice(num, 0, { l:0, t:0, r:0, b:0, words: [[ ]], text: [''], num: newLine, change: { type: 'insert', text: '', words: [] } });
	},

	isLast: function(num) { return num === lines.length - 1; },
	isInRange: function(num) { return num >= 0 && num < lines.length; },

	//
	// const routines
	//
	canUndo: function(num) { return lines[num].change !== undefined; },
	canRedo: function(num) { return lines[num].undo !== undefined;	},
	hasChanged: function(num) { return lines[num].change && lines[num].change.type === 'change'; },
	getChangeType: function(num) { return lines[num].change ? lines[num].change.type : null; },
	isDeleted: function(num) { return lines[num].change && lines[num].change.type === 'delete'; },
	getLineNum: function(num) { return lines[num].num; },
	getTextHistory: function(num) { return lines[num].text.join("<br />"); },
	getStartingText: function(num) { return lines[num].text[lines[num].text.length-1]; },
	getRect: function(num) { return { l: lines[num].l, r: lines[num].r, t: lines[num].t, b: lines[num].b }; },

	getCurrentText: function(num) {
		if (lines[num].change && lines[num].change.type === 'change')
			return lines[num].change.text;
		return lines[num].text[lines[num].text.length-1];
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
		if (lines[num].text[lines[num].text.length-1] === newText) {
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

	// Call this to get the form of the data that can be sent back to the server.
	serialize: function(num) {
		var params = {};

		if (lines[num].change) {
			params.status = lines[num].change.type;
			if (params.status === 'change' || params.status === 'insert') {
				params.words = lines[num].change.words;
			}
		}
		else
			params.status = 'undo';
		params.line = this.getLineNum(num);
        params.src = lines[num].src
		return params;
	}
};
