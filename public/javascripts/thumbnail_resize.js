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

/*global $ */
/*global setTimeout */
/*extern thumbnail_resize */

// Used in my_collex and the exhibit list page. Potentially also in Forum and Search in the future.
function thumbnail_resize()
{
	var img = $(this);
	var height = parseInt(img.up().getStyle('height'));

	img.show();

	var natural_width = img.width;
	var natural_height = img.height;

	if (natural_height === 0)
	{
		// On IE7 this functions seems to be called early sometimes.
		setTimeout(thumbnail_resize.bind(this), 500);
		return;
	}

	var ratio = natural_width / natural_height;

	var margin_top;
	var margin_left;
	var img_width;
    if (natural_width > natural_height)
	{
      margin_top = 0;
      img_width = parseInt(height*ratio + "");
      margin_left = parseInt((height - img_width) / 2 + "");
    } else {
      var inner_height = height/ratio;
      margin_top = '-' + parseInt((inner_height - height) / 2 + "");
      margin_left = 0;
      img_width = height;
    }

	img.setStyle({
		marginTop: margin_top + 'px',
		marginLeft: margin_left +'px'
	});

	img.writeAttribute('width', img_width);
}
