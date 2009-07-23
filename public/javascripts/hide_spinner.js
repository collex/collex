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

/*global $ */
/*extern finishedLoadingImage, hideSpinner */

// This switches the spinner graphic for the real graphic after the real graphic has finished loading.
// TODO-PER: These two functions do similar things. We can probably combine them.
function hideSpinner(element_id)
{
	var spinnerElement = $("spinner_" + element_id);
	spinnerElement.addClassName("hidden");
	var widenableElement = $(element_id);
	widenableElement.removeClassName("hidden");
}

function finishedLoadingImage(progress_el, img_el, max_width, max_height)
{
	// figure out if we should limit by width or height. We want to limit by whichever dimension is larger.
	// Since the optimum placement (max_width X max_height) may not be square, we'll just figure it out.
	var natural_width = $(img_el).width;
	var natural_height = $(img_el).height;

	// We'll set zero or one of these below, depending on the picture's natural dimensions.
	var width = null;
	var height = null;
	if ((natural_width <= max_width) && (natural_height <= max_height))	// If the image is completely smaller than the opening, then don't limit either dimension.
		width = null;	// don't need to do anything here.'
	else if ((natural_width <= max_width) && (natural_height > max_height))	// Only the height is too big, so limit the height
		height = max_height;
	else if ((natural_width > max_width) && (natural_height <= max_height))	// Only the width is too big, so limit the width
		width = max_width;
	else	// both the height and width are too big, so figure out which is more too big than the other.
	{
		var width_percent_over = natural_width / max_width;
		var height_percent_over = natural_height / max_height;
		if (width_percent_over > height_percent_over)
			width = max_width;
		else
			height = max_height;
	}

	if (width) {
		$(img_el).width = width;
		// Now center the image vertically
		var new_height = $(img_el).height;
		var padding = (max_height - new_height) / 2;
		if (padding > 0)
			$(img_el).setStyle({ paddingTop: padding + "px" });
	}

	if (height) {
		$(img_el).height = height;
		// Now center the image horizontally
		var new_width = $(img_el).width;
		var padding2 = (max_width - new_width) / 2;
		if (padding2 > 0)
			$(img_el).setStyle({ paddingLeft: padding2 + "px" });
	}

	$(progress_el).addClassName('hidden');
	$(img_el).removeClassName('hidden');
}
