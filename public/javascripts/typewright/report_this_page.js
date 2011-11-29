// report_this_page.js
//
// Requires the general_dialog file's showPartialInLightBox
// requires the calling element has data-url defined, which is the partial to display.

/*global YUI */
/*global showPartialInLightBox */

YUI().use('node', function(Y) {
	function display_lightbox(node) {
		var url = node._node.getAttribute('data-url');
		showPartialInLightBox(url, 'Report an Issue on This Page', '/images/ajax_loader.gif');

	}

    Y.on("click", function(e) {
        display_lightbox(e.target);
    }, "#tw_report_page");
});
