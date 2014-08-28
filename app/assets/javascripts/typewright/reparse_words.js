// reparse_words.js
//
// This function contains no side effects: it analyzes the words input and returns
// an array of words that is the best guess about how the user wanted the words split up.
//
// reparseWords(string newText, array origWords)
//		newText is the text that the user has entered for the entire line.
//		origWords is the original data. It is an object with these fields:
//			l: number, t: number, r: number, b: number,
//			word: string,
//			line: number
// The return value is a new array that resembles the old array. The newText is parsed into words.
//
// The following events can happen:
//		A word is changed: the new word gets the old word's coordinates.
//		A word is deleted: the old word's coordinates are thrown away.
//		A word is inserted: the new word gets the coordinates between the two words it was inserted between.
//		A word is split into two: the new words split the coordinates of the original word.
//		Two words are combined:  the new word gets the union of the old two words.

/*global Diff_match_patch */
/*global TW */

TW.reparseWords = function(newText, origWords, lineBox) {
	"use strict";
	function google_diff(text1, text2) {
		// This returns an array that contains all the 'events'. The events are: no_change, change, deleted, inserted, split, combined.
		// The other item in the array depends on the event:
		// no_change:
		//		old_item_index, new_item_index, text
		// changed:
		//		old_item_index, new_item_index, new_text
		// deleted:
		//		old_item_index
		// inserted:
		//		old_item_index_before, new_item_index, new_text
		// split:
		//		old_item_index, array of [ new_item_index, new_text ]
		// combined:
		//		array of [old_item_index], new_item_index, new_text
		//
		// The algorithm returns a different format, so most of this function is concerned with converting it.
		// We get an array of no_change, insert, and delete. These correspond like this:
		// - it is no change, then it is NO_CHANGE
		//	- if there is a delete without an immediately following insert, then it is DELETED
		// - if there is an insert without an immediately preceeding delete, then it is INSERTED
		// - if there is a delete with one insert following:
		//		- if there is the same number of words in the delete as the insert, it is a CHANGED
		//		- if there is one word in the delete, and more than one in the insert, it is a SPLIT
		//		- if there is more than one word in the delete, and one in the insert, it is a COMBINED
		//		- if there are, for instance, 2 words in the delete and 3 in the insert, or the other way around,
		//		then the simplest thing is to consider all but the last ones to be CHANGED, and then the last is a SPLIT or COMBINED
		var dmp = new Diff_match_patch();

		dmp.Diff_Timeout = 1;
		dmp.Diff_EditCost = 4;

		// word level diff - we trick the algorithm into thinking words are characters by converting all words to a unicode char.
		var a = dmp.diff_linesToChars_(text1.replace(/ /g, '\n'), text2.replace(/ /g, '\n'));
		text1 = /** @type {string} */(a[0]);
		text2 = /** @type {string} */(a[1]);
		var linearray = /** @type {!Array.<string>} */(a[2]);

		var d = dmp.diff_main(text1, text2);

		// Convert the diff back to original text.
		dmp.diff_charsToLines_(d, linearray);

		var convertDiffToWords = function(diff) {
			// diff is an array with two elements:
			// number: 0: no change, -1: appears in old text, 1: appears in new text
			// string: the text. This may contain more than one word separated by \n

			var ret = [];
			var oldIndex = 0;
			var newIndex = 0;
			for (var i = 0; i < diff.length; i++) {
				var action = diff[i][0];
				var text = diff[i][1];
				var words = text.split('\n');
				if (words[words.length - 1] === "")	// It might end with a newline, so remove that.
					words.pop();

				var j;
				switch (action) {
					case 0:	// no_change
						for (j = 0; j < words.length; j++)
							ret.push({ action: 'NO_CHANGE', oldIndex: oldIndex++, newIndex: newIndex++, text: words[j] });
						break;
					case -1: // delete
						if (i < diff.length-1 && diff[i+1][0] === 1) {		// This is a delete followed by an insert
							i++;
							var insWords = diff[i][1].split('\n');
							if (insWords[insWords.length - 1] === "")	// It might end with a newline, so remove that.
								insWords.pop();
							// if there are the same number of items, then they were all changed, if there are a different number of items, then all
							// but the last item of the shortest array are changed.
							var numChanged = words.length === insWords.length ? insWords.length : Math.min(words.length, insWords.length) - 1;
							for (j = 0; j < numChanged; j++)
								ret.push({ action: 'CHANGED', oldIndex: oldIndex++, newIndex: newIndex++, text: insWords[j] });

							// Now, take care of the last item, if it exists.
							if (words.length > insWords.length) {
								var arr = [];
								for (j = numChanged; j < words.length; j++) {
									arr.push(oldIndex++);
								}
								ret.push({ action: 'COMBINED', oldIndexArr: arr, newIndex: newIndex++, text: insWords[insWords.length-1] });
							} else if (words.length < insWords.length) {
								var arr2 = [];
								for (j = numChanged; j < insWords.length; j++) {
									arr2.push({ newIndex: newIndex++, text: insWords[j] });
								}
								ret.push({ action: 'SPLIT', oldIndex: oldIndex++, newIndexArr: arr2 });
							}
						} else {
							for (j = 0; j < words.length; j++)
								ret.push({ action: 'DELETED', oldIndex: oldIndex++ });
						}
						break;
					case 1:	// insert
						for (j = 0; j < words.length; j++)
							ret.push({ action: 'INSERTED', oldIndex: oldIndex, newIndex: newIndex++, text: words[j] });
						break;
				}
			}
			return ret;
		};

		var changes = convertDiffToWords(d);

//		var out = dmp.diff_prettyHtml(d);
//		out = out.replace(/&para;<br>/g, ' ');
//		document.getElementById('debugging_neil4').innerHTML = out;
//
//		dmp.diff_cleanupSemantic(d);
//		out = dmp.diff_prettyHtml(d);
//		out = out.replace(/&para;<br>/g, ' ');
//		document.getElementById('debugging_neil5').innerHTML = out;
//
//		d = dmp.diff_main(text1, text2);
//		dmp.diff_charsToLines_(d, linearray);
//		dmp.diff_cleanupEfficiency(d);
//		out = dmp.diff_prettyHtml(d);
//		out = out.replace(/&para;<br>/g, ' ');
//		document.getElementById('debugging_neil6').innerHTML = out;
		return changes;
	}

	var rectUnion = function(rect1, rect2) {
		return { l: Math.min(rect1.l,  rect2.l), t: Math.min(rect1.t,  rect2.t), b: Math.max(rect1.b,  rect2.b), r: Math.max(rect1.r,  rect2.r) };
	};
	var wordify = function(str) {
		var arr = str.split(' ');
		var words = [];
		for (var i = 0; i < arr.length; i++) {
			if (arr[i].length > 0)
			words.push(arr[i]);
		}
		return words;
	};
	var combine = function(w1, w2, str) {
		var w = rectUnion(w1, w2);
		w.line = w1.line;
		w.word = str;
		return w;
	};
	var cloneWord = function(word) {
		return  { l: word.l, t: word.t, r: word.r, b: word.b, word: word.word, line: word.line  };
	};
	var cloneWords = function(words) {
		var ret = [];
		for (var i = 0; i < words.length; i++) {
			ret.push(cloneWord(words[i]));
		}
		return ret;
	};
	var origString = function(words) {
		var old = "";
		for (var i = 0 ; i < words.length; i++) {
			if (i !== 0) old += ' ';
			old += words[i].word;
		}
		return old;
	};

	var debug = function(changes) {
		var row1 = [];
		var row2 = [];
		var row3 = [];
		var row4 = [];
		var j;
		for (var i = 0; i < changes.length; i++) {
			row1.push(changes[i].action !== 'NO_CHANGE' ? changes[i].action : '');
			var txt = '';
			var txt2 = '';
			var txt3 = '';
			switch (changes[i].action) {
				case 'NO_CHANGE':
					txt = 'o:' + changes[i].oldIndex + ' n:' + changes[i].newIndex;
					txt2 = origWords[changes[i].oldIndex].word;
					txt3 = changes[i].text;
				break;
				case 'CHANGED':
					txt = 'o:' + changes[i].oldIndex + ' n:' + changes[i].newIndex;
					txt2 = origWords[changes[i].oldIndex].word;
					txt3 = changes[i].text;
				break;
				case 'COMBINED':
					txt = 'o:' + changes[i].oldIndexArr.join('/') + ' n:' + changes[i].newIndex;
					for (j = 0; j < changes[i].oldIndexArr.length; j++)
						txt2 += origWords[changes[i].oldIndexArr[j]].word + ' ';
					txt3 = changes[i].text;
				break;
				case 'SPLIT':
					txt = 'o:' + changes[i].oldIndex + ' n:';
					txt2 = origWords[changes[i].oldIndex].word;
					for (j = 0; j < changes[i].newIndexArr.length; j++) {
						txt += changes[i].newIndexArr[j].newIndex + ' ';
						txt3 += changes[i].newIndexArr[j].text + ' ';
					}
				break;
				case 'DELETED':
					txt = 'o:' + changes[i].oldIndex;
					txt2 = origWords[changes[i].oldIndex].word;
				break;
				case 'INSERTED':
					txt = 'o:' + changes[i].oldIndex + ' n:' + changes[i].newIndex;
					txt2 = changes[i].oldIndex < origWords.length ? origWords[changes[i].oldIndex].word : '';
					txt3 = changes[i].text;
				break;
			}
			row2.push(txt);
			row3.push(txt2);
			row4.push(txt3);
		}
		var html = "<table><tr>";
		for (i = 0; i < row1.length; i++)
			html += "<td style='border:1px solid black;padding-left:4px;padding-right:4px;'>" + row1[i] + "</td>";
		html += "</tr></tr>";
		for (i = 0; i < row2.length; i++)
			html += "<td style='border:1px solid black;padding-left:4px;padding-right:4px;'>" + row2[i] + "</td>";
		html += "</tr></tr>";
		for (i = 0; i < row3.length; i++)
			html += "<td style='border:1px solid black;padding-left:4px;padding-right:4px;'>" + row3[i] + "</td>";
		html += "</tr></tr>";
		for (i = 0; i < row4.length; i++)
			html += "<td style='border:1px solid black;padding-left:4px;padding-right:4px;'>" + row4[i] + "</td>";
		html += "</tr></table>";
		document.getElementById('debugging_table').innerHTML = html;
	};

	var convertChangesToOutput = function(changes, orig) {
		orig = cloneWords(orig);
		var ret = [];
		for (var i = 0; i < changes.length; i++) {
			switch (changes[i].action) {
				case 'NO_CHANGE':
					ret.push(orig[changes[i].oldIndex]);
					break;
				case 'CHANGED':
					orig[changes[i].oldIndex].word = changes[i].text;
					ret.push(orig[changes[i].oldIndex]);
					break;
				case 'COMBINED':
					ret.push(combine(orig[changes[i].oldIndexArr[0]], orig[changes[i].oldIndexArr[changes[i].oldIndexArr.length-1]], changes[i].text));
					break;
				case 'SPLIT':
					var charCount = changes[i].newIndexArr.length - 1;	// count the spaces between words, too.
					for (var j = 0; j < changes[i].newIndexArr.length; j++)
						charCount += changes[i].newIndexArr[j].text.length;
					var totalX = parseInt(orig[changes[i].oldIndex].r,10) - parseInt(orig[changes[i].oldIndex].l,10);
					var charSize = totalX / charCount;
					var currX = parseInt(orig[changes[i].oldIndex].l,10);
					for (j = 0; j < changes[i].newIndexArr.length; j++) {
						var thisSize = Math.round(changes[i].newIndexArr[j].text.length * charSize);
						ret.push({ l: currX, r: currX + thisSize, t: orig[changes[i].oldIndex].t, b: orig[changes[i].oldIndex].b, word: changes[i].newIndexArr[j].text });
						currX += Math.round(thisSize + charSize);	// also add one here for the space between words.
					}
					break;
				case 'DELETED':
					break;
				case 'INSERTED':
					if (changes[i].oldIndex < orig.length) {
						var w = cloneWord(orig[changes[i].oldIndex]);
						if (changes[i].oldIndex > 0) {
							w.r = w.l;
							w.l = orig[changes[i].oldIndex-1].r;
						}
						w.word = changes[i].text;
						ret.push(w);
					} else {
						ret.push({ l:lineBox.l, r:lineBox.r, t:lineBox.t, b:lineBox.b, word: changes[i].text });
					}
					break;
			}
		}
		return ret;
	};
	// The user just changed the text: try to figure out what the new word boundaries are.
	// origWords is an array of a hash with the important elements l, r, and word.

	var words = wordify(newText);

	var changes = google_diff(origString(origWords), words.join(' '));
	if (TW.showDebugItems)
		debug(changes);

	return convertChangesToOutput(changes, origWords);
};

