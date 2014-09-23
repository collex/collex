// ------------------------------------------------------------------------
//     Copyright 2014 Applied Research in Patacriticism and the University of Virginia
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

jQuery(document).ready(function($) {
	"use strict";
	var body = $("body");

	body.on("change", ".post-style .sort select", function () {
		var existingQuery = window.collex.getUrlVars();
		var el = $(this);
		var type = this.id;
		var value = el.val();
		if (value && value.length > 0)
			existingQuery[type] = value;
		else
			delete existingQuery[type];
		var parent = el.closest('.post-style');
		var controller = parent.attr("data-controller");
		var action = "/results";
		var query = window.collex.makeQueryString(existingQuery);
		window.location = "/"+controller+action+'?'+query;
	});

	body.on("click", ".post-style .select-facet", function () {
		var existingQuery = window.collex.getUrlVars();
		var el = $(this);
		var newQueryKey = el.attr("data-key");
		var newQueryValue = el.attr("data-value");
		existingQuery[newQueryKey] = newQueryValue;
		var parent = el.closest('.post-style');
		var controller = parent.attr("data-controller");
		var action = "/results";
		var query = window.collex.makeQueryString(existingQuery);
		window.location = "/"+controller+action+'?'+query;
	});

});
