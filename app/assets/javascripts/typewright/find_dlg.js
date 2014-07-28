/*global dialogMaker */
/*global TW */

jQuery(document).ready(function() {
	"use strict";
	var body = jQuery("body");

	function find(dlg) {
		var data = dlg.getAllData();
		var matchString = data.find.toLowerCase();
		dlg.setFlash("Finding " + matchString, false);

		var found = false;
		var i = 0;
		while (!TW.line.isLast(i)) {
			var text = TW.line.getCurrentText(i);
			if (text && text.toLowerCase().indexOf(matchString) >= 0) {
				body.trigger('changeLine:highlight', { lineNum: i, text: data.find });
				found = true;
				break;
			}
			i++;
		}
		if (found) {
			dlg.cancel();
		} else {
			dlg.setFlash("Text not found on page", true);
		}
		return false;
	}

	function find_dlg() {

		var body = { layout: [
				[ { type: 'label', klass: 'tw_dlg_find_label', text: 'Find:' }, { type: 'input', klass: 'tw_dlg_find', name: 'find', focus: true }]
			]
		};

		dialogMaker.dialog({
			config: { id: 'tw_find_dlg', action: "", div: '', align: ".tw_find_button", lineClass: 'tw_dlg_find_line' },
			header: { title: 'Find Text on Page' },
			body: body,
			footer: {
				buttons: [
					{ label: 'ok', action: find, def: true },
					{ label: 'cancel', action: 'cancel' }
				]
			}
		});
	}

	var kH = 72; // 'H'

	jQuery(".tw_find_button").on("click", function() {
		find_dlg();
    });

	function keyHandler(ev) {
		if (ev.keyCode === kH && ev.shiftKey && ev.ctrlKey)
			find_dlg();
	}

	body.on("keyup", keyHandler);
});

