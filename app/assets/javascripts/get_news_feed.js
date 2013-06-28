//------------------------------------------------------------------------
//    Copyright 2009 Applied Research in Patacriticism and the University of Virginia
//
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
//
//        http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.
//----------------------------------------------------------------------------

/*global $, $A */
/*global serverRequest */
/*extern loadLatestNews */

// asynchronously load the rss feed and pull out the news items
function loadLatestNews( targetList, rssFeedURL, maxItems, retry ) {
	YUI().use("io", function(Y) {
	var onSuccess = function(x, resp) {
		var rss = resp.responseXML;
		if (rss === null) {
			$(targetList).update("<ul><li>Error in retrieving News Feed.</li></ul>\n");
			return;
		}
		var doc = rss.documentElement;
		var channel = doc.getElementsByTagName('channel');
		var items = channel[0].getElementsByTagName('item');
		var aitems = $A(items);
		var len = 5;
		if (aitems.length < 5)
			len = aitems.length;
		var str = "<ul>";
		for (var i = 0; i < len; i++) {
			var title = aitems[i].getElementsByTagName('title');
			var link = aitems[i].getElementsByTagName('link');
			// Unfortunately, firefox defines the attribute textContent, but IE defines text for the same thing.
			var title_text = title[0].text;
			if (title_text === undefined)
				title_text = title[0].textContent;
			var link_text = link[0].text;
			if (link_text === undefined)
				link_text = link[0].textContent;
			str += "<li><a href=\"" + link_text + "\" class=\"nav_link\" >" + title_text + "</a></li>\n";
		}
		str += "<li><a href=\"/news/\" class=\"nav_link\">MORE</a></li></ul>\n";

		$(targetList).update(str);
	};
	var onFailure = function() {
		// This can be a transient error, so we'll retry once, then just leave the area blank.
		if (retry === true)
			loadLatestNews( targetList, rssFeedURL, maxItems, false );
		else
			$(targetList).update("<ul><li>News feed currently unavailable.</li></ul>\n");
	};
		Y.io(rssFeedURL, { method: 'GET', on: { success: onSuccess, failure: onFailure } });
		//	serverRequest({ url: rssFeedURL, onSuccess: onSuccess, onFailure: onFailure, params: { method: 'GET' } });
	});
}
