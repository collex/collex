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

/*global Class, $, $$, $H, Element, Ajax, Effect */
/*global YAHOO */
/*global MessageBoxDlg, hideSpinner, ConfirmDlg, InputDialog, getX, getY, currentScrollPos, doSingleInputPrompt, recurseUpdateWithAjax, CreateListOfObjects, GeneralDialog, pageRenumberFootnotes */
/*global document, window */
/*global supportsFixedPositioning */
/*extern editExhibitProfile, CreateSharingList, doAjaxLink, doAjaxLinkConfirm, doAjaxLinkOnPage, doAjaxLinkOnSelection, doRemoveObjectFromExhibit, doUnhover, editTag, elementTypeChanged, exhibit_outline, exhibit_outline_pos, hide_by_id, illustrationJustificationChanged, imgResized, initOutline, initSelectCtrl, initializeElementEditing, initializeResizableImageElement, initializeResizableTextualElement, open_by_id, removeTag, scroll_to_target, sectionHovered, sectionUnhovered, selectLine, setPageSelected, sharing_dialog, showExhibitOutline, toggleElementsByClass, toggle_by_id, unhoverlist, y_distance_that_the_element_is_not_in_view */

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

function toggleElementsByClass(cls)
{
	var els = $$('.'+cls);
	els.each(function(el){ el.toggle(); });
}

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
	new Ajax.Updater(element.id, "/my9s/change_img_width",
	{
		parameters : { illustration_id: illustrationElement.id, width: newWidth, height: newHeight },
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

function initializeResizableTextualElement( element_id ) {
	var widenableElement = $(element_id);
	var resizer = new YAHOO.util.Resize(widenableElement.id, {ratio:false, handles: ['r', 'l', 'b', 'br', 'bl' ]});
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
	};
	
	new ConfirmDlg("Delete Section", "You are about to delete this section. Do you want to continue?", "Yes", "No", del);
}

function doAjaxLinkOnSelection(verb, exhibit_id)
{
	// this is called from the outline, so we also need to update the regular page, too.
	var action = function(){
		var allElements = $$(".outline_tree_element_selected");
		if (allElements.length === 1) {
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
		if (allElements.length === 1) {
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
						//var page_id = $('current_page').innerHTML;
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
	};
	
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
		if (curr_page !== undefined)
			curr_page.addClassName('selected_page');
	}
}

function y_distance_that_the_element_is_not_in_view(element_id)
{
	// This returns the Y-distance that the window needs to scroll to get the named
	// element into view.
	var el = $(element_id);
	if (el === null)
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

function scroll_to_target(target_el, element_el)
{
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

	var target_el = 'top-of-' + el_id;
	if ($(target_el) !== null)
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
   }, exhibit_outline, true);

	exhibit_outline.setHeader("OUTLINE");
	exhibit_outline.render();
	
	if (supportsFixedPositioning)
		$(div_id + '_c').setStyle({ position: 'fixed'});
}

function editExhibitProfile(update_id, exhibit_id, data_class, populate_nines_obj_url, progress_img)
{
//	$(update_id).setAttribute('action', "/my9s/edit_exhibit_overview,/my9s/update_title");
//	$(update_id).setAttribute('ajax_action_element_id', "overview_data,overview_title");
	
	var data = $$("." + data_class);

	// Now populate a hash with all the starting values.	 The data we are starting with is all on the page with the data_class class.
	var values = {};
	data.each(function(fld) {
		values[fld.id + '_dlg'] = fld.innerHTML.unescapeHTML();
	});
	values.exhibit_id = exhibit_id;
	values.element_id = update_id;

	this.changeView = function (event, param)
	{
		var view = param.destination;
		var dlg = param.dlg;

		dlg.changePage(view, 'overview_title_dlg');

		return false;
	};

	this.sendWithAjax = function (event, params)
	{
		//var curr_page = params.curr_page;
		var dlg = params.dlg;
		var onComplete = function() {
			dlg.cancel();
		};

		var onFailure = function(resp) {
			dlg.setFlash(resp.responseText, true);
		};

		var retData = dlg.getAllData();
		retData.exhibit_id = exhibit_id;
		retData.element_id = update_id;

		recurseUpdateWithAjax(["/my9s/edit_exhibit_overview", "/my9s/update_title"], ["overview_data", "overview_title"], onComplete, onFailure, retData);
	};

	this.deleteExhibit = function(event, params)
	{
		var del = function(){
			window.location = "/my9s/delete_exhibit?id="+exhibit_id;
		};

		new ConfirmDlg('Delete Exhibit', 'Warning: This will permanently remove this exhibit. Are you sure you want to continue?', "Yes", "No", del);
	};

	var profile = {
			page: 'profile',
			rows: [
				[ { text: 'Exhibit Title:', klass: 'new_exhibit_title' }, { input: 'overview_title_dlg', value: values.overview_title_dlg, klass: 'new_exhibit_input_long' } ],
				[ { text: 'Visible URL:', klass: 'new_exhibit_title' }, { input: 'overview_visible_url_dlg', value: values.overview_visible_url_dlg, klass: 'new_exhibit_input_long' } ],
				[ { text: 'Thumbnail:', klass: 'new_exhibit_title' }, { input: 'overview_thumbnail_dlg', value: values.overview_thumbnail_dlg, klass: 'new_exhibit_input_long' } ],
				[ { page_link: '[Choose Thumbnail from Collected Objects]', callback: this.changeView, new_page: 'choose_thumbnail' }],
				[ { page_link: '[Completely Delete Exhibit]', callback: this.deleteExhibit }],
				[ { rowClass: 'last_row' }, { button: 'Save', callback: this.sendWithAjax }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
			]
		};

	var selectObject = function(id) {
		// This is a callback that is called when the user selects a NINES Object.
		var thumbnail = $('overview_thumbnail_dlg');
		var selection = $(id + '_img');
		thumbnail.value = selection.src;
	};
	var objlist = new CreateListOfObjects(populate_nines_obj_url, null, 'nines_object', progress_img, selectObject);

	var choose_thumbnail = {
			page: 'choose_thumbnail',
			rows: [
				[ { text: 'Choose Thumbnail from the list.', klass: 'new_exhibit_title' } ],
				[ { custom: objlist, klass: 'new_exhibit_label' } ],
				[ { rowClass: 'last_row' }, { button: 'Ok', url: 'profile', callback: this.changeView }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
			]
		};

	var pages = [ profile, choose_thumbnail ];

	var params = { this_id: "new_exhibit_wizard", pages: pages, body_style: "new_exhibit_div", row_style: "new_exhibit_row", title: "Edit Exhibit Profile" };
	var dlg = new GeneralDialog(params);
	this.changeView(null, { curr_page: '', destination: 'profile', dlg: dlg });
	dlg.center();
	objlist.populate(dlg, false, 'thumb');

	// First construct the dialog
//	var dlg = new InputDialog(update_id);
//	var size = 52;
//	dlg.addHidden('exhibit_id');
//	dlg.addTextInput('Exhibit title:', 'overview_title_dlg', size);
//	dlg.addTextInput('Visible URL:', 'overview_visible_url_dlg', size);
//	dlg.addTextInput('Thumbnail:', 'overview_thumbnail_dlg', size);
//	dlg.addLink("[ Completely Delete Exhibit ]", "/my9s/delete_exhibit?id="+exhibit_id, "new ConfirmLinkDlg(this, 'Delete Exhibit', 'Warning: This will permanently remove this exhibit. Are you sure you want to continue?'); return false;", "modify_link");
//
//	// Now, everything is initialized, fire up the dialog.
//	var el = $(update_id);
//	dlg.show("Edit Exhibit Overview", getX(el), getY(el), 530, 350, values );
//	el = $('overview_title_dlg');
//	if (el !== null) {
//		el.focus();
//		el.select();
//	}
}

var EditFontsDlg = Class.create({
	initialize : function(url, exhibit_id, exhibit_data)
	{
		var values = exhibit_data.exhibit;
		var options = [ { text: 'Arial', value: 'Arial'},
			{ text: 'Arial Black', value: 'Arial Black'},
			{ text: 'Courier New', value: 'Courier New'},
			{ text: 'Lucinda Console', value: 'Lucinda Console'},
			{ text: 'Tahoma', value: 'Tahoma'},
			{ text: 'Times New Roman', value: 'Times New Roman'},
			{ text: 'Trebuchet MS', value: 'Trebuchet MS'},
			{ text: 'Verdana', value: 'Verdana'}
		];

		var sizes = [ { text: '9', value: '9' }, { text: '10', value: '10' }, { text: '11', value: '11' }, { text: '12', value: '12' }, { text: '13', value: '13' },
			 { text: '14', value: '14' }, { text: '15', value: '15' }, { text: '16', value: '16' }, { text: '18', value: '18' }, { text: '20', value: '20' },
			 { text: '22', value: '22' }, { text: '24', value: '24' }, { text: '26', value: '26' }, { text: '28', value: '28' }, { text: '32', value: '32' },
			 { text: '36', value: '36' }, { text: '40', value: '40' }, { text: '44', value: '44' }, { text: '48', value: '48' }, { text: '54', value: '54' }
		];

		var ok = function (event, params)
		{
			//var curr_page = params.curr_page;
			var page = params.curr_page;
			var dlg = params.dlg;

			dlg.setFlash("Updating Fonts...", false);
			dlg.submitForm(page, url);
		};

		var updatePreview = function(field, new_value) {
			var parts = field.split('_');
			var preview_id = "preview_" + parts[1];
			if (parts[3] === 'size')
				$(preview_id).setStyle({ fontSize: new_value + "px" });
			else
				$(preview_id).setStyle({ fontFamily: new_value });
		};

		var layout = {
				page: 'layout',
				rows: [
					[ { text: 'Header:', klass: 'edit_font_label' }, { select: 'exhibit[header_font_name]', value: values.header_font_name, options: options, change: updatePreview}, { select: 'exhibit[header_font_size]', value: values.header_font_size, options: sizes, change: updatePreview } ],
					[ { text: 'Body Text:', klass: 'edit_font_label' }, { select: 'exhibit[text_font_name]', value: values.text_font_name, options: options, change: updatePreview}, { select: 'exhibit[text_font_size]', value: values.text_font_size, options: sizes, change: updatePreview } ],
					[ { text: 'Illustration:', klass: 'edit_font_label' }, { select: 'exhibit[illustration_font_name]', value: values.illustration_font_name, options: options, change: updatePreview}, { select: 'exhibit[illustration_font_size]', value: values.illustration_font_size, options: sizes, change: updatePreview } ],
					[ { text: 'First Caption:', klass: 'edit_font_label' }, { select: 'exhibit[caption1_font_name]', value: values.caption1_font_name, options: options, change: updatePreview}, { select: 'exhibit[caption1_font_size]', value: values.caption1_font_size, options: sizes, change: updatePreview } ],
					[ { text: 'Second Caption:', klass: 'edit_font_label' }, { select: 'exhibit[caption2_font_name]', value: values.caption2_font_name, options: options, change: updatePreview}, { select: 'exhibit[caption2_font_size]', value: values.caption2_font_size, options: sizes, change: updatePreview } ],
					[ { text: 'Endnotes:', klass: 'edit_font_label' }, { select: 'exhibit[endnotes_font_name]', value: values.endnotes_font_name, options: options, change: updatePreview}, { select: 'exhibit[endnotes_font_size]', value: values.endnotes_font_size, options: sizes, change: updatePreview } ],
					[ { rowClass: 'last_row' }, { button: 'Save', callback: ok }, { button: 'Cancel', callback: GeneralDialog.cancelCallback }, { hidden: 'id', value: exhibit_id } ]
				]
			};

		var params = { this_id: "edit_font_dlg", pages: [ layout ], body_style: "edit_font_div", row_style: "new_exhibit_row", title: "Edit Exhibit Fonts" };
		var dlg = new GeneralDialog(params);
		dlg.changePage('layout', null);
		dlg.center();

		var div = $('edit_font_dlg');
		var div2 = div.down('.bd');
		var preview = new Element('div');
		preview.addClassName('font_preview');
		preview.appendChild(new Element('h3', { id: 'preview_header' }).update("Header"));
		var illustration = new Element('div', { style: "float: right;" });
		illustration.appendChild(new Element('div', { id: 'preview_illustration' }).update("Textual Illustration."));
		var caption1 = new Element('div', { id: 'preview_caption1' }).update("Caption 1");
		illustration.appendChild(caption1);
		caption1.appendChild(new Element('div', { id: 'preview_caption2' }).update("Caption 2"));
		preview.appendChild(illustration);
		preview.appendChild(new Element('div', { id: 'preview_text' }).update("Paragraph of text."));
		preview.appendChild(new Element('div', { id: 'preview_endnotes', style: 'clear:both;' }).update("<span class='endnote_superscript'>1</span>Endnote"));
		div2.insert({ top: preview });
		div2.down(".last_row").addClassName('clear_both');

		$('preview_header').setStyle({ fontFamily: values.header_font_name, fontSize: values.header_font_size + 'px', marginTop: '1px', marginBottom: '5px' });
		$('preview_header').addClassName('exhibit_header');
		$('preview_illustration').setStyle({ fontFamily: values.illustration_font_name, fontSize: values.illustration_font_size + 'px' });
		$('preview_illustration').addClassName('exhibit_illustration_text');
		$('preview_caption1').setStyle({ fontFamily: values.caption1_font_name, fontSize: values.caption1_font_size + 'px' });
		$('preview_caption1').addClassName('exhibit_caption1');
		$('preview_caption2').setStyle({ fontFamily: values.caption2_font_name, fontSize: values.caption2_font_size + 'px' });
		$('preview_caption2').addClassName('exhibit_caption2');
		$('preview_text').setStyle({ fontFamily: values.text_font_name, fontSize: values.text_font_size + 'px' });
		$('preview_endnotes').setStyle({ fontFamily: values.endnotes_font_name, fontSize: values.endnotes_font_size + 'px' });
	}
});

var CreateSharingList = Class.create({
	list : null,
	initialize : function(items, initial_selection, value_field)
	{
		var This = this;
		This.list = "<table class='input_dlg_list input_dlg_license_list' cellspacing='0'>";
		var iCount = 0;
		items.each(function(obj) {
			This.list += This.constructItem(obj.text, obj.icon, iCount, iCount === initial_selection, value_field);
			iCount++;
		});
		This.list += "</table>";
	},

	constructItem: function(text, icon, index, is_selected, value_field)
	{
		var str = "";
		if (is_selected)
			str = " class='input_dlg_list_item_selected' ";
		return "<tr " + str + "onclick='CreateSharingList.prototype.select(this,\"" + value_field + "\" );' index='" + index + "' >" +
		"<td>" + icon + "</td><td>" + text + "</td></tr>\n";
	}
});

CreateSharingList.prototype.select = function(item, value_field)
{
	var selClass = "input_dlg_list_item_selected";
	$$("." + selClass).each(function(el)
	{
		el.removeClassName(selClass);
	});
	$(item).addClassName(selClass);
	$(value_field).value = $(item).getAttribute('index');
};

function sharing_dialog(licenseInfo, iShareStart, exhibit_id, update_id, callback_url)
{
	// Now populate a hash with all the starting values.	 The data we are starting with is all on the page with the data_class class.
	var values = {};
	var value_field = 'sharing';
	values[value_field] = iShareStart;
	values.exhibit_id = exhibit_id;
	values.element_id = update_id;
	$(update_id).writeAttribute('action', callback_url);
	$(update_id).writeAttribute('ajax_action_element_id', update_id);

	// First construct the dialog
	var dlg = new InputDialog(update_id);
	//var size = 52;
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
		//var edit_bar = $(el).down('.' + edit_bar_id);
		$(el).down('.' + edit_bar_id).addClassName('hidden');
	}
}

function sectionUnhovered(el, edit_bar_id, addClass, removeClass)
{
	unhoverlist.set(el.id, 'waiting');
	doUnhover.delay(0.1, el, edit_bar_id, addClass, removeClass);
	return false;
}

//////////////////////////////////////////////////////////////

function doRemoveObjectFromExhibit(exhibit_id, uri)
{
	var reference = $("in_exhibit_" + exhibit_id + "_" + uri);
	if (reference !== null)
		reference.remove();
	new Ajax.Updater("exhibited_objects_container", "/my9s/remove_exhibited_object", {
		parameters : { uri: uri, exhibit_id: exhibit_id },
		onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
	});
}

function editTag(parent_id, tag_name)
{
	doSingleInputPrompt("Edit Tag", 'Tag:', 'new_name', parent_id,
		"",
		"/results/edit_tag",
		$H({ old_name: tag_name, new_name: tag_name }), 'text', null, null );
}

function removeTag(parent_id, tag_name)
{
	var remove = function()
	{
		var new_form = new Element('form', { id: "remove_tag", method: 'post', onsubmit: "this.submit();", action: "/results/remove_all_tags" });
		new_form.observe('submit', "this.submit();");
		document.body.appendChild(new_form);
		new_form.appendChild(new Element('input', { name: 'tag', value: tag_name, id: 'tag' }));

		$(parent_id).appendChild(new Element('img', { src: "/images/ajax_loader.gif", alt: ''}));
		new_form.submit();
	};
	new ConfirmDlg("Remove Tag", "Are you sure you want to remove all instances of the \"" + tag_name + "\" tag that you created?", "Yes", "No", remove);
}

