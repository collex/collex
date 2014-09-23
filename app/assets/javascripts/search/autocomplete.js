jQuery(document).ready(function($) {
	"use strict";
	var body = $("body");

	function callback(request, response) {
		var self = this.element;
		var url = self.attr('data-autocomplete-url') + '.json';
		var fieldSelector = self.attr('data-autocomplete-field');
		var csrf_param = $('meta[name=csrf-param]')[0].content;
		var csrf_token = $('meta[name=csrf-token]')[0].content;

		function success(resp) {
			// The response is an array of suggestions. The suggestions are an array.
			// The first item in the suggestion array is the term and the second item is the count.
			var suggestions = [];
			for (var i = 0; i < resp.length; i++) {
				var suggestion = resp[i];
				suggestions.push({ label: suggestion[0] + ' (' + suggestion[1] + ')', value: suggestion[0] });
			}
			response(suggestions);
		}

		function fail() {
			// Just silently fail.
			response([]);
		}

		request.other = window.collex.removeSortAndPageFromQueryObject();
		request.field = fieldSelector ? $(fieldSelector).val() : 'q';
		request.term = window.collex.sanitizeString(request.term);
		request[csrf_param] = csrf_token;
		var autoCompleteFields = [ 'q', 't', 'aut', 'ed', 'pub'];
		var autoCompleteOk = false;
		for (var i = 0; !autoCompleteOk && i < autoCompleteFields.length; i++)
			if (request.field === autoCompleteFields[i])
				autoCompleteOk = true;
		// Also, don't try autocomplete on more than one word: the solr index doesn't support that.
		if (autoCompleteOk && request.term.length > 2 && request.term.indexOf(' ') === -1)
			$.post(url, request).done(success).fail(fail);
	}

	window.collex.initAutoComplete = function(el) {
		var self = $(el);
		self.autocomplete({
			source: callback,
			minLength: 2,
			delay: 500
		});
	};

	$(".jq-autocomplete").each(function(index, el) {
		window.collex.initAutoComplete(el);
	});
});
