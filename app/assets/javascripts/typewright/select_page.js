// select_page.js
//
// Requires the html element: <select id='page' data-url='URL'>
// Assumes that the server recognizes the URL: URL PAGENUM

/*global window */

jQuery(document).ready(function() {
	"use strict";
	function select_page(node) {
		var url = node.attr('data-url');
		var sel = node.val();
		window.location = url + sel;

	}

	jQuery("body").on("change", "#tw_page", function() {
		select_page(jQuery(this));
	});
});
