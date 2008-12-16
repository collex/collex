/**
 * @author paulrosen
 */

 document.observe('dom:loaded', function() {
 	initializeElementEditing();
 });

function initializeElementEditing()
{
	// find all the elements marked as widenable and add resize handles to them
	var widenableElements = $$('.exhibit_illustration .widenable');
	widenableElements.each(function(widenableElement) {
		// ignore elements that have already been given resize handles
		var existingResizeWrap = widenableElement.up('.yui-resize-wrap');
		if( existingResizeWrap == null ) {
			var resizer = new YAHOO.util.Resize(widenableElement.id, {ratio:true});
			resizer.subscribe( 'endResize', imgResized, widenableElement, false);
		}
	});
}

function imgResized(event, illustrationElement)
{
	var element = illustrationElement.up('.element_block');
	new Ajax.Updater(element.id, "/my9s/change_img_width",
	{
		parameters : { illustration_id: illustrationElement.id, width: illustrationElement.width },
		evalScripts : true,
		onComplete : initializeElementEditing,
		onFailure : function(resp) { alert("Oops, there's been an error: "); }
	});
}

function elementTypeChanged(div, element_id, newType)
{
	if (newType == 'pics')
		$("add_image_" + element_id).show();
	else
		$("add_image_" + element_id).hide();

	var params = { element_id: element_id, type: newType };
	doAjaxLink(div+",full-window-content", "/my9s/change_element_type,/my9s/refresh_outline", params);
 }

function doAjaxLinkConfirm(div, url, params)
{
	if (!confirm('You are about to delete this element. Do you want to continue?')) 
		return;
	
	doAjaxLink(div, url, params);
}

function doAjaxLink(div, url, params)
{
	// If we have a comma separated list, we want to send the alert synchronously to each action
	// (Doing this synchronously eliminates any race condition: The first call can update the data and
	// the rest of the calls just update the page.
	var actions = url.split(',');
	var action_elements = div.split(',');
	if (actions.length == 1)
	{
		new Ajax.Updater(div, url, {
			parameters : params,
			evalScripts : true,
			onComplete : initializeElementEditing,
			onFailure : function(resp) { alert("Oops, there's been an error."); }
		});
	}
	else
	{
		new Ajax.Updater(action_elements[0], actions[0], {
			parameters : params,
			evalScripts : true,
			onComplete: function(resp) {
				new Ajax.Updater(action_elements[1], actions[1], {
					parameters : params,
					evalScripts : true,
					onComplete : initializeElementEditing(),
					onFailure : function(resp) { alert("Oops, there's been an error."); }
				});
			},
			onFailure : function(resp) { alert("Oops, there's been an error."); }
		});
	}
}

function doAjaxLinkOnSelection(verb, exhibit_id)
{
	if (verb == 'delete_element' && !confirm('You are about to delete this element. Do you want to continue?')) 
		return;

	// this is called from the outline, so we also need to update the regular page, too.
	
	var allElements = $$(".outline_tree_element_selected");
	if (allElements.length == 1)
	{
		var id = allElements[0].id;
		var arr = id.split("_");
		var element_id = arr[arr.length-1];
		new Ajax.Updater("full-window-content", "/my9s/modify_outline", {
			parameters : { verb: verb, element_id: element_id, exhibit_id: exhibit_id },
			evalScripts : true,
			onFailure : function(resp) { alert("Oops, there's been an error."); }});
			
		// TODO-PER: We only need this if the action affected the current page.
		var page_id = $('current_page').innerHTML;
		new Ajax.Updater("edit_exhibit_page", "/my9s/redraw_exhibit_page", {
			parameters : { page: page_id },
			evalScripts : true,
			onFailure : function(resp) { alert("Oops, there's been an error."); }});
	}
}

function doAjaxLinkOnPage(verb, exhibit_id, page_num)
{
	if (verb == 'delete_page' && !confirm('You are about to delete page number ' + page_num + '. Do you want to continue?')) 
		return;
	var allElements = $$(".outline_tree_element_selected");
	if (allElements.length == 1)
	{
		var id = allElements[0].id;
		var arr = id.split("_");
		var element_id = arr[arr.length-1];
		new Ajax.Updater("full-window-content", "/my9s/modify_outline_page", {
			parameters : { verb: verb, page_num: page_num, exhibit_id: exhibit_id, element_id: element_id },
			evalScripts : true,
			onFailure : function(resp) { alert("Oops, there's been an error."); }});
	}
}

var strStopEditingText = '[Stop Editing Border]';

function doEnterEditBorder(exhibit_id)
{
	// this is called both to start editing and to stop editing.
	// If we want to stop editing, we just hide the controls and return.
	var didExit = exitEditBorderMode();
	if (didExit)
		return;
	
	// First find the selected item so we know which section to manipulate.
	var allElements = $$(".outline_tree_element_selected");
	if (allElements.length == 1)
	{
		var id = allElements[0].id;
		var arr = id.split("_");
		var element_id = arr[arr.length-1];
		
		var section = allElements[0].up();
		// If the section doesn't have a border, add one automatically.
		if (section.hasClassName("outline_section_with_border") == false)
		{
			doAjaxLinkOnSelection('insert_border', exhibit_id);
			return;
		}
		
		var editBorderButton = $('edit_border');
		editBorderButton.innerHTML = strStopEditingText;
		var borderControls = $("border_controls");
		var borderControlsBottom = $("border_controls_bottom");
		borderControls.show();
		borderControlsBottom.show();
		section.insert({
			top: borderControls,
			bottom: borderControlsBottom
		});
	}	
}

function exitEditBorderMode()
{
	var editBorderButton = $('edit_border');
	if (editBorderButton.innerHTML == strStopEditingText)
	{
		editBorderButton.innerHTML = "[Edit Border]";
		$("border_controls").hide();
		$("border_controls_bottom").hide();
		return true;
	}
	return false;
}

function selectLine(id)
{
	exitEditBorderMode();
	
	var allElements = $$(".outline_tree_element_selected");
	allElements.each( function(el) { el.removeClassName( "outline_tree_element_selected" );  });
	
	$(id).addClassName( "outline_tree_element_selected" );
	
	// now scroll the page to show the element selected.
	var arr = id.split('_');
	var el_id = arr[arr.length-1];

	var target_el = 'top-of-' + el_id;
	if ($(target_el) != null)
	{
		scroll_to_target(target_el, "element_" + el_id);
	}
	else
	{
		// The element must be on another page. Go get that.
		new Ajax.Updater("edit_exhibit_page", "/my9s/find_page_containing_element", {
			parameters : { element: target_el },
			evalScripts : true,
			onFailure : function(resp) { alert("Oops, there's been an error."); }});
	}
}

function scroll_to_target(target_el, element_el)
{
		var distance = y_distance_that_the_element_is_not_in_view(target_el);
	
		// move the scroll position the amount needed.
		window.scrollBy(0, distance);
		new Effect.Highlight(element_el);
}

function y_distance_that_the_element_is_not_in_view(element_id)
{
	// This returns the Y-distance that the window needs to scroll to get the named
	// element into view.
	var el = $(element_id);
	if (el == null)
		return 0;
	
	var y_element = getY(el);
	var viewport_height = window.innerHeight;	// TODO: is this browser independent?
	var scroll_pos = currentScrollPos()[1];

	// if the element is before the scroll position, we need to scroll up	
	if (scroll_pos > y_element)
		return y_element - scroll_pos;
		
	// if the element is after the scroll position and the size of the screen, we need to scroll down.
	if (scroll_pos + viewport_height < y_element)
		return y_element - scroll_pos;
		
	// if it is on the screen at all, return zero so it doesn't move.
	return 0;
}

var _exhibit_outline = null;
var _exhibit_outline_pos = null;

function showExhibitOutline(element_id)
{
	_exhibit_outline.show();
	if (element_id > 0)
		selectLine('outline_element_' + element_id);
}

function initOutline(div_id)
{
	var width = 320;
	//create Dialog:
	_exhibit_outline = new YAHOO.widget.Dialog(div_id, {
		width: width + "px",
		draggable: true,
		//fixedcenter: true,
		constraintoviewport: true,
		visible: false,
		xy: [ getViewportWidth()-width-60, 180 ]
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
   }, _exhibit_outline, true);

   // Setup resize handler to update the Panel's 'height' configuration property 
   // whenever the size of the 'resizablepanel' DIV changes.

   // Setting the height configuration property will result in the 
   // body of the Panel being resized to fill the new height (based on the
   // autofillheight property introduced in 2.6.0) and the iframe shim and 
   // shadow being resized also if required (for IE6 and IE7 quirks mode).
   resize.on("resize", function(args) {
       var panelHeight = args.height;
       this.cfg.setProperty("height", panelHeight + "px");
   }, _exhibit_outline, true);

	_exhibit_outline.setHeader("OUTLINE");
	_exhibit_outline.render();
	$('full_window_c').setStyle({ position: 'fixed'});
}
