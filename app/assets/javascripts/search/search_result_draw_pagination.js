jQuery(document).ready(function($) {
	"use strict";

	window.collex.createPagination = function(curr_page, total, page_size) {
		var html = "";
		total = parseInt(total, 10);
		page_size = parseInt(page_size, 10);
		curr_page = parseInt(curr_page, 10);
		var num_pages = Math.ceil(total / page_size);
		var pagination = $('.pagination');

		// If there's only one page, don't show any pagination
		if (num_pages === 1) {
			pagination.html(html);
			return;
		}

		//Show only a maximum of 11 items, with the current item centered if possible.
		//First figure out the start and end points we want to display.
		var first;
		var last;
		if (num_pages < 11) {
			first = 1;
			last = num_pages;
		} else {
			first = curr_page - 5;
			last = curr_page + 5;
			if (first < 1) {
				first = 1;
				last = first + 10;
			}
			if (last > num_pages) {
				last = num_pages;
				first = last - 10;
			}
		}

		if (first > 1) {
			html += window.collex.create_facet_button('first', '1', "replace", 'page');
			html += "&nbsp;&nbsp;";
		}

		if (curr_page > 1) {
			html += window.collex.create_facet_button('<<', curr_page - 1, "replace", 'page');
			html += "&nbsp;&nbsp;";
		}

		for (var pg = first; pg <= last; pg++) {
			if (pg === curr_page)
				html += window.pss.createHtmlTag("span", { 'class': "current_serp" }, pg);
			else
				html += window.collex.create_facet_button(pg, pg, "replace", 'page');
			html += "&nbsp;&nbsp;";
		}

		if (last < num_pages) {
			html += "...&nbsp;&nbsp;";
			if (num_pages > 12)
				html += window.collex.create_facet_button(num_pages, num_pages, "replace", 'page');
			html += "&nbsp;&nbsp;";
		}

		if (curr_page < num_pages) {
			html += window.collex.create_facet_button('>>', curr_page + 1, "replace", 'page');
			html += "&nbsp;&nbsp;";
		}

		if (last < num_pages) {
			html += window.collex.create_facet_button('last', num_pages, "replace", 'page');
			html += "&nbsp;&nbsp;";
		}

		pagination.html(html);
	};

});
