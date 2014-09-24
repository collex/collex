jQuery(document).ready(function($) {
	"use strict";
	var body = $("body");


	function createTotals(total) {
		$("#search_result_count").text("Search Results (" + window.collex.number_with_delimiter(total)+")");
	}

	function setFederations(federations, selected) {
		var federationCounts = $(".limit_to_federation .num_objects");
		federationCounts.each(function(index, el) {
			el = $(el);
			var fed = el.attr("data-federation");
			if (federations[fed])
				el.text(window.collex.number_with_delimiter(federations[fed]));
			else
				el.text("");
		});
		var federationChecks = $(".limit_to_federation input");
		if (!selected) // The default federation selection is just the current federation.
			selected = [ window.collex.defaultFederation ];

		// Turn the selected array into a hash for easier access
		var selectedHash = {};
		for (var i = 0; i < selected.length; i++) {
			selectedHash[selected[i]] = true;
		}
		federationChecks.each(function(index, el) {
			var name = el.name;
			$(el).prop('checked', selectedHash[name]);
		});
	}

	function hasSearch(obj) {
		for (var key in obj) {
			if (obj.hasOwnProperty(key) && key !== 'srt' && key !== 'dir' && key !== 'f' && key !== 'fuz_t' && key !== 'fuz_q') {
				return false;
			}
		}
		return true;
	}

	function showResultSections(obj) {
		if (hasSearch(obj.query)) {
			// this is a blank page, with no search.
			$(".has-results").hide();
			$(".add_constraint_form").show();
		} else {
			$(".add_constraint_form").hide();
			$(".has-results").show();
			if (obj.hits.length === 0) {
				// there was a search, but there were no results.
				$(".not-empty").hide();
				$(".no_results_msg").show();
			} else {
				// there was a search, and it returned some results.
				$(".not-empty").show();
				$(".no_results_msg").hide();
			}
		}
	}

	function showMessage(message) {
		var el = $(".search_error_message");
		el.text(message);
		if (message && message.length > 0)
			el.show();
		else
			el.hide();
	}

	function fixExpandAllLink() {
		$("#expand_all").show();
		$("#collapse_all").hide();
	}

	var timeoutHandle;
	function imageTimeout() {
		timeoutHandle = setTimeout(function() {
			var spinners = $('.progress_timeout');
			spinners.each(function(index, spinner) {
				spinner.src = $(spinner).attr('data-noimage');
			});
			timeoutHandle = null;
		}, 8000);
	}

	body.bind('RedrawSearchResults', function(ev, obj) {
		if (!obj || !obj.hits || !obj.facets || !obj.query) {
			window.console.log("error redrawing search results", obj);
			return;
		}

		if (timeoutHandle) {
			clearTimeout(timeoutHandle);
			timeoutHandle = null;
		}

		showResultSections(obj);
		showMessage(obj.message);

		window.collex.createResultRows(obj);

		window.collex.createSearchForm(obj.query, obj.facets.role);
		window.collex.createFacets(obj);

		var page = obj.query.page ? obj.query.page : 1;
		window.collex.createPagination(page, obj.total_hits, obj.page_size);

		createTotals(obj.total_hits);
		setFederations(obj.facets.federation, obj.query.f);
		fixExpandAllLink();

		imageTimeout();
	});

	body.bind('DrawHits', function(ev, obj) {
//		showResultSections(obj);
//		showMessage(obj.message);

		window.collex.createResultRows(obj);

//		var page = obj.query.page ? obj.query.page : 1;
//		window.collex.createPagination(page, obj.total_hits, obj.page_size);
//
//		createTotals(obj.total_hits);
//		fixExpandAllLink();

		imageTimeout();
	});
});
