/** 
 *  Copyright 2007 Applied Research in Patacriticism and the University of Virginia
 * 
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 **/

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// perform initialization after DOM loads
Event.observe(window, 'load', function() {	
	// initialize hacks whenever the page loads
	initializeHacks();
});	

function open_tree(event, id)
{
	var This = $("site_opened_" + id);
	var That = $("site_closed_" + id);
	This.addClassName('hidden');
	That.removeClassName('hidden');
	var child_class = "child_of_" + id;
	var children = $$('.' + child_class);
	children.each(function(child) { child.removeClassName('hidden')});
}

function close_tree(event, id)
{
	var This = $("site_closed_" + id);
	var That = $("site_opened_" + id);
	This.addClassName('hidden');
	That.removeClassName('hidden');
	var child_class = "child_of_" + id;
	var children = $$('.' + child_class);
	children.each(function(child) { child.addClassName('hidden')});
}

function toggle_tree(event, id)
{
	var open = $("site_opened_" + id);
	if (open.hasClassName('hidden'))
		close_tree(event, id);
	else
		open_tree(event, id);
}

function showResultRowImage(This, max_size, progress_id)
{
	// This is called after the result row thumbnail has finished loading.
	// At the start of this function, the progress spinner is on the page and the thumbnail is hidden.
	// This sizes and centers the image, removes the spinner, and unhides the image.
	var img = $(This);
	var width = img.width;
	var height = img.height;
	if (height > width && height > 100) {
		// shrink the height
		img.height = 100;
	} else if (width >= height && width > 100) {
		// shrink the width
		img.width = 100;
	}

	// Add padding so that the image is centered vertically.
	var padding = (100 - height) / 2;
	if (padding > 0)
		img.setStyle({ paddingTop: padding + "px" });

	$(progress_id).remove();
	img.removeClassName('hidden');
}

function toggleIt(element) {
  var tr = element.parentNode.parentNode;
  var className = tr.className;
  if (node_before(tr).className == className) { 
    tr = node_before(tr);
  }

  while (true) {
    Element.toggle(tr);
    tr = node_after(tr);
    if (tr == null || tr.className != className) break;
  }
}

// deselect all checkboxes within the specified div 
function deselectAll(target) {
	var checkboxes = $(target).select( 'input[type=checkbox]' );
	for (var i=0; i < checkboxes.length; i++) {  
		var checkbox = checkboxes[i];
		checkbox.checked = false;
	}		
}

// select all checkboxes within the specified div 
function selectAll(target) {
	var checkboxes = $(target).select( 'input[type=checkbox]' );
	for (var i=0; i < checkboxes.length; i++) {  
		var checkbox = checkboxes[i];
		checkbox.checked = true;
	}		
}

function toggleCategory(category_id) {
	elems = document.getElementsByClassName("cat_" + category_id + "_child");

	Element.toggle("cat_" + category_id + "_opened");
	Element.toggle("cat_" + category_id + "_closed");

	for (var i=0; i < elems.length; i++) {  
		if ( elems[i].hasClassName("noshow") ) {
			Element.removeClassName(elems[i], "noshow");
		} else {
			Element.addClassName(elems[i], "noshow");
		}
	}	
}

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

function popUp(URL) {
  day = new Date();
  id = day.getTime();
  eval("page" + id + " = window.open(URL, '" + id + "', 'toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=0,resizable=1,width=300,height=400');");
}

/** Note: methods below are needed to overcome a bug in Firefox.  An explanation
 *        is at:
 *         
 *        http://developer.mozilla.org/en/docs/Whitespace_in_the_DOM
 */
     
/**
 * Version of |previousSibling| that skips nodes that are entirely
 * whitespace or comments.  (Normally |previousSibling| is a property
 * of all DOM nodes that gives the sibling node, the node that is
 * a child of the same parent, that occurs immediately before the
 * reference node.)
 *
 * @param sib  The reference node.
 * @return     Either:
 *               1) The closest previous sibling to |sib| that is not
 *                  ignorable according to |is_ignorable|, or
 *               2) null if no such node exists.
 */
function node_before( sib )
{
  while ((sib = sib.previousSibling)){
    if (!is_ignorable(sib)) return sib;
  }
  return null;
}

/**
 * Version of |nextSibling| that skips nodes that are entirely
 * whitespace or comments.
 *
 * @param sib  The reference node.
 * @return     Either:
 *               1) The closest next sibling to |sib| that is not
 *                  ignorable according to |is_ignorable|, or
 *               2) null if no such node exists.
 */
function node_after( sib ) {
  while ((sib = sib.nextSibling)){
    if (!is_ignorable(sib)) return sib;
  }
  return null;
}

/**
 * Determine if a node should be ignored by the iterator functions.
 *
 * @param nod  An object implementing the DOM1 |Node| interface.
 * @return     true if the node is:
 *                1) A |Text| node that is all whitespace
 *                2) A |Comment| node
 *             and otherwise false.
 */

function is_ignorable( nod ){
  return ( nod.nodeType == 8) || // A comment node
         ( (nod.nodeType == 3) && is_all_ws(nod) ); // a text node, all ws
}

/**
 * Determine whether a node's text content is entirely whitespace.
 *
 * @param nod  A node implementing the |CharacterData| interface (i.e.,
 *             a |Text|, |Comment|, or |CDATASection| node
 * @return     True if all of the text content of |nod| is whitespace,
 *             otherwise false.
 */
function is_all_ws( nod ){
  // Use ECMA-262 Edition 3 String and RegExp features
  return !(/[^\t\n\r ]/.test(nod.data));
}


// borrowed from http://developer.apple.com/internet/webcontent/examples/popup.html

// Copyright © 2000 by Apple Computer, Inc., All Rights Reserved.
//
// You may incorporate this Apple sample code into your own code
// without restriction. This Apple sample code has been provided "AS IS"
// and the responsibility for its operation is yours. You may redistribute
// this code, but you are not permitted to redistribute it as
// "Apple sample code" after having made changes.
//
// ************************
// layer utility routines *
// ************************

function getStyleObject(objectId) {
    // cross-browser function to get an object's style object given its id
    if(document.getElementById && document.getElementById(objectId)) {
	// W3C DOM
	return document.getElementById(objectId).style;
    } else if (document.all && document.all(objectId)) {
	// MSIE 4 DOM
	return document.all(objectId).style;
    } else if (document.layers && document.layers[objectId]) {
	// NN 4 DOM.. note: this won't find nested layers
	return document.layers[objectId];
    } else {
	return false;
    }
} // getStyleObject

function changeObjectVisibility(objectId, newVisibility) {
    // get a reference to the cross-browser style object and make sure the object exists
    var styleObject = getStyleObject(objectId);
    if(styleObject) {
	styleObject.visibility = newVisibility;
	return true;
    } else {
	// we couldn't find the object, so we can't change its visibility
	return false;
    }
} // changeObjectVisibility

function moveObject(objectId, newXCoordinate, newYCoordinate) {
    // get a reference to the cross-browser style object and make sure the object exists
    var styleObject = getStyleObject(objectId);
    if(styleObject) {
	styleObject.left = "" + (newXCoordinate-500) + "px";
	styleObject.top = "" + (newYCoordinate-50) + "px";
	return true;
    } else {
	// we couldn't find the object, so we can't very well move it
	return false;
    }
} // moveObject

function moveObject2(objectId, newXCoordinate, newYCoordinate) {
    // get a reference to the cross-browser style object and make sure the object exists
    var styleObject = getStyleObject(objectId);
    if(styleObject) {
	styleObject.left = "" + (newXCoordinate) + "px";
	styleObject.top = "" + (newYCoordinate) + "px";
	return true;
    } else {
	// we couldn't find the object, so we can't very well move it
	return false;
    }
} // moveObject




// Copyright © 2000 by Apple Computer, Inc., All Rights Reserved.
//
// You may incorporate this Apple sample code into your own code
// without restriction. This Apple sample code has been provided "AS IS"
// and the responsibility for its operation is yours. You may redistribute
// this code, but you are not permitted to redistribute it as
// "Apple sample code" after having made changes.
// ********************************
// application-specific functions *
// ********************************

// store variables to control where the popup will appear relative to the cursor position
// positive numbers are below and to the right of the cursor, negative numbers are above and to the left

//var agt=navigator.userAgent.toLowerCase()
//var is_ie  = agt.indexOf("msie") != -1

// internet explorer sucks and needs to be tricked into getting the right offset
//if (is_ie)
//{
//  var xOffset = 240;
//}
//else
//{
//  var xOffset = 30;
//}
//var yOffset = -5;

//function showPopup (targetObjectId, eventObj) {
//    if(eventObj) {
//	// hide any currently-visible popups
//	hideCurrentPopup();
//	// stop event from bubbling up any farther
//	eventObj.cancelBubble = true;
//	// move popup div to current cursor position 
//	// (add scrollTop to account for scrolling for IE)
//	var newXCoordinate = (eventObj.pageX)?eventObj.pageX + xOffset:eventObj.x + xOffset + ((document.body.scrollLeft)?document.body.scrollLeft:0);
//	var newYCoordinate = (eventObj.pageY)?eventObj.pageY + yOffset:eventObj.y + yOffset + ((document.body.scrollTop)?document.body.scrollTop:0);
//	moveObject(targetObjectId, newXCoordinate, newYCoordinate);
//	// and make it visible
//	if( changeObjectVisibility(targetObjectId, 'visible') ) {
//	    // if we successfully showed the popup
//	    // store its Id on a globally-accessible object
//	    window.currentlyVisiblePopup = targetObjectId;
//	    return true;
//	} else {
//	    // we couldn't show the popup, boo hoo!
//	    return false;
//	}
//    } else {
//	// there was no event object, so we won't be able to position anything, so give up
//	return false;
//    }
//} // showPopup
//
//function hideCurrentPopup() {
//    // note: we've stored the currently-visible popup on the global object window.currentlyVisiblePopup
//    if(window.currentlyVisiblePopup) {
//	changeObjectVisibility(window.currentlyVisiblePopup, 'hidden');
//	window.currentlyVisiblePopup = false;
//    }
//} // hideCurrentPopup



// ***********************
// hacks and workarounds *
// ***********************

// setup an event handler to hide popups for generic clicks on the document
//document.onclick = hideCurrentPopup;

function initializeHacks() {
    // this ugly little hack resizes a blank div to make sure you can click
    // anywhere in the window for Mac MSIE 5
    if ((navigator.appVersion.indexOf('MSIE 5') != -1) 
	&& (navigator.platform.indexOf('Mac') != -1)
	&& getStyleObject('blankDiv')) {
	window.onresize = explorerMacResizeFix;
    }
    resizeBlankDiv();
    // this next function creates a placeholder object for older browsers
    createFakeEventObj();
}

function createFakeEventObj() {
    // create a fake event object for older browsers to avoid errors in function call
    // when we need to pass the event object to functions
    if (!window.event) {
	window.event = false;
    }
} // createFakeEventObj

function resizeBlankDiv() {
    // resize blank placeholder div so IE 5 on mac will get all clicks in window
    if ((navigator.appVersion.indexOf('MSIE 5') != -1) 
	&& (navigator.platform.indexOf('Mac') != -1)
	&& getStyleObject('blankDiv')) {
	getStyleObject('blankDiv').width = document.body.clientWidth - 20;
	getStyleObject('blankDiv').height = document.body.clientHeight - 20;
    }
}

function explorerMacResizeFix () {
    location.reload(false);
}

// -----

function bulkTag(event)
{
	var checkboxes = Form.getInputs('bulk_collect_form', 'checkbox');
	
	var uris = "";
	var has_one = false;
	for (i = 0; i < checkboxes.length; i++) {
		var checkbox = checkboxes[i];
		if (checkbox.checked) {
			uris += checkbox.value + '\t';
			has_one = true;
		}
	}
	
	if (has_one)
	{
		doSingleInputPrompt("Add Tag To All Checked Objects", 'Tag:', 'tag', 'bulk_tag', 
			"",
			"/results/bulk_add_tag", 
			$H({ uris: uris }), 'text', null, null );
	}
	else
	{
		new MessageBoxDlg("Error", "You must select one or more objects before clicking this button.")
	}
}

function bulkCollect(event)
{
	var checkboxes = Form.getInputs('bulk_collect_form', 'checkbox');
	
	var has_one = false;
	for (i = 0; i < checkboxes.length; i++) {
		var checkbox = checkboxes[i];
		if (checkbox.checked) {
			has_one = true;
		}
	}
	
	if (has_one)
	{
		var form = document.getElementById('bulk_collect_form');
		form.submit();
	}
	else
	{
		new MessageBoxDlg("Error", "You must select one or more objects before clicking this button.")
	}
}

bulk_checked = false;

function toggleAllBulkCollectCheckboxes(link) {
  bulk_checked = !bulk_checked;
  checkboxes = Form.getInputs('bulk_collect_form', 'checkbox');
  for (i=0; i < checkboxes.length; i++) {
    checkbox = checkboxes[i];
    checkbox.checked = bulk_checked;
  }

  elements = document.getElementsByClassName('bulk_select_all');
  for (i=0; i<elements.length; i++) {
    elements[i].toggle();
  }

  elements = document.getElementsByClassName('bulk_unselect_all');
  for (i=0; i<elements.length; i++) {
    elements[i].toggle();
  }
}

//
// functions that handle the AJAX inside a result div
//

function getViewportWidth()
{
    return (document.documentElement.clientWidth || document.body.clientWidth);
}

function getViewportHeight()
{
    return (document.documentElement.clientHeight || document.body.clientHeight);
}

function getX( oElement )
{
	var iReturnValue = 0;
	while( oElement != null ) {
		iReturnValue += oElement.offsetLeft;
		oElement = oElement.offsetParent;
	}
	return iReturnValue;
}

function getY( oElement )
{
	var iReturnValue = 0;
	while( oElement != null ) {
		iReturnValue += oElement.offsetTop;
		oElement = oElement.offsetParent;
	}
	return iReturnValue;
}


function currentScrollPos() {
	var pos = [
		f_filterResults (
			window.pageXOffset ? window.pageXOffset : 0,
			document.documentElement ? document.documentElement.scrollLeft : 0,
			document.body ? document.body.scrollLeft : 0
		),
		f_filterResults (
			window.pageYOffset ? window.pageYOffset : 0,
			document.documentElement ? document.documentElement.scrollTop : 0,
			document.body ? document.body.scrollTop : 0
		)];
		return pos;
}

function f_filterResults(n_win, n_docel, n_body) {
	var n_result = n_win ? n_win : 0;
	if (n_docel && (!n_result || (n_result > n_docel)))
		n_result = n_docel;
	return n_body && (!n_result || (n_result > n_body)) ? n_body : n_result;
}

function moveObjectToJustBelowItsParent(target_id, parent_id)
{
	// Get the absolute location of the parent
	var par = document.getElementById(parent_id);
	var x = getX(par);
	var y = getY(par);
	
	// Get the right side of the parent and the target: we want to right justify
	var targ = document.getElementById(target_id);
	var targ_width = parseInt(targ.style.width);	// This includes the trailing 'px'
	var par_width = par.offsetWidth;
	var newXCoordinate = x + ((document.body.scrollLeft)?document.body.scrollLeft:0) - targ_width + par_width;
	var newYCoordinate = y + ((document.body.scrollTop)?document.body.scrollTop:0) + par.offsetHeight;
	moveObject2(target_id, newXCoordinate, newYCoordinate);
}

function moveObjectToLeftTopOfItsParent(target_id, parent_id)
{
	// Get the absolute location of the parent
	var par = document.getElementById(parent_id);
	var x = getX(par);
	var y = getY(par);
	
	var newXCoordinate = x + ((document.body.scrollLeft)?document.body.scrollLeft:0);
	var newYCoordinate = y + ((document.body.scrollTop)?document.body.scrollTop:0);
	
	// Adjust the width if the dialog would be off the side of the page
	var max_x = document.width;
	var t = $(target_id);
	var w = parseInt(t.getStyle('width'));
	var max_x = document.width - w - 10;	// Add a little margin so it is not right against the page.
	if (newXCoordinate > max_x)
		newXCoordinate = max_x;
	moveObject2(target_id, newXCoordinate, newYCoordinate);
}

// This gets the "full text" field in the search results. That is not saved in the cache,
// so if we do Ajax operations on a row with full text, then we would lose it. Therefore,
// we read it, then send it back to the server.
function getFullText(row_id)
{
	var el_full_text = document.getElementById(row_id+ "_full_text");
	var full_text = "";
	if (el_full_text)
		full_text = encodeForUri(el_full_text.innerHTML);
	return full_text;	
}

function removeHidden(more_id, target_id)
{
	// This toggles, so see if the more_id contains the text "more" or "less"
	var btn = $(more_id);
	if (btn.innerHTML.indexOf("more") > 0) {
		$$('#' + target_id + " .hidden").each(function (el) {
			if( el.tagName !== "IMG")
				el.removeClassName('hidden'); el.addClassName('was_hidden');
		});
		btn.update(btn.innerHTML.gsub("more", "less"));
		//btn.innerHTML = btn.innerHTML.gsub("more", "less");
	} else {
		$$('#' + target_id + " .was_hidden").each(function (el) { el.addClassName('hidden'); });
		btn.update(btn.innerHTML.gsub("less", "more"));
	}
}

function expandAllItems()
{
	$$('.search_result_data .hidden').each(function (el) { el.removeClassName('hidden'); el.addClassName('was_hidden'); });
	$$('.more').each(function (el) { el.update(el.innerHTML.gsub("more", "less")); });
}

var StartDiscussionWithObject = Class.create({
	initialize: function (url_get_topics, url_update, uri, discussion_button, is_logged_in) {
		// This puts up a modal dialog that allows the user to select the objects to be in this exhibit.
		this.class_type = 'StartDiscussionWithObject';	// for debugging

		// private variables
		var This = this;
		
		// private functions
		var populate = function()
		{
			new Ajax.Request(url_get_topics, { method: 'get', parameters: { },
				onSuccess : function(resp) {
					var topics = null;
					dlg.setFlash('', false);
					try {
						topics = resp.responseText.evalJSON(true);
					} catch (e) {
						new MessageBoxDlg("Error", e);
					}
					// We got all the users. Now put it on the dialog
					var sel_arr = $$('.discussion_topic_select');
					var select = sel_arr[0];
					select.update('');
					topics = topics.sortBy(function(topic) { return topic.text; });
					topics.each(function(topic) {
						select.appendChild(new Element('option', { value: topic.value }).update(topic.text));
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
			
			dlg.setFlash('Updating Discussion Topics...', false);
			var data = dlg.getAllData();
			data.inet_thumbnail = "";
			data.thread_id = "";
			data.nines_exhibit = "";
			data.description = "";	// TODO: Do we want to let the user enter something for this?
			data.nines_object = uri;
			data.inet_url = "";
			data.disc_type = "NINES Object";

			var x = new Ajax.Request(url, {
				parameters : data,
				evalScripts : true,
				onSuccess : function(resp) {
					$(discussion_button).hide();
					dlg.cancel();
				},
				onFailure : function(resp) {
					dlg.setFlash(resp.responseText, true);
				}
			});
		};
		
		var dlgLayout = {
				page: 'start_discussion',
				rows: [
					[ { text: 'Select the topic you want this discussion to appear under', klass: 'new_exhibit_instructions' } ],
					[ { select: 'topic_id', klass: 'discussion_topic_select', options: [ { value: -1, text: 'Loading user names. Please Wait...' } ] } ],
					[ { button: 'Ok', url: url_update, callback: this.sendWithAjax }, { button: 'Cancel', callback: this.cancel } ]
				]
			};

		var params = { this_id: "edit_exhibit_object_list_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Choose Discussion Topic" };
		var dlg = new GeneralDialog(params);
		dlg.changePage('start_discussion', null);
		dlg.center();
		populate(dlg);
	}
});

function doDiscuss(uri, discussion_button, is_logged_in)
{
	if (!is_logged_in) {
		var dlg = new SignInDlg();
		dlg.setInitialMessage("Please log in to discuss objects");
		dlg.show('sign_in');
		return;
	}
	
//	 "description"=>"", "topic_id"=>"2"
//	 
//	 "disc_type"=>"NINES Object"
//	 "nines_object"=>"http://www.rossettiarchive.org/docs/s228.raw"
//	/forum/post_object_to_new_thread

	doSingleInputPrompt('Discussion', 'Not so fast! We haven\'t implemented the Discussion feature, yet', null, id, null, null, $H({ }), 'none', null, "Ok");
}

function doCollect(uri, row_num, row_id, is_logged_in)
{
	if (!is_logged_in) {
		var dlg = new SignInDlg();
		dlg.setInitialMessage("Please log in to collect objects");
		dlg.show('sign_in');
		return;
	}
	
	var ptr = $(row_id);
	ptr.removeClassName('result_without_tag');
	ptr.addClassName('result_with_tag');
	var full_text = getFullText(row_id);
	
	new Ajax.Updater(row_id, "/results/collect", {
		parameters : "uri="+ encodeForUri(uri) + "&row_num=" + row_num + "&full_text=" + full_text,
		evalScripts : true,
		onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
	});
}

function doRemoveTag(uri, row_id, tag_name)
{
	var full_text = getFullText(row_id);
	var row_num = row_id.substring(row_id.lastIndexOf('_')+1);

	new Ajax.Updater(row_id, "/results/remove_tag", {
		parameters : "uri="+ encodeForUri(uri) + "&row_num=" + row_num + "&tag=" + encodeForUri(tag_name) + "&full_text=" + full_text,
		evalScripts : true,
		onComplete : tagFinishedUpdating,
		onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
	});
}

function doRemoveCollect(uri, row_num, row_id)
{
	if (confirm("Are you sure you want to uncollect this object?"))
	{
		var tr = document.getElementById(row_id);
		tr.className = 'result_without_tag'; 
		var full_text = getFullText(row_id);
		
		new Ajax.Updater(row_id, "/results/uncollect", {
			parameters : "uri="+ encodeForUri(uri) + "&row_num=" + row_num + "&full_text=" + full_text,
			evalScripts : true,
			onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
		});
	}
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
	if (confirm("Are you sure you want to remove all instances of the " + tag_name + " tag that you created?"))
	{
		var new_form = new Element('form', { id: "remove_tag", method: 'post', onsubmit: "this.submit();", action: "/results/remove_all_tags" });
		new_form.observe('submit', "this.submit();");
		document.body.appendChild(new_form);
		new_form.appendChild(new Element('input', { name: 'tag', value: tag_name, id: 'tag' }));

		$(parent_id).appendChild(new Element('img', { src: "/images/ajax_loader.gif", alt: ''}));
		new_form.submit();
	}
}

function doAddTag(parent_id, uri, row_num, row_id)
{
	doSingleInputPrompt("Add Tag", 'Tag:', 'tag', parent_id, 
		row_id + ",tag_cloud_div",
		"/results/add_tag,/tag/update_tag_cloud", 
		$H({ uri: uri, row_num: row_num, row_id: row_id, full_text: getFullText(row_id) }), 'text', null, null );
}

function realLinkToEditorLink(str) {
	// Turn real links into our links. Take this:
	//	<a class="ext_link" target="_blank" href="http://example.com">example</a>
	// and turn it into:
	//	<span class="ext_linklike" real_link="http://example.com" title="NINES Object: http://example.com">example</span>
	var i = str.indexOf("<a");
	if (i < 0)		// If there is no link, we're done.
		return str;
	var prologue = str.substring(0, i);	// strip off and save the part of the string before the link.
	var link = str.substring(i);
	i = link.indexOf("</a>");
	if (i < 0)		// If there is something illformed at any time, then just bail and return the original string.
		return str;
	var ending = link.substring(i+4);	// strip off and save the part of the string after the link.
	link = link.substring(0, i);
	var type = 'ext_linklike';	// If we find nines_link we know what it is, otherwise it is an ext_link. That catches links we didn't make.
	var type2 = 'External Link';
	if (link.indexOf('nines_link') > 0) {
		type = 'nines_linklike';
		type2 = 'NINES Object';
	}
	i = link.indexOf('href=');	// find the actual link.
	if (i < 0)
		return str;
	link = link.substring(i+6);
	i = link.indexOf('"');	// could be either kind of quote, so look for both
	var j = link.indexOf("'");
	if (i < 0)
		i = j;
	else {
		if (j >= 0 && j < i)
			i = j;
	}
	var addr = link.substring(0, i);
	i = link.indexOf('>');
	if (i < 0)
		return str;
	var text = link.substring(i+1);
	link = '<span class="' + type + '" real_link="' + addr + '" title="' + type2 + ': ' + addr +'">' + text + '</span>';
	return realLinkToEditorLink(prologue + link + ending);	// call recursively to get all the links
}

function doAnnotation(parent_id, uri, row_num, row_id, curr_annotation_id)
{
	var existing_note = $(curr_annotation_id).innerHTML;
	existing_note = existing_note.gsub("<br />", "\n");
	existing_note = existing_note.gsub("<br>", "\n");
	existing_note = realLinkToEditorLink(existing_note);

	doSingleInputPrompt("Edit Private Annotation", 'Annotation:', 'note', parent_id, 
		row_id,
		"/results/set_annotation", 
		$H({ uri: uri, row_num: row_num, full_text: getFullText(row_id), note: existing_note }), 'textarea',
		$H({ width: 370, height: 100, linkDlgHandler: new LinkDlgHandler() }), null );
}

function tagFinishedUpdating()
{
	var el_sidebar = document.getElementById('tag_cloud_div');
	if (el_sidebar)
	{
		new Ajax.Updater('tag_cloud_div', "/tag/update_tag_cloud", {
			onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
		});
	}
}

function doRemoveObjectFromExhibit(exhibit_id, uri)
{
	var reference = $("in_exhibit_" + exhibit_id + "_" + uri);
	if (reference != null)
		reference.remove();
	new Ajax.Updater("exhibited_objects_container", "/my9s/remove_exhibited_object", {
		parameters : { uri: uri, exhibit_id: exhibit_id },
		onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
	});
}

function doAddToExhibit(uri, index, row_id)
{
	var arr = row_id.split('-');
	var row_num = arr[arr.length-1];
	
	doSingleInputPrompt("Choose exhibit", 
		'Exhibit:', 
		'exhibit', 
		"exhibit_" + index,
		row_id + ",exhibited_objects_container",
		"/results/add_object_to_exhibit,/my9s/resend_exhibited_objects", 
		$H({ uri: uri, index: index, row_num: row_num }), 'select',
		exhibit_names, null);
}

function cancel_edit_profile_mode(partial_id)
{
	new Ajax.Updater(partial_id, "/my9s/update_profile", {
		onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
	});
}

function enter_edit_profile_mode(partial_id)
{
	new Ajax.Updater(partial_id, "/my9s/enter_edit_profile_mode", {
		onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
	});
}

//function update_profile(partial_id)
//{
//	new Ajax.Updater(partial_id, "/my9s/update_profile", {
//		parameters : "fullname="+ encodeForUri($("fullname").value) + 
//			"&institution=" + encodeForUri($("institution").value) + 
//			"&link=" + encodeForUri($("link").value) + 
//			"&aboutme=" + encodeForUri($("aboutme").value),
//		onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
//	});
//}

function encodeForUri(str)
{
	var value = str.gsub('%', '%25');
	value = value.gsub('#', '%23');
	value = value.gsub('&', '%26');
	value = value.gsub(/\?/, '%3f');
	return value;
}

function doSaveSearch(parent_id)
{
	doSingleInputPrompt("Save Search", 'Name:', 'saved_search_name', parent_id, 
		"saved_search_name_span",
		"/search/save_search", 
		$H({ }), 'text', null, null );
}

function showString(parent_id, str)
{
	doSingleInputPrompt("Copy and Paste link into E-mail or IM", 'Link:', 'show_save_name', parent_id, 
		null,
		null, 
		$H( { show_save_name: str } ), 'text', $H( { width: 70 } ), "Ok" );
}

function setTagVisibility(zoom_level)
{
	var spans = $$('#tagcloud span');
	for (i = 0; i < spans.length; i++)
	{
		var classname = spans[i].className;
		var level = parseInt(classname.substring(5));
		spans[i].style.display = (level >= zoom_level) ? 'inline' : 'none';
	}
}

function doZoom(level)
{
	switch (level)
	{
		case "+": if (zoom_level < 10) zoom_level++; break;
		case "-": if (zoom_level > 1) zoom_level--; break;
		case "1": zoom_level = 1; break;
		case "2": zoom_level = 2; break;
		case "3": zoom_level = 3; break;
		case "4": zoom_level = 4; break;
		case "5": zoom_level = 5; break;
		case "6": zoom_level = 6; break;
		case "7": zoom_level = 7; break;
		case "8": zoom_level = 8; break;
		case "9": zoom_level = 9; break;
		case "10": zoom_level = 10; break;
	}
	setTagVisibility(zoom_level);
	
	var thumb = $('tag_zoom_thumb');
	thumb.style.top = "" + (306 - zoom_level*8) + "px";
	
	if (_dragElement == null)
		new Ajax.Updater("", "/tag/set_zoom", { parameters : "level="+ zoom_level } );

}

var _startY = 0;  // mouse starting positions 
var _offsetY = 0;  // current element offset 
var _dragElement; // needs to be passed from OnMouseDown to OnMouseMove 
var _oldZIndex = 0; // we temporarily increase the z-index during drag
var _curr_pos = 0;

function IsDraggable(target)
{
	// If any parent of what is clicked is draggable, the element is draggable.
	while (target) {
		if (target.id == 'tag_zoom_thumb') 
			return target;
		target = target.parentNode;
	}
	return null;
}

function ZoomThumbMouseDown(e)
{
	 // IE doesn't pass the event object
	 if (e == null) e = window.event;
	 // IE uses srcElement, others use target
	 var target = e.target != null ? e.target : e.srcElement;
	 target = IsDraggable(target);
	  
	  // for IE, left click == 1
	  // for Firefox, left click == 0
	  
	  if ((e.button == 1 && window.event != null || e.button == 0) && target != null) {
	  	// grab the mouse position
	  	_startY = e.clientY;
	  	// grab the clicked element's position
	  	_offsetY = ExtractNumber(target.style.top);
	  	// bring the clicked element to the front while it is being dragged
	  	_oldZIndex = target.style.zIndex;
	  	target.style.zIndex = 10000;
	  	// we need to access the element in OnMouseMove
	  	_dragElement = target;
	  	// tell our code to start moving the element with the mouse
	  	document.onmousemove = ZoomThumbMouseMove;
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
}

function ZoomThumbMouseMove(e)
{
	if (e == null) 
		var e = window.event; // this is the actual "drag code"
		
	// We need to confine the drag to the area of the slider
	var y = _offsetY + e.clientY - _startY;
	if (y < 224) y = 224;
	if (y> 297) y = 297;
	_dragElement.style.top = y + 'px';
	_curr_pos = Math.round((297 - y) / 8) + 1;
	doZoom("" + _curr_pos);
 }

function ZoomThumbMouseUp(e)
{
	if (_dragElement != null)
	{
		_dragElement.style.zIndex = _oldZIndex;
		// we're done with these events until the next OnMouseDown
		document.onmousemove = null;
		document.onselectstart = null;
		_dragElement.ondragstart = null;
		// this is how we know we're not dragging
		_dragElement = null;
		
		doZoom("" + _curr_pos);
	} 
}

function ExtractNumber(value)
{
	var n = parseInt(value);
	return n == null || isNaN(n) ? 0 : n;
}

function thumbnail_resize()
{
	var img = $(this);
	var height = parseInt(img.up().getStyle('height'));

	img.show();
		
	var natural_width = img.width;
	var natural_height = img.height;
	
	if (natural_height == 0)
	{
		// On IE7 this functions seems to be called early sometimes.
		setTimeout(thumbnail_resize.bind(this), 500);
		return;
	}
	
	var ratio = natural_width / natural_height;
	
    if (natural_width > natural_height)
	{
      var margin_top = 0;
      var img_width = parseInt(height*ratio + "");
      var margin_left = parseInt((height - img_width) / 2 + "");
    } else {
      var inner_height = height/ratio;
      var margin_top = '-' + parseInt((inner_height - height) / 2 + "");
      var margin_left = 0;
      var img_width = height;
    }
	
	img.setStyle({
		marginTop: margin_top + 'px',
		marginLeft: margin_left +'px'
	});
	
	img.writeAttribute('width', img_width);
}

function postToUrl(url, hashParams)
{
	var myForm = document.createElement("form");
	myForm.method="post";
	myForm.action = url;
	hashParams.authenticity_token = form_authenticity_token;
	for (var k in hashParams) {
		var myInput = document.createElement("input") ;
		myInput.setAttribute("name", k);
		myInput.setAttribute("value", hashParams[k]);
		myForm.appendChild(myInput);
	}
	document.body.appendChild(myForm);
	myForm.submit();
	document.body.removeChild(myForm);
}

// This is an extension to prototype from http://mir.aculo.us/2009/1/7/using-input-values-as-hints-the-easy-way
// It allows input fields to have hints
(function(){
  var methods = {
    defaultValueActsAsHint: function(element){
      element = $(element);
      element._default = element.value;
      
      return element.observe('focus', function(){
        if(element._default != element.value) return;
        element.removeClassName('inputHintStyle').value = '';
      }).observe('blur', function(){
        if(element.value.strip() != '') return;
        element.addClassName('inputHintStyle').value = element._default;
      }).addClassName('inputHintStyle');
    }
  };
   
  $w('input').each(function(tag){ Element.addMethods(tag, methods) });
})();

// This switches the spinner graphic for the real graphic after the real graphic has finished loading.
function hideSpinner(element_id)
{
	var spinnerElement = $("spinner_" + element_id);
	spinnerElement.addClassName("hidden");
	var widenableElement = $(element_id);
	widenableElement.removeClassName("hidden");
}

// asynchronously load the rss feed and pull out the news items
function loadLatestNews( targetList, rssFeedURL, maxItems ) {	
	new Ajax.Request(rssFeedURL, {
		method: 'get',
		onSuccess : function(resp) {
			var rss = resp.responseXML;
			if (rss === null) {
				$(targetList).update("<ul><li>Error in retrieving News Feed.</li></ul>\n");
				return;
			}
			var doc = rss.documentElement;
			var channel = doc.getElementsByTagName('channel');
			var items = channel[0].getElementsByTagName('item');
			var aitems = $A(items);
			var len = 5;
			if (aitems.length < 5)
				len = aitems.length;
			var str = "<ul>";
			for (var i = 0; i < len; i++) {
				var title = aitems[i].getElementsByTagName('title');
				var link = aitems[i].getElementsByTagName('link');
				// Unfortunately, firefox defines the attribute textContent, but IE defines text for the same thing.
				var title_text = title[0].text;
				if (title_text === undefined)
					title_text = title[0].textContent;
				var link_text = link[0].text;
				if (link_text === undefined)
					link_text = link[0].textContent;
				str += "<li><a href=\"" + link_text + "\" class=\"nav_link\" >" + title_text + "</a></li>\n";
			};
			str += "<li><a href=\"/news/\" class=\"nav_link\">MORE</a></li></ul>\n";

			$(targetList).update(str);
		},
		onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
	});

}
