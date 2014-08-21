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
// <div id='whatever' style='display:none;'>This text will be show or hidden at will</div>
//
// The data-less element is the text that will be used when the link will cause the div to be contracted. If it is not
// supplied, then the value "Less" will be used.
//

jQuery(document).ready(function($) {
	"use strict";
	var body = $("body");
	body.on("click", ".more_link", function() {
		var el = $(this);
		var target = el.attr("data-div");

		// If this is the first time the button was pushed, set up the text.
		var lessText = el.attr("data-less");
		if (!lessText || lessText.length === 0) {
			lessText = "less";
			el.attr("data-less", lessText);
		}
		var moreText = el.attr("data-more");
		if (!moreText || moreText.length === 0) {
			moreText = el.text();
			el.attr("data-more", moreText);
		}

		var targetEl = $('#'+target);
		if (targetEl.length > 0) {
			if (el.text() === lessText) {
				targetEl.hide();
				el.text(moreText);
			} else {
				targetEl.show();
				el.text(lessText);
			}
		}
	});

});

