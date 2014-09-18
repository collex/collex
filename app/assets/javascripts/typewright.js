// typewright.js
//
// Contains js for typewright plugin entry points.
// Requires the html element: <span class='typewright_edit' href='XXX' data-logged-in=true|false>
// Assumes that the server recognizes the URL in href
// Requires SignInDlg

/*global SignInDlg */

jQuery(document).ready(function($) {
	"use strict";

	$(".log-in-first-link").on("click", function() {
		var isLoggedIn = window.collex && window.collex.currentUserId && window.collex.currentUserId > 0;
		if (isLoggedIn)
			return;

		var el = $(this);
		var prompt = el.attr('data-login-prompt');
		var dlg = new SignInDlg(prompt);
		dlg.setInitialMessage("Please log in to begin editing");
		dlg.setRedirectPage = this.href;
		//dlg.setRedirectPageToCurrentWithParam('script=doTypewright&uri='+link.replace(/&/g, '%26'));
		dlg.show('sign_in');
    });

	function onSuccess(resp) {
		var el = this;
		el.html(resp);
	}

	var lazyLoad = $(".lazy-load");

	for (var i = 0; i < lazyLoad.length; i++) {
		var el = $(lazyLoad[i]);
		var action = el.attr("data-action");
		$.ajax(action, {
			context: el,
			success: onSuccess
		});
	}
});
