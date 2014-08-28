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

/*global $, $$, $H */
/*global YAHOO */
/*global MessageBoxDlg, hideSpinner, pageRenumberFootnotes, serverAction */
/*global document, setTimeout */
/*extern doAjaxLink, doAjaxLinkConfirm, doAjaxLinkOnPage, doAjaxLinkOnSelection, elementTypeChanged, illustrationJustificationChanged, imgResized */
/*extern initializeElementEditing, initializeResizableImageElement, initializeResizableTextualElement,  sectionHovered, sectionUnhovered, unhoverlist */

// This contains functions for the Exhibit Builder page that are not the outline or the profile.

// Refactoring notes:
// * Combine with initialize_inplacericheditor
//
// Edit Element: edit bar
//
// Edit Element: inplace
//
// sync outline with page
//

/*global imgResized */ // This is just to resolve the following circular reference.
function initializeElementEditing()
{
	// find all the elements marked as widenable and add resize handles to them
	var widenableElements = $$('.widenable');
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
	if (typeof(pageRenumberFootnotes) === 'function') {
		pageRenumberFootnotes();
	}
}

function imgResized(event, illustrationElement)
{
	var element = illustrationElement.up('.element_block');
	if (element === undefined)
		element = illustrationElement.up('.element_block_hover');
	var newWidth = illustrationElement.width;	// This is the width if it is a picture
	if (newWidth === undefined || newWidth === null)
		newWidth = parseInt(illustrationElement.getStyle('width'));
	var newHeight = illustrationElement.height;	// This is the height if it is a textual illustration
	if (newHeight === undefined || newHeight === null)
		newHeight = parseInt(illustrationElement.getStyle('height'));
	serverAction({action:{ els: element.id, actions: "/builder/change_img_width", onSuccess: initializeElementEditing, params: {illustration_id: illustrationElement.id, width: newWidth, height: newHeight} }});
}

document.observe('dom:loaded', function() {
	initializeElementEditing();
});

function initializeResizableImageElement( element_id ) {
	if (YAHOO.util.Resize === undefined) {
		initializeResizableImageElement.delay(0.5, element_id );
		return;
	}
	hideSpinner(element_id);
	var widenableElement = $(element_id);
	var resizer = new YAHOO.util.Resize(widenableElement.id, {ratio:true, handles: ['r', 'l', 'b', 'br', 'bl' ]});
	resizer.subscribe( 'endResize', imgResized, widenableElement, false);
}

function initializeResizableTextualElement( element_id ) {
	var widenableElement = $(element_id);
	var resizer = new YAHOO.util.Resize(widenableElement.id, {ratio:false, handles: ['r', 'l', 'b', 'br', 'bl' ]});
	resizer.subscribe( 'endResize', imgResized, widenableElement, false);
}

function doAjaxLink(div, url, params)
{
	serverAction({action:{actions: url, els: div, onSuccess: initializeElementEditing, params: params}});
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
	doAjaxLink(div+",exhibit_builder_outline_content", "/builder/change_element_type,/builder/refresh_outline", params);
 }

function illustrationJustificationChanged(div, element_id, newJustification)
{
	var params = { element_id: element_id, justify: newJustification };
	doAjaxLink(div, "/builder/change_illustration_justification", params);
 }

function doAjaxLinkConfirm(div, url, params)
{
	serverAction({confirm: { title: "Delete Section", message: "You are about to delete this section. Do you want to continue?"}, action: { actions: url, els: div, params: params}, progress: { waitMessage: 'Please Wait...'}});
}

function doAjaxLinkOnSelection(verb, exhibit_id)
{
	// this is called from the outline, so we also need to update the regular page, too.
	var allElements = $$(".outline_tree_element_selected");
	if (allElements.length !== 1) {
		new MessageBoxDlg("Exhibit Outline", "Please select a line in the outline.");
		return;
	}
	var id = allElements[0].id;
	var arr = id.split("_");
	var element_id = arr[arr.length - 1];
	var page_id = $('current_page').innerHTML;
	var params = { verb: verb, exhibit_id: exhibit_id, element_id: element_id, page_id: page_id };
	var els = [ "exhibit_builder_outline_content", "exhibit_page" ];
	var actions = [ "/builder/modify_outline", "/builder/redraw_exhibit_page" ];

	if (verb === 'delete_element')
		serverAction({confirm: { title: "Delete Section", message: "You are about to delete this section. Do you want to continue?"}, action: { actions: actions, els: els, params: params }, progress: { waitMessage: 'Please Wait...' }});
	else
		serverAction({action:{actions: actions, els: els, params: params}});
}

// This is called for the controls on the Page line in the Outline 
function doAjaxLinkOnPage(verb, exhibit_id, page_num)
{
	var allElements = $$(".outline_tree_element_selected");
	if (allElements.length !== 1) {
		new MessageBoxDlg("Exhibit Outline", "Please select a line in the outline.");
		return;
	}
	var id = allElements[0].id;
	var arr = id.split("_");
	var element_id = arr[arr.length - 1];
	var params = { verb: verb, exhibit_id: exhibit_id, element_id: element_id, page_num: page_num };

	if (verb === 'delete_page')
		serverAction({confirm: { title: "Delete Page", message: "You are about to delete page number " + page_num + ". Do you want to continue?"}, action: { els: [ "exhibit_builder_outline_content", "exhibit_page" ], actions: [ "/builder/modify_outline_page",  "/builder/reset_exhibit_page_from_outline" ], params: params}, progress: { waitMessage: 'Please Wait...' }});
	else
		serverAction({action:{ els: "exhibit_builder_outline_content", actions: "/builder/modify_outline_page", params: params }});
}

////////////////////////////////////////////////////////////////////////////////////

// There is a lot of "bounce" where we get an unhover and hover events next to each other.
// We'll damp them out by putting a delay in the unhover that can get canceled by the next hover.
var unhoverlist = $H({});	// TODO-PER: This could be made private

function sectionHovered(el, edit_bar_id, addClass, removeClass)	// called as a mousehover event
{
	var initSelectCtrl = function(select_el_id, onchange_callback)
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
			var onInitDropDown = function() {
				var container = $(select_el_id + "_wrapper");
				setTimeout(function() {
					var menuEl = container.down('div');
					menuEl.setStyle({ zIndex: 50 });
				}, 50);
			};
			oMenuButton1.on("focus", onInitDropDown);

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
	};
	
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

function sectionUnhovered(el, edit_bar_id, addClass, removeClass)	// called as an onmouseout handler
{
	var doUnhover = function(el, edit_bar_id, addClass, removeClass)
	{
		if (unhoverlist.get(el.id) === 'waiting') {
			unhoverlist.set(el.id, 'cleared');
			$(el).addClassName(addClass);
			$(el).removeClassName(removeClass);
			//var edit_bar = $(el).down('.' + edit_bar_id);
			$(el).down('.' + edit_bar_id).addClassName('hidden');
		}
	};

	unhoverlist.set(el.id, 'waiting');
	doUnhover.delay(0.1, el, edit_bar_id, addClass, removeClass);
	return false;
}

