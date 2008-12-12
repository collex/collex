/**
 * @author paulrosen
 */

 document.observe('dom:loaded', function() {
 	initializeElementEditing();
 });

function initializeElementEditing()
{
	els = $$('.exhibit_illustration .widenable');
	els.each(function(el) { Widenable.prepare(el, imgResized); });
}

function imgResized(illustration_id, width)
{
	var element = $(illustration_id).up('.element_block');
	new Ajax.Updater(element.id, "/my9s/change_img_width",
	{
		parameters : { illustration_id: illustration_id, width: width },
		evalScripts : true,
		onComplete : setTimeout("initializeElementEditing()", 1000),
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
			onComplete : setTimeout("initializeElementEditing()", 1000),
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
					onComplete : setTimeout("initializeElementEditing()", 1000),
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

function showExhibitOutline(element_id)
{
	_exhibit_outline.show();
	if (element_id > 0)
		selectLine('outline_element_' + element_id);
}

function initOutline(div_id)
{
	//create Dialog:
	_exhibit_outline = new YAHOO.widget.Dialog(div_id, {
		width: "320px",
		draggable: true,
		fixedcenter: true,
		visible: false
	});

	_exhibit_outline.setHeader("OUTLINE");
	_exhibit_outline.render();
}
