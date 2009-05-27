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

/*global Class, $, $$, $H, Element, Ajax */
/*global YAHOO */

function initializeElementEditing()
{
	// find all the elements marked as widenable and add resize handles to them
	var widenableElements = $$('.exhibit_illustration .widenable');
	widenableElements.each(function(widenableElement) {
		// ignore elements that have already been given resize handles
		var existingResizeWrap = widenableElement.up('.yui-resize-wrap');
		if( existingResizeWrap === null ) {
			// for images, the resizer is added after the image is finished loading
			if (widenableElement.tagName !== 'IMG')
			{
				var resizer = new YAHOO.util.Resize(widenableElement.id, {ratio:false, handles: [ 'r' ] });
				resizer.subscribe( 'endResize', imgResized, widenableElement, false);
			}
		}
	});
}

function imgResized(event, illustrationElement)
{
	var element = illustrationElement.up('.element_block');
	if (element === undefined)
		element = illustrationElement.up('.element_block_hover');
	var newWidth = illustrationElement.width;	// This is the width if it is a picture
	if (newWidth === undefined || newWidth === null)
		newWidth = parseInt(illustrationElement.getStyle('width'));
	new Ajax.Updater(element.id, "/my9s/change_img_width",
	{
		parameters : { illustration_id: illustrationElement.id, width: newWidth },
		evalScripts : true,
		onComplete : initializeElementEditing,
		onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error: "); }
	});
}

document.observe('dom:loaded', function() {
	initializeElementEditing();
});

function initializeResizableImageElement( element_id ) {
	hideSpinner(element_id);
	var widenableElement = $(element_id);
	var resizer = new YAHOO.util.Resize(widenableElement.id, {ratio:true, handles: ['r', 'l', 'b', 'br', 'bl' ]});
	resizer.subscribe( 'endResize', imgResized, widenableElement, false);
}

function doAjaxLink(div, url, params)
{
	// If we have a comma separated list, we want to send the request synchronously to each action
	// (Doing this synchronously eliminates any race condition: The first call can update the data and
	// the rest of the calls just update the page.
	var actions = url.split(',');
	var action_elements = div.split(',');
	if (actions.length === 1)
	{
		new Ajax.Updater(div, url, {
			parameters : params,
			evalScripts : true,
			onComplete : initializeElementEditing,
			onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
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
					onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
				});
			},
			onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
		});
	}
}

function elementTypeChanged(div, element_id, newType)
{
	if (newType === 'pics')
	{
		$("add_image_" + element_id).show();
		$("justify_" + element_id + "_wrapper").show();
	}
	else
	{
		$("add_image_" + element_id).hide();
		$("justify_" + element_id + "_wrapper").hide();
	}

	var params = { element_id: element_id, type: newType };
	doAjaxLink(div+",exhibit_builder_outline_content", "/my9s/change_element_type,/my9s/refresh_outline", params);
 }

function illustrationJustificationChanged(div, element_id, newJustification)
{
	var params = { element_id: element_id, justify: newJustification };
	doAjaxLink(div, "/my9s/change_illustration_justification", params);
 }

function doAjaxLinkConfirm(div, url, params)
{
	var del = function(){
		doAjaxLink(div, url, params);
	}
	
	new ConfirmDlg("Delete Section", "You are about to delete this section. Do you want to continue?", "Yes", "No", del);
}

function doAjaxLinkOnSelection(verb, exhibit_id)
{
	// this is called from the outline, so we also need to update the regular page, too.
	var action = function(){
		var allElements = $$(".outline_tree_element_selected");
		if (allElements.length == 1) {
			var id = allElements[0].id;
			var arr = id.split("_");
			var element_id = arr[arr.length - 1];
			new Ajax.Updater("exhibit_builder_outline_content", "/my9s/modify_outline", {
				parameters: {
					verb: verb,
					element_id: element_id,
					exhibit_id: exhibit_id
				},
				evalScripts: true,
				onFailure: function(resp){
					new MessageBoxDlg("Error", "Oops, there's been an error.");
				}
			});
			
			// TODO-PER: We only need this if the action affected the current page.
			var page_id = $('current_page').innerHTML;
			new Ajax.Updater("exhibit_page", "/my9s/redraw_exhibit_page", {
				parameters: {
					page: page_id
				},
				evalScripts: true,
				onFailure: function(resp){
					new MessageBoxDlg("Error", "Oops, there's been an error.");
				}
			});
		}
	};
	
	if (verb === 'delete_element')
		new ConfirmDlg("Delete Section", "You are about to delete this section. Do you want to continue?", "Yes", "No", action);
	else
		action();
}

function doAjaxLinkOnPage(verb, exhibit_id, page_num)
{
	var action = function(){
		var allElements = $$(".outline_tree_element_selected");
		if (allElements.length == 1) {
			var id = allElements[0].id;
			var arr = id.split("_");
			var element_id = arr[arr.length - 1];
			new Ajax.Updater("exhibit_builder_outline_content", "/my9s/modify_outline_page", {
				parameters: {
					verb: verb,
					page_num: page_num,
					exhibit_id: exhibit_id,
					element_id: element_id
				},
				evalScripts: true,
				onComplete: function(resp){
					if (verb === 'delete_page') {
						var page_id = $('current_page').innerHTML;
						new Ajax.Updater("exhibit_page", "/my9s/reset_exhibit_page_from_outline", {
							parameters: {
								verb: verb,
								page_num: page_num,
								exhibit_id: exhibit_id,
								element_id: element_id
							},
							evalScripts: true,
							onFailure: function(resp){
								new MessageBoxDlg("Error", "Oops, there's been an error.");
							}
						});
					}
				},
				onFailure: function(resp){
					new MessageBoxDlg("Error", "Oops, there's been an error.");
				}
			});
		}
	}
	
	if (verb === 'delete_page')
		new ConfirmDlg("Delete Page", "You are about to delete page number " + page_num + ". Do you want to continue?", "Yes", "No", action);
	else
		action();
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
	var allElements = $$(".outline_tree_element_selected");

	// We don't have to do anything if the element is already selected. This also keeps the item from flashing too quickly if the user double clicks on the item.
	if (allElements.length == 1 && allElements[0].id == id)
		return;

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
		new Ajax.Updater("exhibit_page", "/my9s/find_page_containing_element", {
			parameters : { element: target_el },
			evalScripts : true,
			onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }});
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
	$(div_id).removeClassName('hidden');
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
		$(div_id + '_c').setStyle({ position: 'fixed'});
}

function editGlobalExhibitItems(update_id, exhibit_id, data_class)
{
	$(update_id).setAttribute('action', "/my9s/edit_exhibit_overview,/my9s/update_title");
	$(update_id).setAttribute('ajax_action_element_id', "overview_data,overview_title");
	
	var data = $$("." + data_class);

	// Now populate a hash with all the starting values.	 The data we are starting with is all on the page with the data_class class.
	var values = {};
	data.each(function(fld) {
		values[fld.id + '_dlg'] = fld.innerHTML.unescapeHTML();
	});
	values['exhibit_id'] = exhibit_id;
	values['element_id'] = update_id;

	// First construct the dialog
	var dlg = new InputDialog(update_id);
	var size = 52;
	dlg.addHidden('exhibit_id');
	dlg.addTextInput('Exhibit title:', 'overview_title_dlg', size);
	dlg.addTextInput('Visible URL:', 'overview_visible_url_dlg', size);
	dlg.addTextInput('Thumbnail:', 'overview_thumbnail_dlg', size);
	dlg.addLink("[ Completely Delete Exhibit ]", "/my9s/delete_exhibit?id="+exhibit_id, "new ConfirmLinkDlg(this, 'Delete Exhibit', 'Warning: This will permanently remove this exhibit. Are you sure you want to continue?'); return false;", "modify_link");
	
	// Now, everything is initialized, fire up the dialog.
	var el = $(update_id);
	dlg.show("Edit Exhibit Overview", getX(el), getY(el), 530, 350, values );
	el = $('overview_title_dlg');
	if (el !== null) {
		el.focus();
		el.select();
	}
}

function sharing_dialog(licenseInfo, iShareStart, exhibit_id, update_id, callback_url)
{
	// Now populate a hash with all the starting values.	 The data we are starting with is all on the page with the data_class class.
	var values = {};
	var value_field = 'sharing';
	values[value_field] = iShareStart;
	values['exhibit_id'] = exhibit_id;
	values['element_id'] = update_id;
	$(update_id).writeAttribute('action', callback_url);
	$(update_id).writeAttribute('ajax_action_element_id', update_id);

	// First construct the dialog
	var dlg = new InputDialog(update_id);
	var size = 52;
	dlg.addHidden('exhibit_id');
	dlg.addPrompt("<span class='input_dlg_license_list_header'>Share this exhibit under the following license:</span>");
	dlg.addLinkToNewWindow("[ Learn more about CC licenses ]", "http://creativecommons.org/about/licenses", null, "nav_link");
	var list = new CreateSharingList(licenseInfo, iShareStart, value_field);
	dlg.addList(value_field, list.list, null);
	dlg.addPrompt("Licenses provided courtesy of Creative Commons");
	
	// Now, everything is initialized, fire up the dialog.
	var el = $(update_id);
	dlg.show("Change Sharing", getX(el), getY(el), 530, 350, values );
}

var CreateSharingList = Class.create({
	list : null,
	initialize : function(items, initial_selection, value_field)
	{
		var This = this;
		This.list = "<table class='input_dlg_list input_dlg_license_list' cellspacing='0'>";
		var iCount = 0;
		items.each(function(obj) {
			This.list += This.constructItem(obj.text, obj.icon, iCount, iCount == initial_selection, value_field);
			iCount++;
		});
		This.list += "</table>";
	},
	
	constructItem: function(text, icon, index, is_selected, value_field)
	{
		var str = "";
		if (is_selected)
			str = " class='input_dlg_list_item_selected' ";
		return "<tr " + str + "onclick='CreateSharingList.prototype._select(this,\"" + value_field + "\" );' index='" + index + "' >" +
		"<td>" + icon + "</td><td>" + text + "</td></tr>\n";
	}
});

CreateSharingList.prototype._select = function(item, value_field)
{
	var selClass = "input_dlg_list_item_selected";
	$$("." + selClass).each(function(el)
	{
		el.removeClassName(selClass);
	});
	$(item).addClassName(selClass);
	$(value_field).value = $(item).getAttribute('index');
}


//////////////////////////////////////////////////////
/// Create the dialog that manipulates the border in edit exhibits.
//////////////////////////////////////////////////////

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
	
		var myButtons = [ { text:"Submit", handler:this._handleSubmit },
						  { text:"Cancel", handler:this._handleCancel } ];
		this._myPanel.cfg.queueProperty("buttons", myButtons);
		
		var elOuterContainer = new Element('div', { id: 'border_outer_container' });
		var elDiv = new Element('div', { id: 'border_dlg_instructions' }).update('First, drag the mouse over some sections and then click "Add Border" or "Remove Border".');
		elDiv.addClassName('instructions');
		elOuterContainer.appendChild(elDiv);
		var elContainer = new Element('div', { id: 'border_container' });
		elOuterContainer.appendChild(elContainer);
	
		// Here's our header
		var headers = $$('.selected_page .exhibit_outline_text');
		var page_num = headers[0].innerHTML;
		var span = new Element('span').update('&nbsp;&nbsp;' + page_num);
		span.addClassName('exhibit_outline_text');
		var span2 = span.wrap('div');
		span2.addClassName('unselected_page');
		span2.addClassName('selected_page');
		elContainer.appendChild(span2);

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
			var elBorder = new Element('div', {id: "border_" + el.id }).update(inner);
			elBorder.addClassName(cls);
			var elBorder2 = elBorder.wrap('div', { id: 'rubberband_' + el.id });
			elBorder2.addClassName('rubberband_dlg_element');
			elContainer.appendChild(elBorder2);
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
		
//		$('add_border').observe('click', this._addBorder.bind(this));
//		$('remove_border').observe('click', this._removeBorder.bind(this));
		
		//this._enableSubmit(false);
	},
	
	_isDragging: false,
	_anchor: null,
	_focus: null,
	
//	_enableSubmit: function(enable)
//	{
//		var buttons = $$('#edit_border_dlg button');
//		buttons.each(function(but) {
//			if (but.innerHTML == 'Submit')
//			{
//				if (enable == true)
//				{
//					but.disabled = false;
//					but.up().removeClassName('yui-button-disabled');
//				}
//				else
//				{
//					but.disabled = true;
//					but.up().addClassName('yui-button-disabled');
//				}
//			}
//		});
//		
//	},
	
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
	
	_selectionMenu : null,
	
	_mouseUp: function(event) {
		if (this._isDragging)
		{
			this._isDragging = false;
			this._selectionMenu = new InputDialog("border_selection");
			this._selectionMenu.setNoButtons();
			this._selectionMenu.setNotifyCancel(this._userCanceled, this);
			this._selectionMenu.addButtons([ 
				{ text: "Add Border", action: BorderDialog.prototype._addBorder },
				{ text: "Remove Border", action: BorderDialog.prototype._removeBorder }
			]);
//			this._selectionMenu.addLink("[ Add border where dotted line is ]", "#", "BorderDialog.prototype._addBorder(); borderDialog._selectionMenu.cancel();", "modify_link");
//			this._selectionMenu.addLink("[ Remove any border inside dotted line ]", "#", "BorderDialog.prototype._removeBorder(); borderDialog._selectionMenu.cancel();", "modify_link");
			this._selectionMenu.show("Border Action", event.clientX, event.clientY, 530, 350, [] );
		}
		Event.stop(event);
	},
	
	_userCanceled: function(This)
	{
		This._removeRubberband();
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
		borderDialog._adjustOverlappingBorder();
		borderDialog._removeRubberband();
		borderDialog._selectionMenu.cancel();
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
		borderDialog._adjustOverlappingBorder();
		borderDialog._removeRubberband();
		borderDialog._selectionMenu.cancel();
	},
	
	_handleCancel: function() {
		this.cancel();
		this.destroy();
	},

	_handleCancel2: function() {
		this._myPanel._handleCancel();
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
			
			new Ajax.Updater("exhibit_builder_outline_content", "/my9s/modify_border", {
				parameters : { borders: str, element_id: element_id },
				evalScripts : true,
				onSuccess: function(resp) {
					new Ajax.Updater("exhibit_page", "/my9s/redraw_exhibit_page", {
						parameters : { borders: str, element_id: element_id },
						evalScripts : true,
						onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }});
				},
				onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
			});
		}

		this.cancel();
		this.destroy();
		//this.submit();
	}
	
}

var borderDialog = null;

function createBorderDlg()
{
	borderDialog = new BorderDialog();
}

/////////////////////////////////////////////////////////////////////////////////

var CreateNewExhibitWizard = Class.create({
	initialize: function (progress_img, url_get_objects) {
		this.class_type = 'CreateNewExhibitWizard';	// for debugging

		// private variables
		var This = this;
		var obj_selector = new ObjectSelector(progress_img, url_get_objects, -1);
		
		// private functions
		
		this.changeView = function (event, param)
		{
			var curr_page = param.curr_page;
			var view = param.destination;
			var dlg = param.dlg;
			
			// Validation
			dlg.setFlash("", false);
			if (curr_page === 'choose_title')	// We are on the first page. The user must enter a title before leaving the page.
			{
				var data = dlg.getAllData();
				if (data.exhibit_title.strip().length === 0) {
					dlg.setFlash("Please enter a name for this exhibit before continuing.", true);
					return false;					
				}
				dlg.setFlash("Verifying title. Please wait...", false);
				new Ajax.Request('/my9s/verify_title', { method: 'get', parameters: { title: data.exhibit_title.strip() },
					onSuccess : function(resp) {
						dlg.setFlash('', false);
						$('exhibit_url').value = resp.responseText;
						dlg.changePage(view, null);
					},
					onFailure : function(resp) {
						dlg.setFlash(resp.responseText, true);
					}
				});
				return false;
			}
			
			var focus_el = null;
			switch (view)
			{
				case 'choose_title': focus_el = 'exhibit_title'; break;
				case 'choose_other_options': focus_el = 'exhibit_thumbnail'; break;
				case 'choose_palette': break;
			}
			dlg.changePage(view, focus_el);

			return false;
		};
		
		this.cancel = function(event, params)
		{
			params.dlg.cancel();
		};
		
		this.sendWithAjax = function (event, params)
		{
			var curr_page = params.curr_page;
			var url = params.destination;
			var dlg = params.dlg;
			
			dlg.setFlash('Verifying exhibit parameters...', false);
			var data = dlg.getAllData();
			data.objects = obj_selector.getSelectedObjects().join('\t');

			var x = new Ajax.Request(url, {
				parameters : data,
				onSuccess : function(resp) {
					dlg.setFlash('Creating exhibit...', false);
					window.location = "/my9s/edit_exhibit?id=" + resp.responseText;
				},
				onFailure : function(resp) {
					dlg.setFlash(resp.responseText, true);
				}
			});
		};

		// privileged methods
		this.show = function () {
			var choose_title = {
					page: 'choose_title',
					rows: [
						[ { text: 'Creating New Exhibit', klass: 'new_exhibit_title' } ],
						[ { text: 'Step 1: Please choose a title for your new exhibit.', klass: 'new_exhibit_label' } ],
						[ { input: 'exhibit_title', klass: 'new_exhibit_input_long' } ],
						[ { text: 'This is the title that will show up in the exhibit list once you decide to share it with other users. You can edit this later by selecting Edit Exhibit Profile at the top of your exhibit editing page.', klass: 'new_exhibit_instructions' } ],
						[ { button: 'Next', url: 'choose_palette', callback: this.changeView }, { button: 'Cancel', callback: this.cancel } ]
					]
				};

			var choose_palette = {
					page: 'choose_palette',
					rows: [
						[ { text: 'Creating New Exhibit', klass: 'new_exhibit_title' } ],
						[ { text: 'Step 2: Add objects to your exhibit.', klass: 'new_exhibit_label' } ],
						[ { text: 'Choose resources from your collected objects to add to this new exhibit.', klass: 'new_exhibit_instructions' } ],
						[ { custom: obj_selector } ],
						[ { text: 'Any object you have collected is available for use in your exhibit. You may add or remove objects from this list at any time.', klass: 'new_exhibit_instructions' } ],
						[ { button: 'Previous', url: 'choose_title', callback: this.changeView }, { button: 'Next', url: 'choose_other_options', callback: this.changeView }, { button: 'Cancel', callback: this.cancel } ]
					]
				};
			
			// Get the current server location.
			var server = window.location;
			server = 'http://' + server.host;

			var choose_other_options = {
					page: 'choose_other_options',
					rows: [
						[ { text: 'Creating New Exhibit', klass: 'new_exhibit_title' } ],
						[ { text: 'Step 3: Additional options', klass: 'new_exhibit_label' } ],
						[ { text: 'Choose a url for your exhibit:', klass: 'new_exhibit_label' } ],
						[ { text: server + '/exhibits/&nbsp;', klass: 'new_exhibit_label' }, { input: 'exhibit_url', klass: 'new_exhibit_input' } ],
						[ { text: 'Paste a link to a thumbnail image:', klass: 'new_exhibit_label' } ],
						[ { input: 'exhibit_thumbnail', klass: 'new_exhibit_input_long' } ],
						[ { text: 'The thumbnail image will appear next to your exhibit in the exhibit list once you decide to share it with other users. Please use an image that is small, so that the pages doesn\'t take too long to load. These items are optional and can be entered at any time.', klass: 'new_exhibit_instructions' } ],
						[ { button: 'Previous', url: 'choose_palette', callback: this.changeView }, { button: 'Create Exhibit', url: '/my9s/create_exhibit', callback: this.sendWithAjax }, { button: 'Cancel', callback: this.cancel } ]
					]
				};

			var pages = [ choose_title, choose_palette, choose_other_options ];

			var params = { this_id: "new_exhibit_wizard", pages: pages, body_style: "new_exhibit_div", row_style: "new_exhibit_row", title: "New Exhibit Wizard" };
			var dlg = new GeneralDialog(params);
			this.changeView(null, { curr_page: '', destination: 'choose_title', dlg: dlg });
			dlg.center();
			obj_selector.populate(dlg);
			
			return;
		};
	}
});

////////////////////////////////////////////////////////////////////////////////////

// There is a lot of "bounce" where we get an unhover and hover events next to each other.
// We'll damp them out by putting a delay in the unhover that can get canceled by the next hover.
var unhoverlist = $H({});

function initSelectCtrl(select_el_id, onchange_callback)
{
	var sel = $(select_el_id);
	if (sel) {	// Initializing the select wipes out the original select id, so it if it there, then we haven't initialized.
		var opt = sel.down('option', sel.selectedIndex);	// Get the currently selected item: that is set in the original HTML as the selection.
		var start_text = opt.innerHTML;
		var oMenuButton1 = new YAHOO.widget.Button({ 
			id: "menu" + select_el_id, 
			name: "menu" + select_el_id,
			label: "<span class=\"yui-button-label\">" + start_text + "</span>",
			type: "menu",  
			menu: select_el_id, 
			container: select_el_id + "_wrapper"
		});
		
		//	"selectedMenuItemChange" event handler for a Button that will set 
		//	the Button's "label" attribute to the value of the "text" 
		//	configuration property of the MenuItem that was clicked.
		var onSelectedMenuItemChange = function (event) {
			var oMenuItem = event.newValue;
			var new_text = oMenuItem.cfg.getProperty("text");
			this.set("label", ("<span class=\"yui-button-label\">" + 
				new_text + "</span>"));
			if (start_text !== new_text) {
				onchange_callback(oMenuItem.value);
			}
		};
		
		//	Register a "selectedMenuItemChange" event handler that will sync the 
		//	Button's "label" attribute to the MenuItem that was clicked.
		oMenuButton1.on("selectedMenuItemChange", onSelectedMenuItemChange);
	}
}

function sectionHovered(el, edit_bar_id, addClass, removeClass)
{
	var arr = el.id.split('_');
	var element_id = arr[1];
	
	initSelectCtrl(el.id + "_select_type", function(value) {
		elementTypeChanged(el.id, element_id, value);
	});
	
	initSelectCtrl("justify_" + element_id, function(value) {
		illustrationJustificationChanged(el.id, element_id, value);
	});

	if (unhoverlist.get(el.id) === 'waiting') {
		unhoverlist.set(el.id, 'hovered');
	}
	else {
		$(el).addClassName(addClass);
		$(el).removeClassName(removeClass);
		var edit_bar = $(el).down('.' + edit_bar_id);
		edit_bar.removeClassName('hidden');
	}
	return false;
}

function doUnhover(el, edit_bar_id, addClass, removeClass)
{
	if (unhoverlist.get(el.id) === 'waiting') {
		unhoverlist.set(el.id, 'cleared');
		$(el).addClassName(addClass);
		$(el).removeClassName(removeClass);
		var edit_bar = $(el).down('.' + edit_bar_id);
		$(el).down('.' + edit_bar_id).addClassName('hidden');
	}
}

function sectionUnhovered(el, edit_bar_id, addClass, removeClass)
{
	unhoverlist.set(el.id, 'waiting');
	doUnhover.delay(.1, el, edit_bar_id, addClass, removeClass);
	return false;
}

////////////////////////////////////////////////////////////////////////////
/// Create the control that adds and subtracts objects from exhibits
////////////////////////////////////////////////////////////////////////////

//var ObjectList = Class.create({
//	initialize: function (progress_img, title) {
//		// This creates a control that contains a list of NINES Objects. When the user clicks on an object, then it is selected.
//		// The control is populated by a call that either passes an array (that replaces the contents), or is passed an object and that object
//		// is either added or removed.
//		// When the control is first created, then an image is displayed instead. This is intended to be a progress spinner.
//		this.class_type = 'ObjectList';	// for debugging
//
//		// private variables
//		var This = this;
//		var outer = null;
//		var div = null;
//		var objs = null;
//		var actions = [];
//		
//		// private functions
//		var select = function(event)
//		{
//			var sel = $(this);
//			var parent = sel.up('.object_list_outer');
//			var els = parent.select('.object_list_row_selected');
//			els.each(function(el) {
//				el.removeClassName('object_list_row_selected');
//			});
//			sel.addClassName('object_list_row_selected');
//		};
//
//		var isEven = function(num) {
//		  return !(num % 2);
//		};
//		
//		var formatObj = function(obj, alt)
//		{
//			var div = new Element('div');
//			//div.writeAttribute({ onclick: ObjectList.select });
//			actions.push({el: div, action: select });
//			div.writeAttribute({ uri: obj.uri });
//			div.addClassName('object_list_row');
//			div.addClassName(alt ? 'object_list_row_even' : 'object_list_row_odd');
//			var img = new Element('img', { src: obj.thumbnail, alt: obj.thumbnail });
//			img.addClassName('object_list_img');
//			div.appendChild(img);
//			div.appendChild(new Element('span').update(obj.title));
//			return div;
//		};
//		
//		// privileged functions
//		this.populate = function (objects)
//		{
//			div.update('');
//			var alt = false;	// For alternate rows
//			objects.each(function(obj) {
//				div.appendChild(formatObj(obj, alt));
//				alt = !alt;
//			});
//			actions.each(function(action) {
//				action.el.observe('click', action.action);
//			});
//		};
//		
//		this.add = function(object)
//		{
//			var els = div.select('.object_list_row');
//			div.appendChild(formatObj(object, isEven(els.length)));
//			actions[actions.length-1].el.observe('click', actions[actions.length-1].action);
//		};
//		
//		this.subtract = function(object_uri)
//		{
//			var sel = div.select('[uri=' + object_uri + ']');
//			if (sel.length > 0)
//				sel[0].remove();
//		};
//		
//		this.getSelection = function()
//		{
//			// This returns the object that is currently selected.
//			var sel = div.select('.object_list_row_selected');
//			if (sel.length === 0)
//				return null;
//			return sel[0].readAttribute('uri');
//		};
//		
//		this.getMarkup =  function()
//		{
//			if (outer === null) {
//				outer = new Element('div');
//				var header = new Element('div').update(title);
//				header.addClassName('object_list_title');
//				outer.appendChild(header);
//				div = new Element('div');
//				div.addClassName('object_list_outer');
//				outer.appendChild(div);
//				div.appendChild(new Element('img', { src: progress_img, alt: 'progress' }));
//			}
//			return outer;
//		};
//		
//		this.getAllObjects = function()
//		{
//			var objs = [];
//			var sel = div.select('.object_list_row');
//			sel.each(function(el) {
//				objs.push(el.readAttribute('uri'));
//			});
//			return objs;
//		}
//	}
//});

var ObjectSelector = Class.create({
	initialize: function (progress_img, url_get_objects, exhibit_id) {
		// This creates 4 controls: the unselected list, the selected list, and the buttons to move items between the two
		this.class_type = 'ObjectSelector';	// for debugging

		// private variables
		var This = this;
		var olUnchosen = new CreateListOfObjects(url_get_objects + '?chosen=false&exhibit_id='+exhibit_id, '', 'unchosen_objects', progress_img);
		var olChosen = new CreateListOfObjects(url_get_objects + '?chosen=true&exhibit_id='+exhibit_id, '', 'chosen_objects', progress_img);

//		var olChosen = new ObjectList(progress_img, "Objects In Exhibit");
		var divMarkup = null;
		var actions = [];
		var objs = null;
		
		// private functions
		var addSelection = function()
		{
			var obj = olUnchosen.popSelection();
			if (obj)
				olChosen.add(obj);
		};
		
		var removeSelection = function()
		{
			var obj = olChosen.popSelection();
			if (obj)
				olUnchosen.add(obj);
		};
		
		// privileged functions
		this.populate = function(dlg)
		{
			// Call the server to get the data, then pass it to the ObjectLists
			dlg.setFlash('Getting objects...', false);
			olUnchosen.populate(dlg);
			olChosen.populate(dlg);
			actions.each(function(action) {
				action.el.observe('click', action.action);
			});
		};
		
		this.getMarkup =  function()
		{
			if (divMarkup !== null)
				return divMarkup;
				
			divMarkup = new Element('div');
			divMarkup.addClassName('object_selector');

			var divLeftText = new Element('div').update('Available Objects:');
			divLeftText.addClassName('select_objects_label select_objects_label_left');
			divMarkup.appendChild(divLeftText);
			var divRightText = new Element('div').update('Objects in Exhibit:');
			divRightText.addClassName('select_objects_label select_objects_label_right');
			divMarkup.appendChild(divRightText);

			divMarkup.appendChild(olUnchosen.getMarkup());
			var mid = new Element('div');
			mid.addClassName('select_objects_buttons');
			but2 = new Element('input', { type: 'button', value: 'ADD >>' });
			mid.appendChild(but2);
			var but = new Element('input', { type: 'button', value: '<<' });
			mid.appendChild(but);
			actions.push({el: but, action: removeSelection });
			actions.push({el: but2, action: addSelection });
			divMarkup.appendChild(mid);
			divMarkup.appendChild(olChosen.getMarkup());
			return divMarkup;
		};
		
		this.getSelectedObjects = function()
		{
			return olChosen.getAllObjects();
		};
		
		this.getSelection = function() {
			// TODO: This is the new way of getting the selection from custom controls.
			return "";
		}
	}
});

var EditExhibitObjectListDlg = Class.create({
	initialize: function (progress_img, url_get_objects, url_update_objects, exhibit_id, palette_el_id) {
		// This puts up a modal dialog that allows the user to select the objects to be in this exhibit.
		this.class_type = 'EditExhibitObjectListDlg';	// for debugging

		// private variables
		var This = this;
		var obj_selector = new ObjectSelector(progress_img, url_get_objects, exhibit_id);
		
		// private functions
		
		// privileged functions
		this.cancel = function(event, params)
		{
			params.dlg.cancel();
		};
		
		this.sendWithAjax = function (event, params)
		{
			var curr_page = params.curr_page;
			var url = params.destination;
			var dlg = params.dlg;
			
			dlg.setFlash('Updating Exhibit\'s Objects...', false);
			var data = { exhibit_id: exhibit_id, objects: obj_selector.getSelectedObjects().join('\t') };

			var x = new Ajax.Updater(palette_el_id, url, {
				parameters : data,
				evalScripts : true,
				onSuccess : function(resp) {
					dlg.cancel();
				},
				onFailure : function(resp) {
					dlg.setFlash(resp.responseText, true);
				}
			});
		};
		
		var dlgLayout = {
				page: 'choose_objects',
				rows: [
					[ { text: 'Select object from the list on the left and press the ">>" button to move it to the exhibit.', klass: 'new_exhibit_instructions' } ],
					[ { custom: obj_selector } ],
					[ { button: 'Ok', url: url_update_objects, callback: this.sendWithAjax }, { button: 'Cancel', callback: this.cancel } ]
				]
			};
		
		var params = { this_id: "edit_exhibit_object_list_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Choose Objects for Exhibit" };
		var dlg = new GeneralDialog(params);
		dlg.changePage('choose_objects', null);
		dlg.center();
		obj_selector.populate(dlg);
	}
});

//////////////////////////////////////////////////////////////

var SetExhibitAuthorAlias = Class.create({
	initialize: function (progress_img, url_get_users, url_update_alias, exhibit_id, page_id, page_num) {
		// This puts up a modal dialog that allows the user to select the objects to be in this exhibit.
		this.class_type = 'SetExhibitAuthorAlias';	// for debugging

		// private variables
		var This = this;
		var users = null;
		
		// private functions
		var populate = function()
		{
			new Ajax.Request(url_get_users, { method: 'get', parameters: { },
				onSuccess : function(resp) {
					dlg.setFlash('', false);
					try {
						users = resp.responseText.evalJSON(true);
					} catch (e) {
						new MessageBoxDlg("Error", e);
					}
					// We got all the users. Now put it on the dialog
					var sel_arr = $$('.user_alias_select');
					var select = sel_arr[0];
					select.update('');
					users = users.sortBy(function(user) { return user.text; });
					users.each(function(user) {
						select.appendChild(new Element('option', { value: user.value }).update(user.text));
					});
				},
				onFailure : function(resp) {
					dlg.setFlash(resp.responseText, true);
				}
			});			
		};
		
		// privileged functions
		this.cancel = function(event, params)
		{
			params.dlg.cancel();
		};
		
		this.sendWithAjax = function (event, params)
		{
			var curr_page = params.curr_page;
			var url = params.destination;
			var dlg = params.dlg;
			
			dlg.setFlash('Updating Exhibit\'s Author...', false);
			var data = dlg.getAllData();
			data.exhibit_id = exhibit_id;
			data.page_num = page_num;

			var x = new Ajax.Updater(page_id, url, {
				parameters : data,
				evalScripts : true,
				onSuccess : function(resp) {
					dlg.cancel();
				},
				onFailure : function(resp) {
					dlg.setFlash(resp.responseText, true);
				}
			});
		};
		
		var dlgLayout = {
				page: 'choose_objects',
				rows: [
					[ { text: 'Select the user that you wish to impersonate', klass: 'new_exhibit_instructions' } ],
					[ { select: 'user_id', klass: 'user_alias_select', options: [ { value: -1, text: 'Loading user names. Please Wait...' } ] } ],
					[ { button: 'Ok', url: url_update_alias, callback: this.sendWithAjax }, { button: 'Cancel', callback: this.cancel } ]
				]
			};
		
		var params = { this_id: "edit_exhibit_object_list_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Choose Objects for Exhibit" };
		var dlg = new GeneralDialog(params);
		dlg.changePage('choose_objects', null);
		dlg.center();
		populate(dlg);
	}
});
