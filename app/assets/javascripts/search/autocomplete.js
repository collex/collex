jQuery(document).ready(function($) {
	"use strict";
	var body = $("body");

	function callback(request, response) {
		var self = this.element;
		var url = self.attr('data-autocomplete-url') + '.json';

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

		request.other = window.location.search;
		$.post(url, request).done(success).fail(fail);
	}

	$(".jq-autocomplete").each(function(index, el) {
		var self = $(el);
		self.autocomplete({
			source: callback,
			minLength: 2,
			delay: 500
		});
	});
});
