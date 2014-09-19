jQuery(document).ready(function($) {
	"use strict";

	function isSavedSearch() {
		var query = window.location.search;
		query = query.replace(/%20/g, ' ');
		if (query.substr(0,1) === '?')
			query = query.substr(1);
		for (var i = 0; i < window.collex.savedSearches.length; i++) {
			var search = window.collex.savedSearches[i];
			if (search.url === query)
				return search;
		}
		return null;
	}

	function createSavedSearchLink(link) {
		return window.location.origin + "/search?" + link;
	}
	function createSavedSearchPermalink(link) {
		var img = window.pss.createHtmlTag("img", { alt: 'Permalink', src: "/assets/link.jpg", title: "Click here to get a permanent link for this saved search." });
		return window.pss.createHtmlTag("a", { 'class': "nav_link", href: '#', onclick: "window.collex.showString(&quot;" + createSavedSearchLink(link) + "&quot;); return false;" }, img);
	}

	window.collex.drawSavedSearch = function() {
		// do saved search notice
		var savedSearchArea = $("#saved_search_name_span");
		var isLoggedIn = window.collex.currentUserId && window.collex.currentUserId > 0;
		if (isLoggedIn) {
			var search = isSavedSearch();
			if (search) {
				savedSearchArea.html(" : " + search.name + " " + createSavedSearchPermalink(search.url));
			}
			else {
				savedSearchArea.html(window.pss.createHtmlTag("a", {'class': "modify_link", href: '#', onclick: "window.collex.doSaveSearch(); return false;" }, "[save search]"));
			}
		} else {
			var login = window.pss.createHtmlTag("a", {'class': "nav_link", href: '#', onclick: "var dlg = new SignInDlg(); dlg.show('sign_in'); return false;" }, "LOG IN");
			savedSearchArea.html(window.pss.createHtmlTag("span", {'class': "save_search_instruction"}, "(" + login + " to save this search)"));
		}
	};

	window.collex.drawSavedSearchList = function() {
		var target = $(".saved-search-list");
		if (target.length === 0)
			return;

		var maxToShow = 10;
		var numDisplayed = Math.min(maxToShow, window.collex.savedSearches.length);
		var html = "";
		if (numDisplayed !== window.collex.savedSearches.length) {
			html += window.pss.createHtmlTag("div", {'class': "empty_list_text"},
				window.pss.createHtmlTag("span", { 'class': 'hiding-text'}, "Showing the " + numDisplayed + " most recent of your " + window.collex.savedSearches.length + " saved searches. ") +
				window.pss.createHtmlTag("a",
				{ 'class': 'nav_link saved_search_show_all', onclick: "window.collex.showHiddenSavedSearches('saved_search_show_all', 'saved_search_hidden_item' );" }, "[show all]"));
		}
		var table = "";
		if (window.collex.savedSearches.length === 0) {
			table += window.pss.createHtmlTag("tr", {}, window.pss.createHtmlTag("td", {'class': "query_term"}, "No searches saved"));
		} else {
			for (var i = 0; i < window.collex.savedSearches.length; i++) {
				var search = window.collex.savedSearches[i];
				var name = window.pss.createHtmlTag("td", {'class': "query_term"},
					window.pss.createHtmlTag("a", {'class': "nav_link", href: createSavedSearchLink(search.url) }, search.name));
				var removeAction = "serverAction({confirm: { title: 'Saved Search', message: 'Are you sure you want to remove this saved search?' }, action: { actions: this.href }, progress: { waitMessage: 'Please Wait...' }}); return false;";
				var id = search.id ? search.id : search.name;
				var remove = window.pss.createHtmlTag("td", {'class': "query_remove"},
					window.pss.createHtmlTag("a", { 'class': 'modify_link', href: "/search/remove_saved_search?id="+id, post: true, onclick: removeAction }, '[remove]'));
				var options = {};
				if (i >= numDisplayed)
					options['class'] = "saved_search_hidden_item hidden";
				var permalink = window.pss.createHtmlTag("td", {'class': "saved_search_link"},createSavedSearchPermalink(search.url));
				table += window.pss.createHtmlTag("tr", options, name+remove+permalink);
			}
		}
		html += window.pss.createHtmlTag("table", {'class': "query"}, table);
		target.html(html);
	};
});
