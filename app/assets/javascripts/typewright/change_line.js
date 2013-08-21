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
   console.log("CHANGE_LINE LOADED " + new Date());
   function create_display_line(str) {
      var newStr = '' + str;
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
         params = Y.QueryString.stringify(params, {
            arrayKey : true
         });
         serverNotify(updateUrl, params);

      });
   }

   var updateServerSync = function() {
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
         case 'change':
            return tooltipIcon("tw_icon_edit", "Originally: " + line.getStartingText(lineNum));
         case 'delete':
            return tooltipIcon("tw_icon_delete", 'Line has been deleted.');
         case 'correct':
            return tooltipIcon("tw_icon_checkmark", 'Line is correct.');
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
      var displayLine = line.getCurrentText(currLine).replace(/\"/g, "&quot;");

      var editingLine = Y.one("#tw_editing_line");
      if (line.isDeleted(currLine)) {
         editingLine._node.innerHTML = "<input id=\"tw_input_focus\" class=\"tw_deleted_line\" readonly=\"readonly\" type=\"text\" value=\"" + displayLine + "\" />";
      } else {
         editingLine._node.innerHTML = "<input id=\"tw_input_focus\" type=\"text\" value=\"" + displayLine + "\" />";
      }

      var foc = Y.one("#tw_input_focus");
      foc.focus();
   }

   function lineModified() {
      redrawCurrLine();
      updateServer();
   }

   function line_changed() {
      var input = Y.one("#tw_input_focus");
      if (input) {
         if (line.doRegisterLineChange(currLine, input._node.value)) {
            redrawCurrIcons();
         }
      }
   }

   function redraw() {
      if (window.currLine === undefined) {
         return;
      }
      // Must not be on a typewright page.
      var elHist = Y.one('#tw_text_0 .tw_history_icon');
      var elChg = Y.one('#tw_text_0 .tw_change_icon');
      var elNum = Y.one('#tw_text_0 .tw_line_num');
      var elText = Y.one('#tw_text_0 .tw_text');
      if (currLine > 0) {
         elHist._node.innerHTML = createHistory(currLine - 1);
         elChg._node.innerHTML = createIcon(currLine - 1);
         elNum._node.innerHTML = create_display_line(line.getLineNum(currLine - 1));
         elText._node.innerHTML = create_jump_link(line.getCurrentText(currLine - 1), -1, line.isDeleted(currLine - 1));
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
         elHist._node.innerHTML = createHistory(currLine + 1);
         elChg._node.innerHTML = createIcon(currLine + 1);
         elNum._node.innerHTML = create_display_line(line.getLineNum(currLine + 1));
         elText._node.innerHTML = create_jump_link(line.getCurrentText(currLine + 1), 1, line.isDeleted(currLine + 1));
      } else {
         elHist._node.innerHTML = '';
         elChg._node.innerHTML = '';
         elNum._node.innerHTML = '';
         elText._node.innerHTML = '-- bottom of page --';
      }

      // Get the original/full size of the image so we know how to much to scale.
      imgCursor.update();
   }

   function change_line_abs(newLineNum) {
      if (line.isInRange(newLineNum)) {
         if (window.currLine !== undefined) {
            if (line.hasChanged(currLine)) {
               updateServer();
            }
            currLine = newLineNum;
            redraw();
         }
      }
   }

   function change_line_rel(amount) {
      change_line_abs(currLine + amount);
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
      line.doInsert(currLine);
      redraw();
      updateServer();
   }

   function insert_below() {
      line.doInsert(currLine + 1);
      currLine++;
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

   Y.Global.on("imageCursor:loaded", function(e) {
      console.log("CHANGE_LINE ON_LOAD " + new Date());
      setTimeout( function() {
         if (window.currLine !== undefined) {
            change_line_abs(window.currLine);
         } else {
            console.log("UNDEFINED CURRLINE");
         }
      }, 100);
   }, window);

   Y.on('mousewheel', function(e) {
      // The mouse wheel should work any time the input has the focus even if the wheel isn't over it.
      var isInEditingArea = e.target.ancestor('.tw_editing') !== null;
      var isScrollTarget = (e.target._node.parentElement.id === 'tw_img_full' || isInEditingArea || e.target._node.id === 'tw_pointer_doc');
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
      if (window.currLine === undefined) {
         return;
      }
      if (line.hasChanged(currLine)) {
         updateServerSync();
      }
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
      var key = e.charCode;
      switch (key) {
         case backspace:
            if (e.ctrlKey) {
               line.doDelete(currLine);
               lineModified();
            } else {
               line_changed();
            }
            break;
         case kDelete:
            if (e.ctrlKey) {
               line.doDelete(currLine);
               lineModified();
            } else {
               line_changed();
            }
            break;
         case enter:
            if (e.ctrlKey) {
               line.doConfirm(currLine);
               lineModified();
            } else {
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
            var foc = Y.one("#tw_input_focus");
            setCaretPosition(foc._node, foc._node.value.length, 0);
            break;
         case home:
            var foc2 = Y.one("#tw_input_focus");
            setCaretPosition(foc2._node, 0, 0);
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
               if (line.canRedo(currLine)) {
                  line.doRedo(currLine);
                  lineModified();
               } else if (line.canUndo(currLine)) {
                  line.doUndo(currLine);
                  lineModified();
               }
               handled = true;
            }

            if (handled === false) {
               line_changed();
            }
      }
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
      if (window.currLine === undefined) {
         return;
      }
      if (line.hasChanged(currLine)) {
         updateServer();
      }
   }, "body");

   Y.on("resize", function(e) {
      redraw();
   }, window);
});
