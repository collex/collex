jQuery(document).ready(function($) {
	"use strict";

	function searchFormType(key) {
		var types = {
			a: 'Archive',
			discipline: 'Discipline',
			g: 'Genre',
			q: 'Search Term',
			doc_type: 'Format',
			t: "Title",
			aut: "Author",
			ed: 'Editor',
			pub: "Publisher",
			art: 'Artist',
			own: 'Owner',
			y: 'Year',
			lang: 'Language',
			fuz_q: 'Search Term Fuzziness',
			fuz_t: 'Title Fuzziness'
		};
		if (types[key])
			return types[key];
		return key;
	}

	function searchNot(key, val) {
		var a = window.pss.createHtmlTag("option", {}, 'AND');
		var opt = {};
		if (val && val.length > 0 && val[0] === '-')
			opt.selected = 'selected';
		var n = window.pss.createHtmlTag("option", opt, 'NOT');
		opt = {};
		if (key)
			opt['data-key'] = key;
		if (val)
			opt['data-val'] = val;
		return window.pss.createHtmlTag("select", opt, a+n);
	}

	function searchRemove(key, value) {
		return window.pss.createHtmlTag("button", {'class': "trash select-facet", 'data-key': key, 'data-value': value, 'data-action': 'remove' }, '<img alt="Remove Term" src="/assets/lvl2_trash.gif">' );

	}

	function newSearchTerm() {
		var searchTypes = [ ['Search Term', 'q'], ['Title', 't'] ];
		if (window.collex.hasFuzzySearch) {
			searchTypes.push(['Language', 'lang']);
			searchTypes.push(['Year (YYYY)', 'y']);
			// TODO-PER: get the roles that are in the facets.
		} else {
			searchTypes.push(['Author', 'aut']);
			searchTypes.push(['Editor', 'ed']);
			searchTypes.push(['Publisher', 'pub']);
			searchTypes.push(['Artist', 'art']);
			searchTypes.push(['Owner', 'own']);
			searchTypes.push(['Year (YYYY)', 'y']);
		}
		var selectTypeOptions = "";
		for (var i = 0; i < searchTypes.length; i++)
			selectTypeOptions += window.pss.createHtmlTag("option", {value: searchTypes[i][1] }, searchTypes[i][0]);
		var selectType = window.pss.createHtmlTag("select", {'class': "query_type_select" }, selectTypeOptions); // TODO-PER: onchange='searchTypeChanged(this);'
		var searchBox = window.pss.createHtmlTag("input",
			{ 'class': "add-autocomplete", type: 'text', placeholder: "click here to add new search term", 'data-autocomplete-url': "/search/auto_complete_for_q", 'data-autocomplete-field': ".query_type_select", autocomplete: 'off' }) +
			window.pss.createHtmlTag("div", {'class': "auto_complete", id: "search_phrase_auto_complete", style: "display: none;" }, '');
		var submitButton = window.pss.createHtmlTag("button", { 'class': "query_add" }, 'Add');
		return window.pss.createHtmlTag("tr", { 'class': 'new-search-term' },
			window.pss.createHtmlTag("td", {'class': "query_type" }, selectType) +
			window.pss.createHtmlTag("td", {'class': "query_term" }, searchBox) +
			window.pss.createHtmlTag("td", {'class': "new-query_and-not" }, searchNot()) +
			window.pss.createHtmlTag("td", { 'class': "query_remove" }, submitButton) );
	}

	function createFuzzyRadio(key, value, text, isSelected) {
		var params = { type: 'radio', name: key, value: value, id: key+value };
		if (isSelected)
			params.checked = "checked";
		return window.pss.createHtmlTag("input", params) +
			window.pss.createHtmlTag("label", { for: key+value }, text);
	}

	window.collex.createSearchForm = function(query) {
		var table = $('.search-form');
		var html = "";
		var htmlBottom = "";
		var isEmpty = true;
		for (var key in query) {
			if (query.hasOwnProperty(key) && key !== 'page' && key !== 'srt' && key !== 'dir' && key !== 'f') {
				var values = (typeof query[key] === 'string') ? [ query[key] ] : query[key];
				for (var i = 0; i < values.length; i++) {
					var value = values[i];
					var displayedKey = key;
					if (key === 'a') {
						var a = window.collex.getArchive(value);
						if (a) value = a.name;
					} else if (key === 'o') {
						switch (value) {
							case 'typewright': displayedKey = 'TypeWright'; value = 'Only resources that can be edited.'; break;
							case 'freeculture': displayedKey = 'Free Culture'; value = 'Only resources that are freely available in their full form.'; break;
							case 'fulltext': displayedKey = 'Full Text'; value = 'Only resources that contain full text.'; break;
						}
					}
					isEmpty = false;
					var displayedValue = value;
					if (displayedValue && displayedValue[0] === '-')
						displayedValue = displayedValue.substr(1);
					if (key === 'q' || key === 't' || key === 'aut' || key === 'ed' || key === 'pub' || key === 'art' || key === 'own' || key === 'y') {
						displayedValue = window.pss.createHtmlTag("a", {'class': "modify_link query-editable", href: '#', 'data-type': key}, displayedValue);
					}
					if (key === 'lang') {
						var langSelect = $('.search_language option');
						for (var j = 0; j < langSelect.length; j++) {
							var option = $(langSelect[j]);
							if (option.val() === displayedValue)
								displayedValue = option.text();
						}
					}
					if (key.indexOf('role_') === 0) {
						var roleSelect = $('.search_role_type option');
						for (var k = 0; k < roleSelect.length; k++) {
							var option2 = $(roleSelect[k]);
							if (option2.val() === displayedKey)
								displayedKey = option2.text();
						}
					}
					if (key.indexOf('fuz_') === 0) {
						var type = key.split('_')[1];
						if (query[type]) { // Only show the tuner if a query of the same type is also being made.
							var options = createFuzzyRadio(key, '1', "Exact Match", displayedValue === '1') +
								createFuzzyRadio(key, '2', "Some Variance", displayedValue === '2') +
								createFuzzyRadio(key, '3', "More Variance", displayedValue === '3');

							displayedValue = window.pss.createHtmlTag("span", { 'class': 'mod-fuzzy' }, options);
							htmlBottom += window.pss.createHtmlTag("tr", {},
								window.pss.createHtmlTag("td", {'class': "query_type"}, searchFormType(displayedKey)) +
								window.pss.createHtmlTag("td", {'colspan': '3', 'class': "query_term"}, displayedValue));
						}
					} else {
						html += window.pss.createHtmlTag("tr", {},
							window.pss.createHtmlTag("td", {'class': "query_type"}, searchFormType(displayedKey)) +
							window.pss.createHtmlTag("td", {'class': "query_term"}, displayedValue) +
							window.pss.createHtmlTag("td", {'class': "query_and-not"}, searchNot(key, value)) +
							window.pss.createHtmlTag("td", {'class': "query_remove"}, searchRemove(key, value)));
					}
				}
			}
		}
		html += htmlBottom;
		html += newSearchTerm();
		table.html(html);
		table.find('.add-autocomplete').each(function(index, el) { window.collex.initAutoComplete(el); });

		// do saved search notice
		if (isEmpty)
			$("#saved_search_name_span").html("");
		else
			window.collex.drawSavedSearch(isEmpty);
		window.collex.drawSavedSearchList();
	};
});
