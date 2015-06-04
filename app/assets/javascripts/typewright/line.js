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

/*global TW, console */

jQuery(document).ready(function($) {
	"use strict";

    // get the index of the item that represents this line number
    // comparing floats for equality is bad news...
	function getIndexFromLineNum(lineNum) {
		var found = false;
		for (var num = 0; num < TW.lines.length && !found; num++) {
			if (TW.lines[num].num === lineNum)
				return num;
		}
		return -1;
	}

    // get the insertion point into the line index of this line number
    // comparing floats for equality is bad news...
	function getClosestIndexFromLineNum(lineNum) {
		var found = false;
		for (var num = 0; num < TW.lines.length && !found; num++) {
			if (TW.lines[num].num === lineNum)
				return num;
			if (TW.lines[num].num > lineNum)
				return num;
		}
		return TW.lines.length;
	}

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
		   var otherSrc = TW.lines[num - 1].src;
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
			TW.lines.splice(num, 0, { src: otherSrc, l: l, t: t, r: r, b: b, words: [
				[ ]
			], text: [''], num: newLine, change: { type: 'insert', text: '', words: [] }, box_size: 'changed', dirty: true });
		},

		//
		// members
		//
		allStaleLines: [],
		staleLines: {},

		//
		// const routines
		//

        isEof: function(num) { return num === TW.lines.length; },
		isLast: function(num) { return num === TW.lines.length - 1; },
		isInRange: function(num) { return num >= 0 && num < TW.lines.length; },

		canUndo: function(num) {
            if( TW.line.isInRange( num ) === false ) { return false; }
            return TW.lines[num].change !== undefined;
        },
		canRedo: function(num) {
            if( TW.line.isInRange( num ) === false ) { return false; }
            return TW.lines[num].undo !== undefined;
        },
		hasChanged: function(num) {
            if( TW.line.isInRange( num ) === false ) { return false; }
            return (TW.lines[num].change && TW.lines[num].change.type === 'change') || (TW.lines[num].box_size === 'changed');
        },
		getLastAction: function(num) {
            if( TW.line.isInRange( num ) === false ) { return null; }
			if (!TW.lines[num].actions)
				return null;
			return TW.lines[num].actions[TW.lines[num].actions.length-1];
		},
		getChangeType: function(num) {
            if( TW.line.isInRange( num ) === false ) { return null; }
			if (TW.lines[num].change)
				return TW.lines[num].change.type;
			if (TW.line.getLastAction(num) === 'delete')
				return 'delete';
			return null;
		},
		isJustDeleted: function(num) {
            if( TW.line.isInRange( num ) === false ) { return false; }
            return TW.lines[num].change && TW.lines[num].change.type === 'delete';
        },
		isDeleted: function(num) {
            if( TW.line.isInRange( num ) === false ) { return false; }
			if (TW.line.isJustDeleted(num))
				return true;
			return TW.line.getLastAction(num) === 'delete';
		},
		getLineNum: function(num) {
            if( TW.line.isInRange( num ) === false ) { return ''; }
            return TW.lines[num].num;
        },
		getStartingText: function(num) {
            return TW.lines[num].text[TW.lines[num].text.length - 1];
        },
		getRect: function(num) {
            if( TW.line.isInRange( num ) === false ) { return { l: 0, r: 0, t: 0, b: 0 }; }
            return { l: TW.lines[num].l, r: TW.lines[num].r, t: TW.lines[num].t, b: TW.lines[num].b };
        },
		isDirty: function(num) {
            if( TW.line.isInRange( num ) === false ) { return false; }
            return TW.lines[num].dirty === true;
        },
		numUndisplayedChanges: function() {
            return TW.line.allStaleLines.length;
        },

		getCurrentText: function(num) {
			var ret;
            if( TW.line.isEof( num ) === true ) { return '-- bottom of page --'; }
            if( TW.line.isInRange( num ) === false ) { return ''; }

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
			function formatLine(action, lineText, author, date, klass) {
				if (!date) date = "";
				var text;
				switch (action) {
					case 'delete':
						text = '-- Deleted --';
						break;
					case 'correct':
						text = '-- Declared Correct --';
						break;
					case 'change':
						text = lineText;
						break;
					case 'insert':
						text = 'Inserted';
						break;
					case 'original':
						text = lineText;
						break;
					case '':
						text = lineText;
						break;
					default:
						text = action;
						break;
				}
				return "<tr class='" + klass + "'><td><span></span>" + text + "</td><td>" + author + "</td><td>" + date + "</td></tr>";
			}

            if( TW.line.isInRange( num ) === false ) { return null; }

			var line = TW.lines[num];
			var rows = [];
			var i;
			if (line.actions) {
				for (i = 0; i < line.text.length; i++) {
					var t = line.exact_times && line.exact_times[i] ? line.exact_times[i] : 0;
					rows.push({ action: line.actions[i], text: line.text[i], author: line.authors[i], date: line.dates[i], time: t, klass: "" });
				}
			}
			if (TW.line.staleLines[num])
				for (i = 0; i < TW.line.staleLines[num].length; i++) {
					var change = TW.line.staleLines[num][i];
					rows.push({ action: change.action, text: change.text, author: change.author, date: change.date, time: change.exact_time, klass: 'tw_stale' });
				}
			if (line.change)
				rows.push({ action: line.change.type, text: line.change.text, author: "You", date: line.change.date, time: line.change.exact_time, klass: 'tw_local_change' });

			if (rows.length > 0) {
				var str = "<table><tr><td class='tw_header'>Correction:</td><td td class='tw_header'>Editor:</td><td td class='tw_header'>Date:</td></tr>";
				rows.sort(function(a,b) { return a.time - b.time; });
				for (i = 0; i < rows.length; i++)
					str += formatLine(rows[i].action, rows[i].text, rows[i].author, rows[i].date, rows[i].klass);

				str += "</table>";
				return str;
			}
			return null;
		},
		lineIsStale: function(num) {
			return TW.line.staleLines[num] && TW.line.staleLines[num].length > 0;
		},

		//
		// modifying routines
		//
		setClean: function(num) { TW.lines[num].dirty = false; },

		doRegisterLineChange: function(num, newText) {
            if( TW.line.isInRange( num ) == false ) { return false; }

			var line = TW.lines[num];
			// sets the line if there is something to set, and returns true if a change was made.
			var lastTextLocation = line.text.length - 1;
			var lastText = line.text[lastTextLocation];
			if (lastText === newText || (lastText === null && newText === '')) {
				if (line.change && line.change.type === 'change') {
					line.dirty = true;
					delete line.change;
					return true;
				}
			} else {
				line.dirty = true;
				var origWords = line.words[line.words.length - 1];
				line.change = { type: 'change', text: newText, words: TW.reparseWords(newText, origWords, { l: line.l, r: line.r, t: line.t, b: line.b }) };
				return true;
			}
			return false;
		},

		setEditTime: function(edit_line, edit_time, exact_time) {
			var num = getIndexFromLineNum(edit_line);
			if (num >= 0 && TW.lines[num].change) {
				TW.lines[num].change.date = edit_time;
				TW.lines[num].change.exact_time = exact_time;
			} else
				console.log("Can't set edit time: ",edit_line,num,edit_time);
		},

		doUndo: function(num) {
			TW.lines[num].dirty = true;
			TW.lines[num].undo = TW.lines[num].change;
			delete TW.lines[num].change;
		},

		doRedo: function(num) {
			TW.lines[num].dirty = true;
			TW.lines[num].change = TW.lines[num].undo;
			delete TW.lines[num].undo;
		},

		doConfirm: function(num) {
			TW.lines[num].dirty = true;
			TW.lines[num].change = { type: 'correct' };
		},

		doDelete: function(num) {
			TW.lines[num].dirty = true;
			TW.lines[num].change = { type: 'delete' };
		},

		setRect: function(num, rect) {
			TW.lines[num].dirty = true;
			TW.lines[num].l = Math.round(rect.l);
			TW.lines[num].r = Math.round(rect.r);
			TW.lines[num].t = Math.round(rect.t);
			TW.lines[num].b = Math.round(rect.b);
			TW.lines[num].box_size = 'changed';
		},

		liveUpdate: function(newLines) {
			$.merge(TW.line.allStaleLines, newLines);
			for (var i = 0; i < newLines.length; i++) {
				var newLine = newLines[i];
				newLine.line = parseFloat(newLine.line);
				var num = getIndexFromLineNum(newLine.line);
				if (num >= 0) {
					var staleArr = TW.line.staleLines[num];
					if (staleArr === undefined)
						staleArr = [];
					staleArr.push(newLine);
					TW.line.staleLines[num] = staleArr;
					// If this is the first modification on a line, then we need to add some infrastructure.
					var destinationLine = TW.lines[num];
					if (destinationLine.actions === undefined) {
						destinationLine.actions = [ 'original' ];
						destinationLine.authors = [ 'Original' ];
						destinationLine.dates = [ '' ];
						destinationLine.exact_times = [ '' ];
					}
				}
			}
		},

      integrateLocalChange: function(destinationLine) {
         destinationLine.actions.push(destinationLine.change.type);
         destinationLine.authors.push("You");
         destinationLine.dates.push(destinationLine.change.date);
         destinationLine.exact_times.push(destinationLine.change.exact_time);
         destinationLine.text.push(destinationLine.change.text);
         destinationLine.words.push(destinationLine.change.words);
         destinationLine.change = undefined;
      },

		integrateRemoteChanges: function(ignoreConflicts) {
         var last_line_change_time = 0;
         var savedStaleLines = [];
			for (var i = 0; i < TW.line.allStaleLines.length; i++) {
				var line = TW.line.allStaleLines[i];
				var num = getIndexFromLineNum(line.line);
				var destinationLine = num >= 0 ? TW.lines[num] : null;
				if (destinationLine && destinationLine.change) {
               if (!ignoreConflicts) {
                  savedStaleLines.push(line);
                  continue; // don't overwrite my changes with external ones, skip to next line
               }
               if (destinationLine.change.exact_time < line.exact_time) {  // integrate this if the local change was before the remote one
                  this.integrateLocalChange(destinationLine);
               }
				}
				switch (line.action) {
					case 'change':
						if (destinationLine) {
							destinationLine.actions.push(line.action);
							destinationLine.authors.push(line.author);
							destinationLine.dates.push(line.date);
							destinationLine.exact_times.push(line.exact_time);
							destinationLine.text.push(line.text);
							destinationLine.words.push(line.words);
                     destinationLine.l = line.l;
                     destinationLine.r = line.r;
                     destinationLine.t = line.t;
                     destinationLine.b = line.b;
                     last_line_change_time = line.exact_time;
						}
						break;
					case 'insert':
						num = getClosestIndexFromLineNum(line.line);
						TW.lines.splice(num, 0, { src: line.src, l: line.l, t: line.t, r: line.r, b: line.b, words: [[ ]], text: [''], actions: [''], authors: [''], dates: [''], exact_times: [''], num: line.line});
						break;
					case 'delete':
						if (destinationLine) {
							destinationLine.actions.push(line.action);
							destinationLine.authors.push(line.author);
							destinationLine.dates.push(line.date);
							destinationLine.exact_times.push(line.exact_time);
							destinationLine.text.push('');
							destinationLine.words.push([]);
                     last_line_change_time = line.exact_time;
						}
						break;
				}
         }
         // integrate the local change at the end if it was after the remote last line change
         if (destinationLine && destinationLine.change && destinationLine.change.exact_time >= last_line_change_time) {
            this.integrateLocalChange(destinationLine);
         }
			TW.line.allStaleLines = savedStaleLines;
			TW.line.staleLines = {};
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
