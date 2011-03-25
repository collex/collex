// select_page.js
//
// Requires the html element: <select id='page' data-url='URL'>
// Assumes that the server recognizes the URL: URL PAGENUM

/*global YUI */
/*global window */

YUI().use('node', function(Y) {
	function select_page(node) {
		var url = node._node.getAttribute('data-url');
		var sel = node._node.value;
		window.location = url + sel;

	}

    Y.on("change", function(e) {
        select_page(e.target);
    }, "#tw_page");
});
