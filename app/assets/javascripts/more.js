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

//
// This activates a "more" link that will hide and show a div. To use, create an element that looks like this:
// <a href='#' onclick='return false;' class='more_link' data-div='whatever' data-less='Read Less'>Read More</a>
// and create another element on the page with the id of 'whatever' that is initially hidden:
// <div id='whatever' class='hidden'>This text will be show or hidden at will</div>
//
// The data-less element is the text that will be used when the link will cause the div to be contracted. If it is not
// supplied, then the value "Less" will be used.
//
// This assumes that prototype is loaded, and that there is a class in the css named 'hidden' which contains "display:none"
//

/*global $, $$ */

document.observe('dom:loaded', function() {
	$$(".more_link").each(function(el) {
		var lessText = YAHOO.util.Dom.getAttribute(el, 'data-less');
		if (!lessText || lessText.length === 0)
			YAHOO.util.Dom.setAttribute(el, 'data--less', 'Less');
		YAHOO.util.Dom.setAttribute(el, 'data--more', el.innerHTML);
		var targ = YAHOO.util.Dom.getAttribute(el, 'data-div');
		var targEl = $(targ);
		if (targEl)
			targEl.addClassName('hidden');

		var fnCallback = function(e) {
			var text = this.innerHTML;
			var targ = YAHOO.util.Dom.getAttribute(this, 'data-div');
			var targEl = $(targ);
			if (targEl) {
				var lessText = YAHOO.util.Dom.getAttribute(this, 'data-less');
				if (text === lessText) {
					var moreText = YAHOO.util.Dom.getAttribute(this, 'data-more');
					this.innerHTML = moreText;
					targEl.addClassName('hidden');
				} else {
					this.innerHTML = lessText;
					targEl.removeClassName('hidden');
				}
			}
			return false;
		};
		YAHOO.util.Event.addListener(el, "click", fnCallback);
	});
});
