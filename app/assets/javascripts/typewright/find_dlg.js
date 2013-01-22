/*global YUI */
/*global dialogMaker */
/*global line */

YUI().use('node', 'event-delegate', 'event-key', 'event-custom', function(Y) {

	function find(dlg) {
		var data = dlg.getAllData();
		var matchString = data.find.toLowerCase();
		dlg.setFlash("Finding " + matchString, false);

		var found = false;
		var i = 0;
		while (!line.isLast(i)) {
			var text = line.getCurrentText(i);
			if (text && text.toLowerCase().indexOf(matchString) >= 0) {
				Y.Global.fire('changeLine:highlight', i, data.find);
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

	var kH = 72;

    Y.on("click", function(e) {
		find_dlg();
    }, ".tw_find_button");

	Y.on('key', function(e) {
		e.halt();
		find_dlg();
	}, 'body', 'down:'+kH+'+shift+ctrl', Y);

});

