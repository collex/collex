// typewright.js
//
// Contains js for typewright plugin entry points.
// Requires the html element: <span class='typewright_edit' href='XXX' data-logged-in=true|false>
// Assumes that the server recognizes the URL in href
// Requires SignInDlg

/*global YUI */
/*global SignInDlg */
/*global gotoPage */

YUI().use('node', function(Y) {
	function callback(node) {
		var is_logged_in = node._node.getAttribute('data-logged-in') === 'true';
		var link = node._node.getAttribute('href');

		if (!is_logged_in) {
			var dlg = new SignInDlg();
			dlg.setInitialMessage("Please log in to begin editing");
			dlg.setRedirectPageToCurrentWithParam('script=doTypewright&uri='+link.replace(/&/g, '%26'));
			dlg.show('sign_in');
			return;
		}

		gotoPage(link);
	}

    Y.on("click", function(e) {
        callback(e.target);
    }, ".typewright_edit");
});
