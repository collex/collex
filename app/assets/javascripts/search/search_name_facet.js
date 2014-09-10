// ------------------------------------------------------------------------
//     Copyright 2009 Applied Research in Patacriticism and the University of Virginia
// 
//     Licensed under the Apache License, Version 2.0 (the "License");
//     you may not use this file except in compliance with the License.
//     You may obtain a copy of the License at
// 
//         http://www.apache.org/licenses/LICENSE-2.0
// 
//     Unless required by applicable law or agreed to in writing, software
//     distributed under the License is distributed on an "AS IS" BASIS,
//     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//     See the License for the specific language governing permissions and
//     limitations under the License.
// ----------------------------------------------------------------------------

/*global MessageBoxDlg, serverAction, ShowDivInLightbox */

jQuery(document).ready(function($) {
	"use strict";
	var body = $("body");

	body.on("click", ".expandSearchNameFacet", function () {
		var elMin = $('#search_name_facet_min');
		var elMax = $('#search_name_facet_max');
		elMin.addClass('hidden');
		elMax.removeClass('hidden');
		var elProgress = $('#search_name_never_requested');
		if (elProgress) {	// The spinner is on the page, but hidden, until the first time there's an update. So we only need to call the server when the spinner still exists.
			var onFailure = function(resp) {
				new MessageBoxDlg("Error in retrieving names", "There was an error getting the list of names from the server. The problem was: " + resp.responseText);
			};
			serverAction({action: { els: 'search_name_facet_max', actions: '/search/list_name_facet_all', params: { query: window.collex.removeSortAndPageFromQueryObject() }, onFailure: onFailure }});
		}
	});

	body.on("click", ".minimizeSearchNameFacet", function () {
		var elMin = $('#search_name_facet_min');
		var elMax = $('#search_name_facet_max');
		elMax.addClass('hidden');
		elMin.removeClass('hidden');
	});

	body.on("click", ".showAllSearchNameFacet", function () {
		new ShowDivInLightbox({ title: "Name Browser", id: 'full_name_facet_list', klass: 'name_facet_in_lightbox' });
	});

	window.collex.resetNameFacet = function() {
		var parent = $("#search_name_facet_max");
		var html = window.pss.createHtmlTag("div", { 'id': "search_name_never_requested" },
			window.pss.createHtmlTag("img", { 'alt': "Please wait...", src: "/assets/ajax_loader.gif" }) + "<br><br>Searching for names. Please wait a moment...");
		parent.html(html);
		var elMin = $('#search_name_facet_min');
		var elMax = $('#search_name_facet_max');
		elMax.addClass('hidden');
		elMin.removeClass('hidden');
	};
});
