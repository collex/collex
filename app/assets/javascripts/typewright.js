// typewright.js
//
// Contains js for typewright plugin entry points.
// Requires the html element: <span class='typewright_edit' href='XXX' data-logged-in=true|false>
// Assumes that the server recognizes the URL in href
// Requires SignInDlg

/*global SignInDlg */
/*global gotoPage */

//jQuery(document).ready(function($) {
//	"use strict";
//	function callback(node) {
//		var is_logged_in = node.attr('data-logged-in') === 'true';
//		var link = node.attr('href');
//
//		if (!is_logged_in) {
//			var dlg = new SignInDlg();
//			dlg.setInitialMessage("Please log in to begin editing");
//			dlg.setRedirectPageToCurrentWithParam('script=doTypewright&uri='+link.replace(/&/g, '%26'));
//			dlg.show('sign_in');
//			return;
//		}
//
//		gotoPage(link);
//	}
//
//	$(".typewright_edit").on("click", function() {
//        callback($(this));
//    });
//});
