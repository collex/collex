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

/*global $, $$, Element, Effect */
/*global YAHOO */
/*global window, document */
/*global supportsFixedPositioning */
/*global serverAction */
/*extern exhibit_outline, exhibit_outline_pos, initOutline, selectLine, setPageSelected, showExhibitOutline,toggle_by_id */
/*extern outline_page_height, setOutlineHeight, scroll_to_target, hide_by_id, open_by_id */

// Used by Exhibit Outline
function toggle_by_id(node_id) {
	Element.toggle(node_id + "_opened");
	Element.toggle(node_id + "_closed");
	Element.toggle(node_id);
}

function open_by_id(node_id) {
	Element.show(node_id + "_opened");
	Element.hide(node_id + "_closed");
	Element.show(node_id);
}

function hide_by_id(node_id) {
	Element.hide(node_id + "_opened");
	Element.show(node_id + "_closed");
	Element.hide(node_id);
}

function setPageSelected()
{
	var allElements = $$(".selected_page");
	allElements.each( function(el) { el.removeClassName( "selected_page" );  });
	var sel_element = $$(".outline_tree_element_selected");
	if (sel_element.length > 0)
	{
		var curr_page = $(sel_element[0]).up('.unselected_page');
		if (curr_page !== undefined)
			curr_page.addClassName('selected_page');
	}
}

var outline_page_height = 0;	// This is initialized in initOutline
function setOutlineHeight() {
	if (outline_page_height > 0) {
		var scrollable_section = $('exhibit_outline_pages');
		scrollable_section.setStyle({height: outline_page_height + 'px'});
	}
}

// Called in exhibit/exhibit_page - TODO-PER: seems like this could have been done with # in the URL
function scroll_to_target(target_el, element_el)
{
	var currentScrollY = function() {
		var f_filterResults = function(n_win, n_docel, n_body) {
			var n_result = n_win ? n_win : 0;
			if (n_docel && (!n_result || (n_result > n_docel)))
				n_result = n_docel;
			return n_body && (!n_result || (n_result > n_body)) ? n_body : n_result;
		};

		return f_filterResults (
			window.pageYOffset ? window.pageYOffset : 0,
			document.documentElement ? document.documentElement.scrollTop : 0,
			document.body ? document.body.scrollTop : 0);
	};

	var y_distance_that_the_element_is_not_in_view = function(element_id)
	{
		// This returns the Y-distance that the window needs to scroll to get the named
		// element into view.
		var el = $(element_id);
		if (el === null)
			return 0;

		var y_element = YAHOO.util.Dom.getY(el);
		var viewport_height = window.innerHeight;	// TODO: is this browser independent?
		var scroll_pos = currentScrollY();

		// if the element is before the scroll position, we need to scroll up
		if (scroll_pos > y_element)
			return y_element - scroll_pos;

		// if the element is after the scroll position and the size of the screen, we need to scroll down.
		if (scroll_pos + viewport_height < y_element)
			return y_element - scroll_pos;

		// if it is on the screen at all, return zero so it doesn't move.
		return 0;
	};

		var distance = y_distance_that_the_element_is_not_in_view(target_el);

		// move the scroll position the amount needed.
		window.scrollBy(0, distance);
		new Effect.Highlight(element_el);
}

function selectLine(id)
{
	var allElements = $$(".outline_tree_element_selected");

	// We don't have to do anything if the element is already selected. This also keeps the item from flashing too quickly if the user double clicks on the item.
	if (allElements.length === 1 && allElements[0].id === id)
		return;

	allElements.each( function(el) { el.removeClassName( "outline_tree_element_selected" );  });

	$(id).addClassName( "outline_tree_element_selected" );

	setPageSelected();

	// now scroll the page to show the element selected.
	var arr = id.split('_');
	var el_id = arr[arr.length-1];

	var target_el = 'element_' + el_id;
	if ($(target_el) !== null)
	{
		scroll_to_target(target_el, "element_" + el_id);
	}
	else
	{
		// The element must be on another page. Go get that.
		serverAction({ action: { actions: "/builder/find_page_containing_element", els: "exhibit_page", params: { element: target_el } }});
	}
}

var exhibit_outline = null;
var exhibit_outline_pos = null;

function showExhibitOutline(element_id, page_num)
{
	exhibit_outline.show();

	if (page_num === -1)
		return;

	if (element_id > 0)
		selectLine('outline_element_' + element_id);
	else
	{
		// need to set the page_num to the current page number
		page_num = parseInt($("current_page_num").innerHTML);
	}

	var done = false;
	var count = 1;
	while (!done)
	{
		var id = 'outline_p' + count;
		var curr_page = $('outline_page_' + count);
		if ($(id) === null)
			done = true;
		else
		{
			if (page_num === count)
			{
				curr_page.addClassName('selected_page');
				open_by_id(id);
			}
			else
			{
				curr_page.removeClassName('selected_page');
				hide_by_id(id);
			}
		}
		count++;
	}
}

function initOutline(div_id)
{
	if (YAHOO.util.Resize === undefined) {
		initOutline.delay(0.5, div_id);
		return;
	}

	$(div_id).removeClassName('hidden');
	var width = 320;
	var top = 180;
	var height = YAHOO.util.Dom.getViewportHeight() - top - 80;
	//create Dialog:
	exhibit_outline = new YAHOO.widget.Dialog(div_id, {
		width: width + "px",
		height: height + 'px',
		fixedcenter: (supportsFixedPositioning === false),
		draggable: true,
		constraintoviewport: true,
		visible: false,
		xy: [ YAHOO.util.Dom.getViewportWidth()-width-60, 180 ]
	});

   var resize = new YAHOO.util.Resize(div_id, {
       handles: ["br"],
       autoRatio: false,
       minWidth: 300,
       minHeight: 100,
       status: false
   });

   // Setup startResize handler, to constrain the resize width/height
   // if the constraintoviewport configuration property is enabled.
   resize.on("startResize", function(args) {
			 if (this.cfg.getProperty("constraintoviewport")) {
          var D = YAHOO.util.Dom;

          var clientRegion = D.getClientRegion();
          var elRegion = D.getRegion(this.element);

          resize.set("maxWidth", clientRegion.right - elRegion.left - YAHOO.widget.Overlay.VIEWPORT_OFFSET);
          resize.set("maxHeight", clientRegion.bottom - elRegion.top - YAHOO.widget.Overlay.VIEWPORT_OFFSET);
		    } else {
          resize.set("maxWidth", null);
          resize.set("maxHeight", null);
				}
   }, exhibit_outline, true);

   // Setup resize handler to update the Panel's 'height' configuration property
   // whenever the size of the 'resizablepanel' DIV changes.

   // Setting the height configuration property will result in the
   // body of the Panel being resized to fill the new height (based on the
   // autofillheight property introduced in 2.6.0) and the iframe shim and
   // shadow being resized also if required (for IE6 and IE7 quirks mode).
   resize.on("resize", function(args) {
       var panelHeight = args.height;
       this.cfg.setProperty("height", panelHeight + "px");
			var scrollable_section = $('exhibit_outline_pages');
			outline_page_height = panelHeight - scrollable_section.offsetTop - 15;	// the 15 is a margin
			setOutlineHeight();
   }, exhibit_outline, true);

	exhibit_outline.setHeader("OUTLINE");
	exhibit_outline.render();

	var scrollable_section = $('exhibit_outline_pages');
	outline_page_height = height - scrollable_section.offsetTop - 15;	// the 15 is a margin
	setOutlineHeight();

	if (supportsFixedPositioning)
		$(div_id + '_c').setStyle({ position: 'fixed'});
}



