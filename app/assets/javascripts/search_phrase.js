jQuery(document).ready(function() {
	// TODO-PER: This isn't being called, I think.
	"use strict";
	var body = $("body");

	var isOnSearchPage = jQuery('.search_phrase').length > 0;

	function searchTypeChanged(This) {
		var type = This.value.toLowerCase();
		type = type.gsub(" (yyyy)", '');
		type = type.gsub(' ', '_');
		var valid_types = ['search_keyword', 'search_phrase', 'search_term', 'title', 'editor', 'publisher', 'year'];
		if (valid_types.indexOf(type) > -1) {
			search_phrase_auto_completer.url = '/collex/auto_complete_for_' + type;
		} else {
			search_phrase_auto_completer.url = '/collex/auto_complete_for_search_phrase';
		}
	}

	function on_search_type_change(event, el) {
		var si = el.options.selectedIndex;
		var type = el.options[si].value;
		if (type === 'Language') {
			$('search_phrase').hide();
			$('search_language').show();
		} else {
			$('search_phrase').show();
			$('search_language').hide();
		}
	}

	function add_search_type_events() {
		var st = $$('#search_type');
		if (st.length > 0) {
			st[0].on('change', on_search_type_change);
			on_search_type_change(null, st[0]);
		}
	}

	if (isOnSearchPage) {
		$('search_phrase').defaultValueActsAsHint('<%= default_search_phrase %>');

		var search_phrase_auto_completer = new Ajax.Autocompleter('search_phrase', 'search_phrase_auto_complete', '/collex/auto_complete_for_search_phrase', {minChars: 2});

		add_search_type_events();
	}
});
