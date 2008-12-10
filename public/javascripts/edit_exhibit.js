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

	new Ajax.Updater(div, "/my9s/change_element_type", {
		parameters : "element_id="+ element_id + "&type=" + newType,
		evalScripts : true,
		onComplete : setTimeout("initializeElementEditing()", 1000),
		onFailure : function(resp) { alert("Oops, there's been an error."); }
	});
}

function insertIllustration(div, element_id, illustration_position)
{
	new Ajax.Updater(div, "/my9s/insert_illustration", {
		parameters : "element_id="+ element_id + "&position=" + illustration_position,
		evalScripts : true,
		onComplete : setTimeout("initializeElementEditing()", 1000),
		onFailure : function(resp) { alert("Oops, there's been an error."); }
	});
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
	// this is called from the outline, so we also need to update the regular page, too.
	
	var allElements = $$(".outline_tree_element_selected");
	if (allElements.length == 1)
	{
		var id = allElements[0].id;
		var arr = id.split("_");
		var element_id = arr[arr.length-1];
		new Ajax.Updater("full_window", "/my9s/modify_outline", {
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
	var allElements = $$(".outline_tree_element_selected");
	if (allElements.length == 1)
	{
		var id = allElements[0].id;
		var arr = id.split("_");
		var element_id = arr[arr.length-1];
		new Ajax.Updater("full_window", "/my9s/modify_outline_page", {
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
		if (section.hasClassName("outline_section_without_border"))
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
	//location.replace('#top-of-' + el_id);
	var distance = y_distance_that_the_element_is_not_in_view('top-of-' + el_id);

	// move the scroll position the amount needed.
	window.scrollBy(0, distance);
	new Effect.Highlight("element_" + el_id);
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
	$(_exhibit_outline).show();
	if (element_id > 0)
		selectLine('outline_element_' + element_id);
}

function initOutline(div_id)
{
	var outline_width = 370;
	var outline_height = 400;
	
	var outer_win = $$('.tab-content-outline2');
	var x = getX(outer_win[0]);
	var y = getY(outer_win[0]);
	var w = parseInt(outer_win[0].getStyle('width'));
	var left = x + w - outline_width - 55;
	var top = y + 25;
	
	_exhibit_outline = new Window({
		title: 'OUTLINE',
		//className: 'darkX',
		className: "collex",
		//className: "mac_os_x",
		width: null,
		height: null,
		destroyOnClose: false,
		left: left,
		top: top,
		width: outline_width,
		height: outline_height,
		showEffect: Element.show,
		hideEffect: Element.hide,
		maximizable: false,
		minimizable: true,
		resizable: true
	});

	var content = _exhibit_outline.getContent();
	content.update($(div_id));
	//_win.setConstraint(true, {left:10 - pos[0], right:30 - pos[1], top: 10 - pos[0], bottom:10 - pos[1]});
	_exhibit_outline.show(false);
}
