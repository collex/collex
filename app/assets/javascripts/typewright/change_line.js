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

   function setButtons() {
      var undo = $('.tw_undo_button');
      var redo = $('.tw_redo_button');
      var cor = $('.tw_correct');
      var del = $('.tw_delete_line');

      if (TW.line.canRedo(TW.currLine)) {
          undo.addClass('hidden');
          redo.removeClass('hidden');
      } else if (TW.line.canUndo(TW.currLine)) {
          undo.removeClass('hidden');
          redo.addClass('hidden');
      } else {
          undo.addClass('hidden');
          redo.addClass('hidden');
      }

      if( TW.line.isInRange(TW.currLine) === false ) {
          if( cor ) cor.addClass('hidden');
          if( del ) del.addClass('hidden');
      } else {
          if( cor ) cor.removeClass('hidden');
          if (cor) cor.removeClass('disabled');
          if( del ) del.removeClass('hidden');
      }
   }

	function ajaxCall(data, success, error) {
		data.token = TW.token;
		$.ajax({
			url: TW.updateUrl,
			type: 'PUT',
			data: data,
			async: false,
			beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', jQuery('meta[name="csrf-token"]').attr('content'));},
			dataType: 'json',
			success: success,
			error: error
		});
	}

	function serverResponse(data, textStatus, jqXHR) {
		if (data.edit_line !== undefined) {
			TW.line.setEditTime(data.edit_line, data.edit_time, data.exact_time);
		}
		reportLiveChanges(data);
	}

	var currentEditors = { doc: [], page: []};

	function formatUserName(username, id, idle_time, page) {
		var html = '<a href="#" class="nav_link" onclick="showPartialInLightBox(\'/my_collex/show_profile?user=' + id + '\', \'Profile for ' + username + '\', \'\'); return false;">' + username + '</a>';
		var secs = Math.round(idle_time % 60);
		idle_time /= 60;
		var min = Math.round(idle_time % 60);
		idle_time /= 60;
		var hours = Math.round(idle_time % 24);
		idle_time /= 24;
		var days = Math.round(idle_time);
		html += " (" + days + " " + hours + ":" + min + ":" + secs +")";
		if (page)
			html += " (page: " + page + ")";
		return html;
	}

	function redrawLiveChanges() {
		var changes = "";
		if (TW.line.numUndisplayedChanges() > 0) {
			var changeStr = TW.line.numUndisplayedChanges() === 1 ? 'There has been 1 conflicting change' : 'There have been ' + TW.line.numUndisplayedChanges() + ' conflicting changes';
			changes = '<div><button class="tw_icon tw_icon_edit_history_new tw_apply_new_data"></button><span class="tw_stale_data_note">' + changeStr + ' to this page. Click the button to update.</span></div>';
		}
		//		data.lines.forEach(function(line) {
		//			var str = line.line + ": " + line.author + " " + line.action + " " + line.date + " " + line.text;
		//			changes += "<br>" + str;
		//		});
		var editors = "";
		if (currentEditors.page.length > 0) {
			editors += "<h3>The following people are currently editing this page:</h3>";
			for (var i = 0; i < currentEditors.page.length; i++) {
				var page_user = currentEditors.page[i];
				editors += formatUserName(page_user.username, page_user.federation_user_id, page_user.idle_time) + "<br>";
			}
		}
		if (currentEditors.doc.length > 0) {
			editors += "<h3>The following people are currently editing other pages in this document:</h3>";
			for (var j = 0; j < currentEditors.doc.length; j++) {
				var doc_user = currentEditors.doc[j];
				editors += formatUserName(doc_user.username, doc_user.federation_user_id, doc_user.idle_time, doc_user.page) + "<br>";
			}
		}
		if (currentEditors.page.length === 0 && currentEditors.doc.length === 0)
			editors += "No one else is currently editing this document.";

		var status = $('.tw_live_status');
		if (TW.line.numUndisplayedChanges() > 0 || currentEditors.page.length > 0 || currentEditors.doc.length > 0) {
			var statusBody = status.find(".tw_body");
			statusBody.html(changes + "<br>" + editors);
			status.show();
			redraw();	// This is to update the history icon and tooltip.
		} else
			status.hide();
	}

	function reportLiveChanges(data) {
      if (data.lines.length > 0) {
         var myEdit = true;
         var currUser = $("#curr-user-name").text();
         $.each(data.lines, function(idx, val) {
            if (val.author != currUser) {
               myEdit = false;
            }
         });

         if (myEdit == false) {
            var currUser = $("#curr-user-name").text();
            TW.line.liveUpdate(data.lines);
            TW.line.integrateRemoteChanges(false);
            var growler = $(".tw_notification");
            growler.find('.tw_notification_text').html(
                  "This page has been edited by someone else.");
            growler.fadeIn("slow");
            setTimeout(function() {
               growler.fadeOut("slow");
            }, 3000);
         }
      }
      currentEditors = data.editors;
      redrawLiveChanges();
   }

	function serverError(jqXHR, textStatus, errorThrown) {
		var status = $('.tw_live_status');
		var statusBody = status.find(".tw_body");
		statusBody.html(errorThrown.message);
		status.show();
	}

	function updateServer() {
		if (TW.line.isDirty(TW.currLine)) {
			var params = TW.line.serialize(TW.currLine);
			params.page = TW.page;

			ajaxCall({params: JSON.stringify(params)}, serverResponse, serverError);
			TW.line.setClean(TW.currLine);
		}
	}

	function pingTypeWright(loadTime) {
		ajaxCall({ ping: true, document_id: TW.doc_id, page: TW.page, load_time: loadTime }, reportLiveChanges, serverError);
	}

	function signOutOfTypeWright() {
		ajaxCall({ unload: true });
	}

   function tooltipIcon(iconStyle, tooltipText) {
      return "<span class='tw_icon " + iconStyle + " tw_history_tooltip_wrapper'>&nbsp;<span class='tw_tooltip hidden'>" + tooltipText + "</span></span>";

   }

	function createHistory(lineNum) {
		var str = TW.line.getAllHistory(lineNum);
		if (str) {
			var isStale = TW.line.lineIsStale(lineNum);
			var klass = isStale ? "tw_icon_edit_history_new" :"tw_icon_edit_history";
			return tooltipIcon(klass, "<h4 class='header'>History:</h4><hr />" + str);
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
      setButtons();
   }

	function redrawCurrLine() {
        redrawCurrIcons();
		var elHist = $('#tw_text_1 .tw_history_icon');
		var elNum = $('#tw_text_1 .tw_line_num');
		elHist.html(createHistory(TW.currLine));
		elNum.html(create_display_line(TW.line.getLineNum(TW.currLine)));
		var displayLine = TW.line.getCurrentText(TW.currLine).replace(/\"/g, "&quot;");

		var justDeleted = TW.line.isJustDeleted(TW.currLine);
		var isStale = TW.line.lineIsStale(TW.currLine);
		var isDeleted = TW.line.isDeleted(TW.currLine);
        var isReadOnly = TW.line.isEof(TW.currLine);

		var attrs = [];
		attrs.push("id=\"tw_input_focus\"");
		attrs.push("type=\"text\"");
		if (justDeleted || isStale || isReadOnly )
			attrs.push("readonly=\"readonly\"");
		if (isDeleted || isStale) {
			attrs.push("value=\"\"");
			attrs.push("placeholder=\"" + displayLine + "\"");
			attrs.push("class=\"tw_deleted_line_text\"");
		} else
			attrs.push("value=\"" + displayLine + "\"");
		if (justDeleted)
			attrs.push("class=\"tw_deleted_line\"");

		var editingLine = $("#tw_editing_line");
		editingLine.html("<input " + attrs.join(' ') + " />");

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
          if (TW.line.isEof(TW.currLine) === true ) {
              elText.html('');
          } else {
              elText.html('-- bottom of page --');
          }
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
             set_line(newLineNum)
         }
      } else {
         // are we at the bottom of the page?
         if( newLineNum >= TW.lines.length ) {
             // and we are not already at the special end of file line
             if( ( window.TW.currLine !== undefined ) && ( TW.line.isEof( TW.currLine ) === false ) ) {
                 set_line(TW.lines.length);
             }
         }
      }
   }

   function set_line( newLineNum ) {
       if (TW.line.hasChanged(TW.currLine)) {
           updateServer();
       }
       TW.currLine = newLineNum;
       redraw();
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
      // ignore inserts when we are on the last (placeholder) line
      if( TW.line.isEof( TW.currLine ) === true ) return;

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

    // Chrome, IE, Opera, Safari
	body.on("mousewheel", ".tw_editing, #tw_input_focus, #tw_img_full, #tw_pointer_doc", function(e) {
		var delta = e.originalEvent.wheelDelta / 120;
		change_line_rel(-delta);
		e.preventDefault();
		e.stopPropagation();
	});

    // FF
    body.on("DOMMouseScroll", ".tw_editing, #tw_input_focus, #tw_img_full, #tw_pointer_doc", function(e) {
        var delta = e.originalEvent.detail;
        change_line_rel(delta);
        e.preventDefault();
        e.stopPropagation();
    });

	body.on("click", "#tw_img_thumb", function (e) {
      var coords = imgCursor.convertThumbToOrig(e.clientX, e.clientY);
      var lineNum = TW.line.findLine(coords.x, coords.y);
      change_line_abs(lineNum);
   });

	$(window).unload(function() {
		// Careful! This is called when any page unloads, not just the TypeWright edit pages, so first see if TypeWright is active.
		if (TW.updateUrl === undefined)
			return;
		if (TW.currLine !== undefined && TW.line.hasChanged(TW.currLine)) {
			updateServer();
		}
		signOutOfTypeWright();
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
		// Cancel the default functioning of the keys that we will be handling below.
		var key = e.which;
		switch (key) {
			case enter:
			case page_up:
			case page_down:
			case up_arrow:
			case down_arrow:
			case end:
			case home:
				return false;
		}
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
            setCaretPosition(foc[0], foc.val().length, 0);
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

	//
	// Live Update
	//

	body.on("click", ".tw_apply_new_data", function () {
		TW.line.integrateRemoteChanges(true);
		redrawLiveChanges();
	});

	if (TW.updateUrl !== undefined) {
		var idleTimeoutMilliseconds = 30000; // 30 seconds
		setInterval(pingTypeWright, idleTimeoutMilliseconds);
	}

	body.on("click", ".tw_dismiss", function () {
		$(".tw_notification").fadeOut("slow");
		return false;
	});

	// This happens on page load just after everything is loaded.
	// WARNING: This call happens for every page load, not just TypeWright edit pages, so ignore it if we aren't editing.
	setTimeout(function() {
		if (TW.updateUrl === undefined)
			return;
		imgCursor = TW.createImageCursor();
		if (window.TW.currLine !== undefined) {
			change_line_abs(window.TW.currLine);
		}
		pingTypeWright(window.TW.loadTime);
		$("#tw_input_focus").focus();
		// TODO-PER: Something is stealing the focus away and I can't find it, so I'll just steal it back.
		setTimeout(function() {
			$("#tw_input_focus").focus();
		}, 1000);

	}, 1);
});
