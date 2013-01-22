// This controls the plus / minus image on a tree control. It toggles showing or hiding a related div.
//
// Expectations:
// The control should look like this: <div class="expander" data-target="whatever"></div>
// Then there should be a matching <div id="whatever"> that will be what is hidden and shown.
//
// This css is required (an image with plus and minus stacked on top of each other and a position for the minus image and a class that hides the div.)
//
//.expander {
//	background-image: url('../images/tree_btn.png');
//	padding-right: 9px;
//	padding-bottom: 9px;
//}
//
//.contracter {
//	background-position: 0 -9px;
//}
//
//.hidden {
//	display: none;
//}

/*global YUI */
YUI().use('node', "io-base", function(Y) {

	function toggle(node) {
		var target = '#' + node.getAttribute("data-target");
		var contract = node.hasClass('contracter');
		if (contract) {
			node.removeClass('contracter');
			var div = Y.one(target);
			div.addClass('hidden');
		} else {
			node.addClass('contracter');
			var div = Y.one(target);
			div.removeClass('hidden');
		}
		var notice = node.getAttribute("data-notice-url");
		if (notice) {
			notice += (notice.indexOf('?')) ? '&' : '?';
			notice += "expanded=" + !contract;
			Y.io(notice);
		}
	}

	Y.delegate("click", function(e) {
		toggle(e.target);
	}, 'body', ".expander");
});
