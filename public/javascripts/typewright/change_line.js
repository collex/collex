// change_line.js
//
// Requires the html element: <div class='change_line' data-amount='NUM'>
// Requires the global variable currLine to contain the current line number.
// Requires the object 'line' to handle all getting and setting values for the set of data.
// Requires that there be an element with the id 'line_number' to visually display the line number.

/*global currLine:true, currUser */
/*global YUI */
/*global window */
/*global showDebugItems */
/*global alert, Image */
/*global line */
/*global doc_id, page, updateUrl, imgWidth, imgHeight */
/*global imgCursor */

YUI().use('node', 'event-delegate', 'event-key', 'event-mousewheel', 'event-custom', function(Y) {
	function create_display_line(str) {
		str= '' + str;
		return str.replace(/\'/g, '&apos;');
	}

	function create_jump_link(str, amount, isDeleted) {
		var classes = 'nav_link tw_change_line';
		if (isDeleted)
			classes += " tw_deleted_line";
		return "<a href='#' class='"+classes + "' data-amount='" + amount + "'>" + create_display_line(str) + "</a>";
	}

	function setUndoButtons() {
		var un = Y.one('.tw_undo_button');
		var re = Y.one('.tw_redo_button');
		if (line.canRedo(currLine)) {
			un.addClass('hidden');
			re.removeClass('hidden');
		} else if (line.canUndo(currLine)) {
			un.removeClass('hidden');
			re.addClass('hidden');
		} else {
			un.addClass('hidden');
			re.addClass('hidden');
		}

		var correct = Y.one('.tw_correct');
		if (correct) {
//			if (line.hasChanged(currLine))
//				correct.addClass('disabled');
//			else
				correct.removeClass('disabled');
		}

	}

	var serverNotifyArrayParams = function(url, params) {
	};

	function updateServer() {

		var params = line.serialize(currLine);
		params.page = page;
		params._method = 'PUT';

    // TODO-PER: This is probably safe to put in the general serverNotify function, but testing is needed.
    YUI().use('querystring-stringify', function(Y) {

			// The default call of stringify-simple doesn't create the nested array parameters
			// in the right format for ruby, so we call it explicitly here.
			params = Y.QueryString.stringify( params, { arrayKey: true } );
			serverNotify(updateUrl, params);

		});
	}

	var updateServerSync = function () {
		var params = line.serialize(currLine);
		params.page = page;
		params._method = 'PUT';

		serverNotifySync(updateUrl, params);
	};

	function tooltipIcon(iconStyle, tooltipText) {
		return "<span class='tw_icon " + iconStyle + " tw_history_tooltip_wrapper'>&nbsp;<span class='tw_tooltip hidden'>" + tooltipText + "</span></span>";

	}

	function createHistory(lineNum) {
		var str = line.getAllHistory(lineNum);
		if (str) {
			return tooltipIcon("tw_icon_edit_history", "<h4 class='header'>History:</h4><hr />" + str);
		}
		return "";
	}

	function createIcon(lineNum) {
		switch (line.getChangeType(lineNum)) {
			case 'change': return tooltipIcon("tw_icon_edit", "Originally: "+line.getStartingText(lineNum));
			case 'delete': return tooltipIcon("tw_icon_delete", 'Line has been deleted.');
			case 'correct': return tooltipIcon("tw_icon_checkmark", 'Line is correct.');
		}
		return "";
	}

	function redrawCurrIcons() {
		var el = Y.one('#tw_text_1 .tw_change_icon');
		el._node.innerHTML = createIcon(currLine);
		setUndoButtons();
	}

	function redrawCurrLine() {
		redrawCurrIcons();
		var elHist = Y.one('#tw_text_1 .tw_history_icon');
		var elNum = Y.one('#tw_text_1 .tw_line_num');
		elHist._node.innerHTML = createHistory(currLine);
		elNum._node.innerHTML = create_display_line(line.getLineNum(currLine));
		var displayLine = line.getCurrentText(currLine);
        if (displayLine) {
		    displayLine = displayLine.replace(/\'/g, '&apos;');
        }
		var editingLine = Y.one("#tw_editing_line");
		if (line.isDeleted(currLine))
			editingLine._node.innerHTML = "<input id='tw_input_focus' class='tw_deleted_line' readonly='readonly' type='text' value='" + displayLine + "' />";
		else
			editingLine._node.innerHTML = "<input id='tw_input_focus' type='text' value='" + displayLine + "' />";

		var foc = Y.one("#tw_input_focus");
		foc.focus();
	}

	function lineModified() {
		redrawCurrLine();
		updateServer();
	}

	var lineDirty = false;
	var mostRecentLine = "";

	function line_changed() {
		var input = Y.one("#tw_input_focus");
		if (input) {
			if (input._node.value !== mostRecentLine) {
				lineDirty = true;
				mostRecentLine = input._node.value;
			}
			if (line.doRegisterLineChange(currLine, input._node.value))
				redrawCurrIcons();
		}
	}

	function redraw() {
		var elHist = Y.one('#tw_text_0 .tw_history_icon');
		var elChg = Y.one('#tw_text_0 .tw_change_icon');
		var elNum = Y.one('#tw_text_0 .tw_line_num');
		var elText = Y.one('#tw_text_0 .tw_text');
		if (currLine > 0) {
			elHist._node.innerHTML = createHistory(currLine-1);
			elChg._node.innerHTML = createIcon(currLine-1);
			elNum._node.innerHTML = create_display_line(line.getLineNum(currLine-1));
			elText._node.innerHTML = create_jump_link(line.getCurrentText(currLine-1), -1, line.isDeleted(currLine-1));
		} else {
			elHist._node.innerHTML = '';
			elChg._node.innerHTML = '';
			elNum._node.innerHTML = '';
			elText._node.innerHTML = '-- top of page --';
		}

		redrawCurrLine();

		elHist = Y.one('#tw_text_2 .tw_history_icon');
		elChg = Y.one('#tw_text_2 .tw_change_icon');
		elNum = Y.one('#tw_text_2 .tw_line_num');
		elText = Y.one('#tw_text_2 .tw_text');
		if (!line.isLast(currLine)) {
			elHist._node.innerHTML = createHistory(currLine+1);
			elChg._node.innerHTML = createIcon(currLine+1);
			elNum._node.innerHTML = create_display_line(line.getLineNum(currLine+1));
			elText._node.innerHTML = create_jump_link(line.getCurrentText(currLine+1), 1, line.isDeleted(currLine+1));
		} else {
			elHist._node.innerHTML = '';
			elChg._node.innerHTML = '';
			elNum._node.innerHTML = '';
			elText._node.innerHTML = '-- bottom of page --';
		}

		// Get the original/full size of the image so we know how to much to scale.
		imgCursor.update();
	}

	function change_line_abs(lineNum) {
		if (line.isInRange(lineNum)) {
			if (lineDirty) {
				lineDirty = false;
				updateServer();
			}
			currLine = lineNum;
			redraw();
			var input = Y.one("#tw_input_focus");
			mostRecentLine = input._node.value;
		}
	}

	function change_line_rel(amount) {
		change_line_abs(currLine+amount);
	}

	function setCaretPosition(ctrl, pos, len) {
		if(ctrl.setSelectionRange)
		{
			ctrl.focus();
			ctrl.setSelectionRange(pos,pos+len);
		}
		else if (ctrl.createTextRange) {
			var range = ctrl.createTextRange();
			range.collapse(true);
			range.moveEnd('character', pos+len);
			range.moveStart('character', pos);
			range.select();
		}
	}

	function insert_above() {
		line.doInsert(currLine);
		redraw();
		updateServer();
	}

	function insert_below() {
		line.doInsert(currLine+1);
		redraw();
		updateServer();
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	//	EVENT HANDLERS
	//
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////

	var backspace = 8;
	var enter = 13;
	var page_up = 33;
	var page_down = 34;
	var end = 35;
	var home = 36;
	var up_arrow = 38;
	var down_arrow = 40;
	var kdelete = 46;
	var kI = 73;
	var kY = 89;
	var ctrl_enter = '13+ctrl';
	var ctrl_delete = '46+ctrl';
	var ctrl_backspace = '8+ctrl';
	var ctrl_I = '73+ctrl';
	var shift_ctrl_I = '73+shift+ctrl';
	var ctrl_Y = '89+ctrl';
	var all_controlled_keys = ctrl_enter+',' + ctrl_backspace+',' + ctrl_delete+',' + ctrl_I+',' + ctrl_Y+',';
	var all_non_shifted_keys = enter+',' + page_up+',' + page_down+',' + end+',' + home+',' + up_arrow+',' + down_arrow;

	//
	// key handling
	//
	Y.on('key', function(e) {
		if (e.target.get('id') === 'tw_input_focus') {
			e.halt();
			var key = e.keyCode;
			if (e.shiftKey) key += "+shift";
			if (e.ctrlKey) key += "+ctrl";

			switch (key) {
				case page_up: change_line_rel(-3); break;
				case page_down: change_line_rel(3); break;
				case up_arrow: change_line_rel(-1); break;
				case down_arrow: change_line_rel(1); break;
				case enter: change_line_rel(1); break;

				case end: var foc = Y.one("#tw_input_focus"); setCaretPosition(foc._node, foc._node.value.length, 0); break;
				case home: var foc2 = Y.one("#tw_input_focus"); setCaretPosition(foc2._node, 0, 0); break;
			}
		}
	}, 'body', 'down:'+all_non_shifted_keys, Y);

	Y.on('key', function(e) {
		if (e.target.get('id') === 'tw_input_focus') {
			e.halt();
			var key = e.keyCode;
			if (e.shiftKey) key += "+shift";
			if (e.ctrlKey) key += "+ctrl";

			switch (key) {
				case ctrl_enter: line.doConfirm(currLine); lineModified(); break;
				case ctrl_backspace: line.doDelete(currLine); lineModified(); break;
				case ctrl_delete: line.doDelete(currLine); lineModified(); break;
				case ctrl_I: insert_below(); break;
				case ctrl_Y:
					if (line.canRedo(currLine)) {
						line.doRedo(currLine);
						lineModified();
					} else if (line.canUndo(currLine)) {
						line.doUndo(currLine);
						lineModified();
					}
					break;
			}
		}
	}, 'body', 'down:'+all_controlled_keys, Y);

	// Have to do the multiple modifier keys separately because they interfere with the single modifier keys.
	Y.on('key', function(e) {
		if (e.target.get('id') === 'tw_input_focus') {
			e.halt();
			var key = e.keyCode;
			if (e.shiftKey) key += "+shift";
			if (e.ctrlKey) key += "+ctrl";

			switch (key) {
				case shift_ctrl_I: insert_above(); break;
			}
		}
	}, 'body', 'down:'+shift_ctrl_I, Y);

	//
	// confirm line
	//

	Y.on("click", function(e) {
        if (line.hasChanged(currLine)) {
            change_line_rel(1);
        } else {
		    line.doConfirm(currLine);
            lineModified();
        }
	 }, ".tw_correct");

	//
	// move to different line
	//

	Y.Global.on('changeLine:highlight', function(lineNum, text) {
		change_line_abs(lineNum);
		var pos = line.getStartingText(lineNum).indexOf(text);
		if (pos >= 0) {
			var foc = Y.one("#tw_input_focus");
			setCaretPosition(foc._node, pos, text.length);
		}
	});

    Y.delegate("click", function(e) {
		var amount = e.target._node.getAttribute('data-amount');
        change_line_rel(parseInt(amount));
    }, 'body', ".tw_change_line");

    Y.on("load", function(e) {
        change_line_rel(0);
    }, window);

	Y.on('mousewheel', function(e) {
		// The mouse wheel should work any time the input has the focus even if the wheel isn't over it.
		var isInEditingArea = e.target.ancestor('.tw_editing') !== null;
		var isScrollTarget = (e.target._node.parentElement.id === 'tw_img_full' || isInEditingArea
			|| e.target._node.id === 'tw_pointer_doc');
		// For now, we just exclude when the target is a select control
//		if (e.target._node.tagName !== 'OPTION') {
		if (isScrollTarget) {
			var delta = e.wheelDelta;
			change_line_rel(-delta);
			e.halt();
		}
	}, '#tw_input_focus');

	Y.delegate("click", function(e) {
		var coords = imgCursor.convertThumbToOrig(e.clientX, e.clientY);
		var lineNum = line.findLine(coords.x, coords.y);
		change_line_abs(lineNum);
	 }, 'body', "#tw_img_thumb");

	Y.on("beforeunload", function(e) {
		if (lineDirty)
			updateServerSync();
	}, window);

	//
	// delete line
	//

	Y.on("click", function(e) {
		line.doDelete(currLine);
		lineModified();
	 }, ".tw_delete_line");

	//
	// Change line
	//

	Y.delegate('keyup', function(e) {
		line_changed();
	}, 'body', '#tw_input_focus');

	//
	// undo
	//

	Y.on("click", function(e) {
		line.doUndo(currLine);
		lineModified();
	 }, ".tw_undo_button");

	Y.on("click", function(e) {
		line.doRedo(currLine);
		lineModified();
	 }, ".tw_redo_button");

	//
	// Insert
	//

	Y.on("click", function(e) {
		insert_above();
	 }, ".tw_insert_above_button");

	Y.on("click", function(e) {
		insert_below();
	 }, ".tw_insert_below_button");

	Y.on("unload", function(e) {
		if (lineDirty)
			updateServer();
	}, "body");

	Y.on("resize", function(e) {
	  redraw();
	}, window);
});
