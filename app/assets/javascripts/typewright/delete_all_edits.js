// delete_all_edits.js
//
// Requires the general_dialog file's showPartialInLightBox
// requires the calling element has data-url defined, which is the partial to display.

/*global showPartialInLightBox */

jQuery(document).ready(function() {
	"use strict";

	function display_lightbox(node) {
		var url = node.attr('data-url');

        var ok_action = function( ) {
            serverAction({action:{ actions: { method: 'PUT', url: url }}});
        };

        new ConfirmDlg('Delete Edits', 'This will delete any edits made on this page. Are you sure?', 'Ok', 'Cancel', ok_action );
	}

	jQuery("#tw_delete_edits").on("click", function() {
        display_lightbox(jQuery(this));
    });
});
