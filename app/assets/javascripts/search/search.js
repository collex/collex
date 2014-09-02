/*global History */
/*global GeneralDialog */

jQuery(document).ready(function($) {
	"use strict";
	var body = $("body");

	var progressDlg = null;
	function showProgress() {
		// This puts up a large spinner that can only be canceled through the ajax return status

		var dlgLayout = {
			page : 'spinner_layout',
			rows : [
				[{
					text : ' ',
					klass : 'gd_transparent_progress_spinner'
				}], [{
					rowClass : 'gd_progress_label_row'
				}, {
					text : "Searching...",
					klass : 'transparent_progress_label'
				}]]
		};

		var pgsParams = {
			this_id : "gd_progress_spinner_dlg",
			pages : [dlgLayout],
			body_style : "gd_progress_spinner_div",
			row_style : "gd_progress_spinner_row"
		};
		progressDlg = new GeneralDialog(pgsParams);
		progressDlg.center();
	}

	function getUrlVars() {
		// This returns the query string as a hash of values.
		// If a key appears more than once then it is returned as an array, otherwise as a string.
		// That is, given "?q=tree&gen=2&gen=5", the return object is: { q: "tree", gen: [ "2", "5" ] }
		var params = {};
		var query = ""+window.location.search;
		if (query === "") // If there are no query params at all.
			return params;
		query = query.substr(1);	// get rid of the "?"
		var hashes = query.split('&');
		for(var i = 0; i < hashes.length; i++)
		{
			var hash;
			hash = hashes[i].split('=');
			if (hash.length === 1) // If the form just has "&key&key2" without an equal sign.
				hash.push("");

			var value = decodeURIComponent(hash[1]);
			if (params[hash[0]] !== undefined) {
				if (typeof params[hash[0]] === "string")
					params[hash[0]] = [ params[hash[0]], value ]; // If this is the second occurrence, turn it from a string into an array.
				else
					params[hash[0]].push(value);// If there are multiple occurrences, just keep adding them.
			} else
				params[hash[0]] = value;// For the first, or only occurrence, return it as a string.
		}
		return params;
	}

	function makeQueryString(existingQuery) {
		var arr = [];
		for (var key in existingQuery) {
			if (existingQuery.hasOwnProperty(key)) {
				var val = existingQuery[key];
				if (typeof val === 'string')
					arr.push(key+'='+val);
				else {
					for (var i = 0; i < val.length; i++)
						arr.push(key+'='+val[i]);
				}
			}
		}
		return arr.join('&');
	}

	function onSuccess(resp) {
		resp.query = getUrlVars();
		for (var key in resp.query) {
			if (resp.query.hasOwnProperty(key)) {
				if (!resp.query[key] || resp.query[key].length === 0)
					delete resp.query[key];
			}
		}
		body.trigger('RedrawSearchResults', resp);
		if (progressDlg) {
			progressDlg.cancel();
			progressDlg = null;
		}
	}

	function onError(resp) {
		if (progressDlg) {
			progressDlg.cancel();
			progressDlg = null;
		}
		window.console.error(resp);
	}

	function doSearch() {
		var existingQuery = getUrlVars();
		$.ajax({ url: "/search.json",
			data: existingQuery,
			success: onSuccess,
			error: onError
		});
	}

	History.Adapter.bind(window,'statechange',function(){ // Note: We are using statechange instead of popstate
		History.getState(); // Note: We are using History.getState() instead of event.state
		doSearch();
	});

	function addToQueryObject(newQueryKey, newQueryValue) {
		var existingQuery = getUrlVars();
		if (existingQuery[newQueryKey] === undefined)
			existingQuery[newQueryKey] = newQueryValue;
		else if (typeof existingQuery[newQueryKey] === 'string')
			existingQuery[newQueryKey] = [existingQuery[newQueryKey], newQueryValue];
		else if ($.inArray(newQueryValue, existingQuery[newQueryKey]) === -1)
			existingQuery[newQueryKey].push(newQueryValue);
		return existingQuery;
	}

	function removeFromQueryObject(newQueryKey, newQueryValue) {
		var existingQuery = getUrlVars();
		if (existingQuery[newQueryKey] === undefined)
			return existingQuery; // Nothing to do: the parameter wasn't present
		else if (typeof existingQuery[newQueryKey] === 'string') {
			if (existingQuery[newQueryKey] === newQueryValue)
				delete existingQuery[newQueryKey];
			// If the value didn't match, then there's nothing to do, the parameter wasn't present.
		} else {
			var index = $.inArray(newQueryValue, existingQuery[newQueryKey]);
			if (index !== -1)
				existingQuery[newQueryKey].splice(index, 1);
		}
		return existingQuery;
	}

	function removeSortFromQueryObject() {
		var existingQuery = getUrlVars();
		delete existingQuery.srt;
		delete existingQuery.dir;
		return existingQuery;
	}

	function replaceInQueryObject(newQueryKey, newQueryValue) {
		var existingQuery = getUrlVars();
		existingQuery[newQueryKey] = newQueryValue;
		return existingQuery;
	}

	function createNewUrl(newQueryKey, newQueryValue, action) {
		var existingQuery;
		if (action === 'remove')
			existingQuery = removeFromQueryObject(newQueryKey, newQueryValue);
		else if (action === 'add')
			existingQuery = addToQueryObject(newQueryKey, newQueryValue);
		else
			existingQuery = replaceInQueryObject(newQueryKey, newQueryValue);
		if (newQueryKey !== 'page') // always go back to page 1 when the search changes.
			delete existingQuery.page;

		return "/search?" + makeQueryString(existingQuery);
	}

	function changePage(url) {
		// If the url is the same as the current URL, the history won't actually trigger a page change, so don't do anything.
		var currentLocation = "/search" +window.location.search;
		if (url === currentLocation)
			return;
		showProgress();
		var pageTitle = document.title; // For now, don't change the page title depending on the search.
		History.pushState(null, pageTitle, url);
	}

	body.on("click", ".new_search", function () {
		changePage("/search");
	});

	body.on("click", ".select-facet", function () {
		var el = $(this);
		var newQueryKey = el.attr("data-key");
		var newQueryValue = el.attr("data-value");
		//newQueryValue = encodeURIComponent(newQueryValue);
		var action = el.attr("data-action");
		var url = createNewUrl(newQueryKey, newQueryValue, action);
		changePage(url);
	});

	body.on("change", ".sort select", function () {
		var el = $(this);
		var newQueryKey = el.attr("name");
		var newQueryValue = el.val();
		var url;
		if (newQueryKey === 'srt') {
			if (newQueryValue === 'rel') {
				$(".sort select[name='dir']").hide();
				var newQuery = removeSortFromQueryObject();
				url = "/search?" + makeQueryString(newQuery);
			} else
				$(".sort select[name='dir']").show();
		}
		if (!url) // If it isn't a special case, then create the url normally.
			url = createNewUrl(newQueryKey, newQueryValue, "replace");
		changePage(url);
	});

	function query_add(el) {
		var parent = el.closest('tr');
		var type = parent.find(".query_type_select").val();
		var term = parent.find(".query_term input").val();
		// Remove non-word characters. Unfortunately, JavaScript doesn't do this, so approximate it by including some unicode chars directly.
		term = term.replace(/[^0-9A-Za-z\u00C0-\u017F]/g, ' ');
		term = term.replace(/\s+/g, ' ');
		var not = parent.find(".query_and-not_select").val();
		// TODO-PER: do NOT
		var url = createNewUrl(type, term, "add");
		changePage(url);
	}

	body.on("click", ".query_add", function () {
		query_add($(this));
	});

	body.on("keyup", ".query.search-form input", function(e) {
		var key = e.which;
		if (key === 13) {
			query_add($(this));
		}
	});

	body.on("change", ".limit_to_federation input", function() {
		var feds = $(".limit_to_federation input");
		// If all of the federation checkboxes are checked, then we remove the federation parameter.
		// If none of the federation checkboxes are checked, then we change them to all being checked.
		// Otherwise add the federations that were checked.
		var allChecked = true;
		var noneChecked = true;
		var checkedFeds = [];
		feds.each(function(index, el) {
			if (el.checked) {
				noneChecked = false;
				checkedFeds.push(el.name);
			} else {
				allChecked = false;
			}
		});
		var existingQuery = getUrlVars();
		if (allChecked || noneChecked) {
			delete existingQuery.f;
		} else {
			existingQuery.f = checkedFeds;
		}
		delete existingQuery.page;
		changePage("/search?" + makeQueryString(existingQuery));
	});

	// This replaces the current search with the one passed to it.
	body.bind('SetSearch', function(ev, obj) {
		changePage("/search?" + makeQueryString(obj));
	});

	function initSortControls() {
		var existingQuery = getUrlVars();
		if (existingQuery.srt && existingQuery.srt.length > 0) {
			$(".sort select[name='srt']").val(existingQuery.srt);
			if (existingQuery.dir && existingQuery.dir.length > 0)
				$(".sort select[name='dir']").val(existingQuery.dir);
			$(".sort select[name='dir']").val();
		} else {
			$(".sort select[name='dir']").hide();
		}
	}

	function initializeSearch() {
		// This is called on initial page load.
		if (window.collex && window.collex.pageName === 'search') {
			initSortControls();
			showProgress();
			setTimeout(doSearch, 10);	// allow the progress spinner to appear.
		}
	}
	initializeSearch();
});

