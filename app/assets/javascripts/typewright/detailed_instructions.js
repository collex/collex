// detailed_instructions.js
//
// Requires the general_dialog file's showPartialInLightBox
// requires the calling element has data-url defined, which is the partial to display.

/*global showPartialInLightBox */

jQuery(document).ready(function() {
	"use strict";
	function display_lightbox(node) {
		var url = node.attr('data-url');
		var title = node.attr('data-title');
		showPartialInLightBox(url, title, '/assets/ajax_loader.gif');

	}

	jQuery(".show-in-lightbox").on("click", function() {
        display_lightbox(jQuery(this));
    });
});
