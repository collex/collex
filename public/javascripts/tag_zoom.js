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

/*global $, $$ */
/*global window, document */
/*global serverNotify */
/*extern tagZoom */

// Create a singleton object so we don't pollute the global namespace too much.
var tagZoom = {
	zoom_level: 1,   // default zoom level 
	startY: 0,  // mouse starting positions
	offsetY: 0,  // current element offset
	dragElement: null, // needs to be passed from OnMouseDown to OnMouseMove
	oldZIndex: 0, // we temporarily increase the z-index during drag
	curr_pos: 0,

	doZoom: function(level)
	{
		var setTagVisibility = function(new_zoom_level)
		{
		  // get all of the span elements under the tagcloud. These are the tags
			var spans = $$('#tagcloud span');
			for (var i = 0; i < spans.length; i++)
			{
			  // remove all cloud# class info
			  for ( var s=0; s<=10; s++)
			  {
			     spans[i].removeClassName("cloud"+s);
			  }
				
				// read in the zoom attribute
				var zooms = spans[i].readAttribute('zoom').split(",");
				var newClass = "cloud"+zooms[new_zoom_level-1];
				spans[i].addClassName(newClass);
			}
		};

		switch (level)
		{
			case "+": if (tagZoom.zoom_level < 10) tagZoom.zoom_level++; break;
			case "-": if (tagZoom.zoom_level > 1) tagZoom.zoom_level--; break;
			case "1": tagZoom.zoom_level = 1; break;
			case "2": tagZoom.zoom_level = 2; break;
			case "3": tagZoom.zoom_level = 3; break;
			case "4": tagZoom.zoom_level = 4; break;
			case "5": tagZoom.zoom_level = 5; break;
			case "6": tagZoom.zoom_level = 6; break;
			case "7": tagZoom.zoom_level = 7; break;
			case "8": tagZoom.zoom_level = 8; break;
			case "9": tagZoom.zoom_level = 9; break;
			case "10": tagZoom.zoom_level = 10; break;
		}
		
		// pass along the prior level so the delta can be calculated
		setTagVisibility(tagZoom.zoom_level);

		var thumb = $('tag_zoom_thumb');
		thumb.style.top = "" + (306 - tagZoom.zoom_level*9) + "px";

		if (tagZoom.dragElement === null)
			serverNotify("/tag/set_zoom", { level: tagZoom.zoom_level } );
	},

	zoomThumbMouseDown: function(e)
	{
		var extractNumber = function(value)
		{
			var n = parseInt(value);
			return n === null || isNaN(n) ? 0 : n;
		};

		var isDraggable = function(target)
		{
			// If any parent of what is clicked is draggable, the element is draggable.
			while (target) {
				if (target.id === 'tag_zoom_thumb')
					return target;
				target = target.parentNode;
			}
			return null;
		};

		var zoomThumbMouseMove = function(e)
		{
			if (e === null)
				e = window.event; // this is the actual "drag code"

			// We need to confine the drag to the area of the slider
			var y = tagZoom.offsetY + e.clientY - tagZoom.startY;
			if (y < 224) y = 224;
			if (y> 297) y = 297;
			tagZoom.dragElement.style.top = y + 'px';
			tagZoom.curr_pos = Math.round((297 - y) / 8) + 1;
			tagZoom.doZoom("" + tagZoom.curr_pos);
		 };

		 // IE doesn't pass the event object
		 if (e === null) e = window.event;
		 // IE uses srcElement, others use target
		 var target = e.target !== null ? e.target : e.srcElement;
		 target = isDraggable(target);

		  // for IE, left click == 1
		  // for Firefox, left click == 0

		  if ((e.button === 1 && window.event !== null || e.button === 0) && target !== null) {
			// grab the mouse position
			tagZoom.startY = e.clientY;
			// grab the clicked element's position
			tagZoom.offsetY = extractNumber(target.style.top);
			// bring the clicked element to the front while it is being dragged
			tagZoom.oldZIndex = target.style.zIndex;
			target.style.zIndex = 10000;
			// we need to access the element in OnMouseMove
			tagZoom.dragElement = target;
			// tell our code to start moving the element with the mouse
			document.onmousemove = zoomThumbMouseMove;
			// cancel out any text selections
			document.body.focus();
			// prevent text selection in IE
			document.onselectstart = function()
			{
				return false;
			};
			// prevent IE from trying to drag an image
			target.ondragstart = function()
			{
				return false;
			};
			// prevent text selection (except IE)
			return false;
		  }
		return true;
	},

	zoomThumbMouseUp: function(e)
	{
		if (tagZoom.dragElement !== null)
		{
			tagZoom.dragElement.style.zIndex = tagZoom.oldZIndex;
			// we're done with these events until the next OnMouseDown
			document.onmousemove = null;
			document.onselectstart = null;
			tagZoom.dragElement.ondragstart = null;
			// this is how we know we're not dragging
			tagZoom.dragElement = null;

			tagZoom.doZoom("" + tagZoom.curr_pos);
		}
	}
};



