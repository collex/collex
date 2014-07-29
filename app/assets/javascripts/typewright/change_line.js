// change_line.js
//
// Requires the html element: <div class='change_line' data-amount='NUM'>
// Requires the global variable TW.currLine to contain the current line number.
// Requires the object 'line' to handle all getting and setting values for the set of data.
// Requires that there be an element with the id 'line_number' to visually display the line number.

/*global YUI */
/*global TW */

jQuery(document).ready(function($) {
	"use strict";
	var body = $("body");
	var imgCursor;
	var imgBoxResize;

   var updateInProcess = false;

   function create_display_line(str) {
      var newStr = String(str);
      return newStr.replace(/\"/g, "&quot;");
   }

   function create_jump_link(str, amount, isDeleted) {
      var classes = 'nav_link tw_change_line';
      if (isDeleted) {
         classes += " tw_deleted_line";
      }
      return "<a href=\"#\" class=\"" + classes + "\" data-amount=\"" + amount + "\">" + create_display_line(str) + "</a>";
   }

   function setUndoButtons() {
      var un = $('.tw_undo_button');
      var re = $('.tw_redo_button');
      if (TW.line.canRedo(TW.currLine)) {
         un.addClass('hidden');
         re.removeClass('hidden');
      } else if (TW.line.canUndo(TW.currLine)) {
         un.removeClass('hidden');
         re.addClass('hidden');
      } else {
         un.addClass('hidden');
         re.addClass('hidden');
      }

      var correct = $('.tw_correct');
      if (correct) {
         correct.removeClass('disabled');
      }
   }

//   var serverNotifyArrayParams = function(url, params) {
//   };

	function updateServer() {
		if (TW.line.isDirty(TW.currLine)) {
			var params = TW.line.serialize(TW.currLine);
			params.page = TW.page;

			jQuery.ajax({
				url: TW.updateUrl,
				type: 'PUT',
				data: {params: JSON.stringify(params)},
				async: false,
				beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', jQuery('meta[name="csrf-token"]').attr('content'));}
			});
			TW.line.setClean(TW.currLine);
		}
	}

   var updateServerSync = function() {
		// TODO-PER: Originally this was needed to do something extra when the page was about to unload. Originally this caused the "sync: true" to be set.
      updateServer();
   };

   function tooltipIcon(iconStyle, tooltipText) {
      return "<span class='tw_icon " + iconStyle + " tw_history_tooltip_wrapper'>&nbsp;<span class='tw_tooltip hidden'>" + tooltipText + "</span></span>";

   }

   function createHistory(lineNum) {
      var str = TW.line.getAllHistory(lineNum);
      if (str) {
         return tooltipIcon("tw_icon_edit_history", "<h4 class='header'>History:</h4><hr />" + str);
      }
      return "";
   }

   function createIcon(lineNum) {
      switch (TW.line.getChangeType(lineNum)) {
         case 'change':
            return tooltipIcon("tw_icon_edit", "Originally: " + TW.line.getStartingText(lineNum));
         case 'delete':
            return tooltipIcon("tw_icon_delete", 'Line has been deleted.');
         case 'correct':
            return tooltipIcon("tw_icon_checkmark", 'Line is correct.');
      }
      return "";
   }

   function redrawCurrIcons() {
      var el = $('#tw_text_1 .tw_change_icon');
      el.html( createIcon(TW.currLine) );
      setUndoButtons();
   }

   function redrawCurrLine() {
      redrawCurrIcons();
      var elHist = $('#tw_text_1 .tw_history_icon');
      var elNum = $('#tw_text_1 .tw_line_num');
      elHist.html( createHistory(TW.currLine) );
      elNum.html(create_display_line(TW.line.getLineNum(TW.currLine)) );
      var displayLine = TW.line.getCurrentText(TW.currLine).replace(/\"/g, "&quot;");

      var editingLine = $("#tw_editing_line");
      if (TW.line.isJustDeleted(TW.currLine)) {
         editingLine.html("<input id=\"tw_input_focus\" class=\"tw_deleted_line\" readonly=\"readonly\" type=\"text\" value=\"" + displayLine + "\" />");
      } else if (TW.line.isDeleted(TW.currLine)) {
			editingLine.html("<input id=\"tw_input_focus\" class=\"tw_deleted_line_text\" type=\"text\" value=\"\" placeholder='" + displayLine + "' />");
		} else {
         editingLine.html( "<input id=\"tw_input_focus\" type=\"text\" value=\"" + displayLine + "\" />");
      }

      $("#tw_input_focus").focus();
   }

   function lineModified() {
      redrawCurrLine();
      updateServer();
   }

   function line_changed() {
      var input = $("#tw_input_focus");
      if (input) {
         if (TW.line.doRegisterLineChange(TW.currLine, input.val())) {
            redrawCurrIcons();
         }
      }
   }

   function redraw() {
      if (window.TW.currLine === undefined) {
         return;
      }
      // Must not be on a typewright page.
      var elHist = $('#tw_text_0 .tw_history_icon');
      var elChg = $('#tw_text_0 .tw_change_icon');
      var elNum = $('#tw_text_0 .tw_line_num');
      var elText = $('#tw_text_0 .tw_text');
      if (TW.currLine > 0) {
         elHist.html(createHistory(TW.currLine - 1));
         elChg.html(createIcon(TW.currLine - 1));
         elNum.html(create_display_line(TW.line.getLineNum(TW.currLine - 1)));
         elText.html(create_jump_link(TW.line.getCurrentText(TW.currLine - 1), -1, TW.line.isDeleted(TW.currLine - 1)));
      } else {
         elHist.html('');
         elChg.html('');
         elNum.html('');
         elText.html('-- top of page --');
      }

      redrawCurrLine();

      elHist = $('#tw_text_2 .tw_history_icon');
      elChg = $('#tw_text_2 .tw_change_icon');
      elNum = $('#tw_text_2 .tw_line_num');
      elText = $('#tw_text_2 .tw_text');
      if (!TW.line.isLast(TW.currLine)) {
         elHist.html(createHistory(TW.currLine + 1));
         elChg.html(createIcon(TW.currLine + 1));
         elNum.html(create_display_line(TW.line.getLineNum(TW.currLine + 1)));
         elText.html(create_jump_link(TW.line.getCurrentText(TW.currLine + 1), 1, TW.line.isDeleted(TW.currLine + 1)));
      } else {
         elHist.html('');
         elChg.html('');
         elNum.html('');
         elText.html('-- bottom of page --');
      }

      // Get the original/full size of the image so we know how to much to scale.
      imgCursor.update(TW.currLine);
		if (imgBoxResize) {
			imgBoxResize.destroy();
			imgBoxResize = undefined;
		}
   }

   function change_line_abs(newLineNum) {
      if (TW.line.isInRange(newLineNum)) {
         if (window.TW.currLine !== undefined) {
            if (TW.line.hasChanged(TW.currLine)) {
               updateServer();
            }
            TW.currLine = newLineNum;
            redraw();
         }
      }
   }

   function change_line_rel(amount) {
      change_line_abs(TW.currLine + amount);
   }

   function setCaretPosition(ctrl, pos, len) {
      if (ctrl.setSelectionRange) {
         ctrl.focus();
         ctrl.setSelectionRange(pos, pos + len);
      } else if (ctrl.createTextRange) {
         var range = ctrl.createTextRange();
         range.collapse(true);
         range.moveEnd('character', pos + len);
         range.moveStart('character', pos);
         range.select();
      }
   }

   function insert_above() {
      TW.line.doInsert(TW.currLine);
      redraw();
      updateServer();
   }

   function insert_below() {
      TW.line.doInsert(TW.currLine + 1);
      TW.currLine+=1;
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
   var kDelete = 46;
   var kI = 73;
   var kY = 89;

   //
   // confirm line
   //

	body.on("click", ".tw_correct", function () {
       if ( updateInProcess === false ) {
         if (TW.line.hasChanged(TW.currLine)) {
            change_line_rel(1);
         } else {
            TW.line.doConfirm(TW.currLine);
            lineModified();
         }
       }
   });

   //
   // move to different line
   //

	body.bind("changeLine:highlight", function(e, params) {
		var lineNum = params.lineNum;
		var text = params.text;
      change_line_abs(lineNum);
      var pos = TW.line.getStartingText(lineNum).indexOf(text);
      if (pos >= 0) {
         var foc = $("#tw_input_focus");
         setCaretPosition(foc[0], pos, text.length);
      }
   });

	body.on("click", ".tw_change_line", function () {
      var amount = $(this).attr('data-amount');
      change_line_rel(parseInt(amount,10));
   });

	body.on("mousewheel", ".tw_editing, #tw_input_focus, #tw_img_full, #tw_pointer_doc", function(e) {
		var target = $(e.target);
		var delta = e.originalEvent.wheelDelta / 120;
		change_line_rel(-delta);
		e.preventDefault();
		e.stopPropagation();
	});

	body.on("click", "#tw_img_thumb", function (e) {
       var coords = imgCursor.convertThumbToOrig(e.clientX, e.clientY);
      var lineNum = TW.line.findLine(coords.x, coords.y);
      change_line_abs(lineNum);
   });

	$(window).unload(function() {
      if (TW.currLine !== undefined && TW.line.hasChanged(TW.currLine)) {
         updateServerSync();
      }
   });

   //
   // delete line
   //

	body.on("click", ".tw_delete_line", function (e) {
       TW.line.doDelete(TW.currLine);
      lineModified();
   });

   //
   // Change line
   //
	body.on("keydown", "#tw_input_focus", function(e) {
		updateInProcess = true;
   });

	body.on("keyup", "#tw_input_focus", function(e) {
      var key = e.which;
      switch (key) {
         case backspace:
            if (e.ctrlKey) {
               TW.line.doDelete(TW.currLine);
               lineModified();
            } else {
               line_changed();
            }
            break;
         case kDelete:
            if (e.ctrlKey) {
				TW.line.doDelete(TW.currLine);
               lineModified();
            } else {
               line_changed();
            }
            break;
         case enter:
            if (e.ctrlKey) {
				TW.line.doConfirm(TW.currLine);
               lineModified();
            } else {
				if (updateInProcess) // This can be triggered by some other action, like closing a modal dlg, so that needs to be filtered out.
					change_line_rel(1);
            }
            break;
         case page_up:
            change_line_rel(-3);
            break;
         case page_down:
            change_line_rel(3);
            break;
         case up_arrow:
            change_line_rel(-1);
            break;
         case down_arrow:
            change_line_rel(1);
            break;
         case end:
            var foc = $("#tw_input_focus");
            setCaretPosition(foc[0], foc.value.length, 0);
            break;
         case home:
            var foc2 = $("#tw_input_focus");
            setCaretPosition(foc2[0], 0, 0);
            break;
         default:
            var handled = false;
            if (key === kI) {
               if (e.ctrlKey && e.shiftKey === false) {
                  insert_below();
                  handled = true;
               } else if (e.ctrlKey && e.shiftKey) {
                  insert_above();
                  handled = true;
               }
            } else if (key === kY && e.ctrlKey) {
               if (TW.line.canRedo(TW.currLine)) {
					TW.line.doRedo(TW.currLine);
                  lineModified();
               } else if (TW.line.canUndo(TW.currLine)) {
					TW.line.doUndo(TW.currLine);
                  lineModified();
               }
               handled = true;
            }

            if (handled === false) {
               line_changed();
            }
      }
      updateInProcess = false;
   });

   //
   // undo
   //

	body.on("click", ".tw_undo_button", function (e) {
		TW.line.doUndo(TW.currLine);
      lineModified();
   });

	body.on("click", ".tw_redo_button", function (e) {
		TW.line.doRedo(TW.currLine);
      lineModified();
   });

   //
   // Insert
   //

	body.on("click", ".tw_insert_above_button", function (e) {
      insert_above();
   });

	body.on("click", ".tw_insert_below_button", function (e) {
      insert_below();
   });

	YUI().use('node', 'event-delegate', 'resize', function(Y) {
		Y.on("resize", function() {
			redraw();
		}, window);

		//
		// Thumbnail cursor resize
		//
		body.on("click", ".tw_resize_box", function(e) {
			if (imgBoxResize) {
				imgBoxResize.destroy();
				imgBoxResize = undefined;
			} else {
				imgBoxResize = new Y.Resize({
					//Selector of the node to resize
					node: '#tw_pointer_doc'
				});
				imgBoxResize.plug(Y.Plugin.ResizeConstrained, {
					constrain: '#tw_img_full',
					minHeight: 16,
					minWidth: 50
				});
				imgBoxResize.on('resize:end', function(e) {
					var box = imgCursor.getBox(TW.currLine);
					if (box) {
						TW.line.setRect(TW.currLine, box);
						e.preventDefault();
						e.stopPropagation();
					}
				});
			}
			return false;
		});
	});

	setTimeout(function() {
		imgCursor = TW.createImageCursor();
		if (window.TW.currLine !== undefined) {
			change_line_abs(window.TW.currLine);
		}
	}, 1);
});
