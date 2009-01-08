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
			// for images, the resizer is added after the image is finished loading
			if (widenableElement.tagName != 'IMG')
			{
				var resizer = new YAHOO.util.Resize(widenableElement.id, {ratio:false, handles: [ 'r' ] });
				resizer.subscribe( 'endResize', imgResized, widenableElement, false);
			}
		}
	});
}

function initializeResizableImageElement( element_id ) {
	var widenableElement = $(element_id);
	var resizer = new YAHOO.util.Resize(widenableElement.id, {ratio:true});
	resizer.subscribe( 'endResize', imgResized, widenableElement, false);
}

function imgResized(event, illustrationElement)
{
	var element = illustrationElement.up('.element_block');
	var newWidth = illustrationElement.width;	// This is the width if it is a picture
	if (newWidth == undefined || newWidth == null)
		newWidth = parseInt(illustrationElement.getStyle('width'));
	new Ajax.Updater(element.id, "/my9s/change_img_width",
	{
		parameters : { illustration_id: illustrationElement.id, width: newWidth },
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

//var strStopEditingText = '[Stop Editing Border]';
//
//function doEnterEditBorder(exhibit_id)
//{
//	// this is called both to start editing and to stop editing.
//	// If we want to stop editing, we just hide the controls and return.
//	var didExit = exitEditBorderMode();
//	if (didExit)
//		return;
//	
//	// First find the selected item so we know which section to manipulate.
//	var allElements = $$(".outline_tree_element_selected");
//	if (allElements.length == 1)
//	{
//		var id = allElements[0].id;
//		var arr = id.split("_");
//		var element_id = arr[arr.length-1];
//		
//		var section = allElements[0].up();
//		// If the section doesn't have a border, add one automatically.
//		if (section.hasClassName("outline_section_with_border") == false)
//		{
//			doAjaxLinkOnSelection('insert_border', exhibit_id);
//			return;
//		}
//		
//		var editBorderButton = $('edit_border');
//		editBorderButton.innerHTML = strStopEditingText;
//		var borderControls = $("border_controls");
//		var borderControlsBottom = $("border_controls_bottom");
//		borderControls.show();
//		borderControlsBottom.show();
//		section.insert({
//			top: borderControls,
//			bottom: borderControlsBottom
//		});
//	}	
//}
//
//function exitEditBorderMode()
//{
//	var editBorderButton = $('edit_border');
//	if (editBorderButton.innerHTML == strStopEditingText)
//	{
//		editBorderButton.innerHTML = "[Edit Border]";
//		$("border_controls").hide();
//		$("border_controls_bottom").hide();
//		return true;
//	}
//	return false;
//}

function setPageSelected()
{
	var allElements = $$(".selected_page");
	allElements.each( function(el) { el.removeClassName( "selected_page" );  });
	var sel_element = $$(".outline_tree_element_selected");
	if (sel_element.length > 0)
	{
		var curr_page = $(sel_element[0]).up('.unselected_page');
		if (curr_page != undefined)
			curr_page.addClassName('selected_page');
	}
}

function selectLine(id)
{
	//exitEditBorderMode();
	
	var allElements = $$(".outline_tree_element_selected");
	allElements.each( function(el) { el.removeClassName( "outline_tree_element_selected" );  });
	
	$(id).addClassName( "outline_tree_element_selected" );
	
	setPageSelected();

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

function showExhibitOutline(element_id, page_num)
{
	_exhibit_outline.show();
	
	if (page_num == -1)
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
		if ($(id) == null)
			done = true;
		else
		{
			if (page_num == count)
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
	var width = 320;
	var top = 180;
	var height = getViewportHeight() - top - 80;
	//create Dialog:
	_exhibit_outline = new YAHOO.widget.Dialog(div_id, {
		width: width + "px",
		height: height + 'px',
		fixedcenter: (supportsFixedPositioning == false),
		draggable: true,
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
	
	if (supportsFixedPositioning)
		$('full_window_c').setStyle({ position: 'fixed'});
}

BorderDialog = Class.create();

BorderDialog.prototype = {
	initialize: function () {
		this._myPanel = new YAHOO.widget.Dialog("edit_border_dlg", {
			width:"380px",
			fixedcenter: true,
			constraintoviewport: true,
			underlay:"shadow",
			close:true,
			visible:true,
			modal: true,
			draggable:true
		});
		this._myPanel.setHeader("Edit Border");
	
		var myButtons = [ { text:"Submit", handler:this._handleSubmit, isDefault:true },
						  { text:"Cancel", handler:this._handleCancel } ];
		this._myPanel.cfg.queueProperty("buttons", myButtons);
		
		var elOuterContainer = new Element('div', { id: 'border_outer_container' });
		elOuterContainer.appendChild(new Element('div', { 'class': 'instructions'}).update('Drag the mouse over sections that you want to group together.'));
		var elToolbar = new Element('div', { 'class': 'toolbar'});
		elToolbar.appendChild(new Element('a', { id: 'add_border', href: "#", 'class': 'nav_link' }).update('Add Border'));
		elToolbar.appendChild(new Element('span').update(' | '));
		elToolbar.appendChild(new Element('a', { id: 'remove_border', href: "#", 'class': 'nav_link' }).update('Remove Border'));
		elOuterContainer.appendChild(elToolbar);
		var elContainer = new Element('div', { id: 'border_container' });
		elOuterContainer.appendChild(elContainer);
	
		// Here's our header
		var headers = $$('.selected_page .exhibit_outline_text');
		var page_num = headers[0].innerHTML;
		var span = new Element('span', { 'class': 'exhibit_outline_text' }).update('&nbsp;&nbsp;' + page_num);
		elContainer.appendChild(span.wrap('div', { 'class': 'unselected_page selected_page ' }));

		// First copy all the elements over that we want to use
		var elements = $$(".selected_page .outline_element");
		elements.each(function(el) {
			var par = el.up();
			var prev = el.previous();
			var next = el.next();
			var cls = 'border_dlg_element';
			if (par.hasClassName('outline_section_with_border'))
			{
				cls += " border_sides";
				if (prev == undefined)
					cls += " border_top";
				if (next == undefined)
					cls += " border_bottom";
			}
			var inner = el.innerHTML;
			var elBorder = new Element('div', {id: "border_" + el.id, 'class' : cls }).update(inner);
			elContainer.appendChild(elBorder.wrap('div', { id: 'rubberband_' + el.id, 'class': 'rubberband_dlg_element'}));
		}, this);
		
		this._myPanel.setBody(elOuterContainer);
		this._myPanel.render(document.body); 
	
		elements = $$('#border_container .outline_right_controls');
		elements.each(function(el) {
			el.remove();
		}, this);
	
		elements = $$('#border_container .count');
		elements.each(function(el) {
			var num = el.down().innerHTML;
			el.update(num);
			el.addClassName('count');
		}, this);
		
		elements = $$('#border_container [onclick]');
		elements.each(function(el) {
			el.removeAttribute('onclick');
		}, this);
		
		var el = $('border_container');
		el.observe('mousedown', this._mouseDown.bind(this));
		el.observe('mousemove', this._mouseMove.bind(this));
		el.observe('mouseup', this._mouseUp.bind(this));
		
		$('add_border').observe('click', this._addBorder.bind(this));
		$('remove_border').observe('click', this._removeBorder.bind(this));
	},
	
	_isDragging: false,
	_anchor: null,
	_focus: null,
	
	_redrawRubberband : function(focus)
	{
		var t = (focus > this._anchor) ? this._anchor : focus;
		var b = (focus < this._anchor) ? this._anchor : focus;
		
		this._removeRubberband();
		
		var elements = $$('.rubberband_dlg_element');
		elements.each(function(el) {
			var count = parseInt(el.down('.count').innerHTML);
			if (count == t)
				el.addClassName('selection_border_top');
			if ((count >= t) && (count <= b))
				el.addClassName('selection_border_sides');
			if (count == b)
				el.addClassName('selection_border_bottom');
		});
		
		this._focus = focus;
	},
	
	_removeRubberband: function()
	{
		$$('.selection_border_top').each(function(el) { el.removeClassName('selection_border_top')});
		$$('.selection_border_sides').each(function(el) { el.removeClassName('selection_border_sides')});
		$$('.selection_border_bottom').each(function(el) { el.removeClassName('selection_border_bottom')});
	},
	
	_getCurrentElement : function(event)
	{
		var tar = this._getTarget(event);
		var el = (tar.hasClassName('rubberband_dlg_element') ? tar : tar.up('.rubberband_dlg_element'));
		if (el == undefined)
			return -1;
		return parseInt(el.down('.count').innerHTML);
	},
	
	_getTarget : function(event) {
		var tar = $(event.originalTarget);
		if (tar == undefined)
			tar = $(event.srcElement);
		return tar;
	},
	
	_mouseDown: function(event) {

		this._isDragging = true;
		this._anchor = this._getCurrentElement(event);
		this._redrawRubberband(this._anchor);
		Event.stop(event);
	},
	
	_mouseMove: function(event) {
		if (this._isDragging)
		{
			var focus = this._getCurrentElement(event);
			if (focus != this._focus)
			{
				if (focus >= 0)
					this._redrawRubberband(focus);
			}
		}
		Event.stop(event);
	},
	
	_mouseUp: function(event) {
		this._isDragging = false;
		Event.stop(event);
	},
	
	_adjustOverlappingBorder: function() {
		// If the rubberband overlaps a current border, then adjust the edges of that border.
		var tops = $$('.selection_border_top');
		var bottoms = $$('.selection_border_bottom');
		// There should be exactly one of each of these. If not, then just ignore.
		if (tops.length != 1 || bottoms.length != 1)
			return;
		
		var previous = tops[0].previous();
		if (previous && previous.down().hasClassName('border_sides'))	// if the top isn't the first item, and the item before has a border
			previous.down().addClassName('border_bottom');
			
		var next = bottoms[0].next();
		if (next && next.down().hasClassName('border_sides'))	// if the bottom isn't the last item, and the item after has a border
			next.down().addClassName('border_top');
	},
	
	_addBorder: function(event) {
		var elements = $$('.rubberband_dlg_element');
		elements.each(function(el) {
			// If the item doesn't have sides then it isn't part of this selection
			if (el.hasClassName('selection_border_sides'))
			{
				el.down().addClassName('border_sides');
				
				if (el.hasClassName('selection_border_top'))
					el.down().addClassName('border_top');
				else
					el.down().removeClassName('border_top');
	
				if (el.hasClassName('selection_border_bottom'))
					el.down().addClassName('border_bottom');
				else
					el.down().removeClassName('border_bottom');
			}
		});
		this._adjustOverlappingBorder();
		this._removeRubberband();
	},
	
	_removeBorder: function(event) {
		var elements = $$('.rubberband_dlg_element');
		elements.each(function(el) {
			if (el.hasClassName('selection_border_sides'))
			{
				el.down().removeClassName('border_top');
				el.down().removeClassName('border_sides');
				el.down().removeClassName('border_bottom');
			}
		});
		this._adjustOverlappingBorder();
		this._removeRubberband();
	},
	
	_handleCancel: function() {
		this.cancel();
		this.destroy();
	},

	_handleSubmit: function() {
		var elements = $$('.border_dlg_element');
		var str = "";
		elements.each(function(el) {
			if (el.hasClassName('border_top'))
				str += 'start_border' + ',';
			else if (el.hasClassName('border_sides'))
				str += 'continue_border' + ',';
			else
				str += 'no_border' + ',';
		});

		var els = $$('.outline_tree_element_selected');
		if (els.length > 0)
		{
			var element_id = els[0].id;
			element_id = element_id.substring(element_id.lastIndexOf('_')+1);
			
			new Ajax.Updater("full-window-content", "/my9s/modify_border", {
				parameters : { borders: str, element_id: element_id },
				evalScripts : true,
				onFailure : function(resp) { alert("Oops, there's been an error."); }});
		}

		this.cancel();
		this.destroy();
		//this.submit();
	}
	
}

function createBorderDlg()
{
	new BorderDialog();
}
