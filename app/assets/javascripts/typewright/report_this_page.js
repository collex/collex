// report_this_page.js
//
// Requires the general_dialog file's showPartialInLightBox
// requires the calling element has data-url defined, which is the partial to display.

/*global showPartialInLightBox */

jQuery(document).ready(function() {
	"use strict";
	function display_lightbox(node) {
		var url = node.attr('data-url');
		showPartialInLightBox(url, 'Report an Issue on This Page', '/assets/ajax_loader.gif');

	}

	jQuery("#tw_report_page").on("click", function() {
        display_lightbox(jQuery(this));
    });
});
