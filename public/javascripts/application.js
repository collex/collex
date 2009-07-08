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
//Event.observe(window, 'load', function() {
//	// initialize hacks whenever the page loads
//	initializeHacks();
//});

////////////////////////////////////////

//function toggleIt(element) {
//  var tr = element.parentNode.parentNode;
//  var className = tr.className;
//  if (node_before(tr).className == className) {
//    tr = node_before(tr);
//  }
//
//  while (true) {
//    Element.toggle(tr);
//    tr = node_after(tr);
//    if (tr == null || tr.className != className) break;
//  }
//}

// deselect all checkboxes within the specified div 
//function deselectAll(target) {
//	var checkboxes = $(target).select( 'input[type=checkbox]' );
//	for (var i=0; i < checkboxes.length; i++) {
//		var checkbox = checkboxes[i];
//		checkbox.checked = false;
//	}
//}

// select all checkboxes within the specified div 
//function selectAll(target) {
//	var checkboxes = $(target).select( 'input[type=checkbox]' );
//	for (var i=0; i < checkboxes.length; i++) {
//		var checkbox = checkboxes[i];
//		checkbox.checked = true;
//	}
//}

//function toggleCategory(category_id) {
//	var elems = document.getElementsByClassName("cat_" + category_id + "_child");
//
//	Element.toggle("cat_" + category_id + "_opened");
//	Element.toggle("cat_" + category_id + "_closed");
//
//	for (var i=0; i < elems.length; i++) {
//		if ( elems[i].hasClassName("noshow") ) {
//			Element.removeClassName(elems[i], "noshow");
//		} else {
//			Element.addClassName(elems[i], "noshow");
//		}
//	}
//}

//function popUp(URL) {
//  var day = new Date();
//  var id = day.getTime();
//  eval("page" + id + " = window.open(URL, '" + id + "', 'toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=0,resizable=1,width=300,height=400');");
//}

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
//function node_before( sib )
//{
//  while ((sib = sib.previousSibling)){
//    if (!is_ignorable(sib)) return sib;
//  }
//  return null;
//}

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
//function node_after( sib ) {
//  while ((sib = sib.nextSibling)){
//    if (!is_ignorable(sib)) return sib;
//  }
//  return null;
//}

/**
 * Determine if a node should be ignored by the iterator functions.
 *
 * @param nod  An object implementing the DOM1 |Node| interface.
 * @return     true if the node is:
 *                1) A |Text| node that is all whitespace
 *                2) A |Comment| node
 *             and otherwise false.
 */

//function is_ignorable( nod ){
//  return ( nod.nodeType == 8) || // A comment node
//         ( (nod.nodeType == 3) && is_all_ws(nod) ); // a text node, all ws
//}

/**
 * Determine whether a node's text content is entirely whitespace.
 *
 * @param nod  A node implementing the |CharacterData| interface (i.e.,
 *             a |Text|, |Comment|, or |CDATASection| node
 * @return     True if all of the text content of |nod| is whitespace,
 *             otherwise false.
 */
//function is_all_ws( nod ){
//  // Use ECMA-262 Edition 3 String and RegExp features
//  return !(/[^\t\n\r ]/.test(nod.data));
//}


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

//function getStyleObject(objectId) {
//    // cross-browser function to get an object's style object given its id
//    if(document.getElementById && document.getElementById(objectId)) {
//	// W3C DOM
//	return document.getElementById(objectId).style;
//    } else if (document.all && document.all(objectId)) {
//	// MSIE 4 DOM
//	return document.all(objectId).style;
//    } else if (document.layers && document.layers[objectId]) {
//	// NN 4 DOM.. note: this won't find nested layers
//	return document.layers[objectId];
//    } else {
//	return false;
//    }
//} // getStyleObject

//function changeObjectVisibility(objectId, newVisibility) {
//    // get a reference to the cross-browser style object and make sure the object exists
//    var styleObject = getStyleObject(objectId);
//    if(styleObject) {
//	styleObject.visibility = newVisibility;
//	return true;
//    } else {
//	// we couldn't find the object, so we can't change its visibility
//	return false;
//    }
//} // changeObjectVisibility

//function moveObject(objectId, newXCoordinate, newYCoordinate) {
//    // get a reference to the cross-browser style object and make sure the object exists
//    var styleObject = getStyleObject(objectId);
//    if(styleObject) {
//	styleObject.left = "" + (newXCoordinate-500) + "px";
//	styleObject.top = "" + (newYCoordinate-50) + "px";
//	return true;
//    } else {
//	// we couldn't find the object, so we can't very well move it
//	return false;
//    }
//} // moveObject

//function moveObject2(objectId, newXCoordinate, newYCoordinate) {
//    // get a reference to the cross-browser style object and make sure the object exists
//    var styleObject = getStyleObject(objectId);
//    if(styleObject) {
//	styleObject.left = "" + (newXCoordinate) + "px";
//	styleObject.top = "" + (newYCoordinate) + "px";
//	return true;
//    } else {
//	// we couldn't find the object, so we can't very well move it
//	return false;
//    }
//} // moveObject




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

//function initializeHacks() {
//    // this ugly little hack resizes a blank div to make sure you can click
//    // anywhere in the window for Mac MSIE 5
//    if ((navigator.appVersion.indexOf('MSIE 5') != -1)
//	&& (navigator.platform.indexOf('Mac') != -1)
//	&& getStyleObject('blankDiv')) {
//	window.onresize = explorerMacResizeFix;
//    }
//    resizeBlankDiv();
//    // this next function creates a placeholder object for older browsers
//    createFakeEventObj();
//}
//
//function createFakeEventObj() {
//    // create a fake event object for older browsers to avoid errors in function call
//    // when we need to pass the event object to functions
//    if (!window.event) {
//	window.event = false;
//    }
//} // createFakeEventObj

//function resizeBlankDiv() {
//    // resize blank placeholder div so IE 5 on mac will get all clicks in window
//    if ((navigator.appVersion.indexOf('MSIE 5') != -1)
//	&& (navigator.platform.indexOf('Mac') != -1)
//	&& getStyleObject('blankDiv')) {
//	getStyleObject('blankDiv').width = document.body.clientWidth - 20;
//	getStyleObject('blankDiv').height = document.body.clientHeight - 20;
//    }
//}

//function explorerMacResizeFix () {
//    location.reload(false);
//}

//
// functions that handle the AJAX inside a result div
//


//function moveObjectToJustBelowItsParent(target_id, parent_id)
//{
//	// Get the absolute location of the parent
//	var par = document.getElementById(parent_id);
//	var x = getX(par);
//	var y = getY(par);
//
//	// Get the right side of the parent and the target: we want to right justify
//	var targ = document.getElementById(target_id);
//	var targ_width = parseInt(targ.style.width);	// This includes the trailing 'px'
//	var par_width = par.offsetWidth;
//	var newXCoordinate = x + ((document.body.scrollLeft)?document.body.scrollLeft:0) - targ_width + par_width;
//	var newYCoordinate = y + ((document.body.scrollTop)?document.body.scrollTop:0) + par.offsetHeight;
//	moveObject2(target_id, newXCoordinate, newYCoordinate);
//}

//function moveObjectToLeftTopOfItsParent(target_id, parent_id)
//{
//	// Get the absolute location of the parent
//	var par = document.getElementById(parent_id);
//	var x = getX(par);
//	var y = getY(par);
//
//	var newXCoordinate = x + ((document.body.scrollLeft)?document.body.scrollLeft:0);
//	var newYCoordinate = y + ((document.body.scrollTop)?document.body.scrollTop:0);
//
//	// Adjust the width if the dialog would be off the side of the page
//	//var max_x = document.width;
//	var t = $(target_id);
//	var w = parseInt(t.getStyle('width'));
//	var max_x = document.width - w - 10;	// Add a little margin so it is not right against the page.
//	if (newXCoordinate > max_x)
//		newXCoordinate = max_x;
//	moveObject2(target_id, newXCoordinate, newYCoordinate);
//}



//function cancel_edit_profile_mode(partial_id)
//{
//	new Ajax.Updater(partial_id, "/my9s/update_profile", {
//		onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
//	});
//}

//function enter_edit_profile_mode(partial_id)
//{
//	new Ajax.Updater(partial_id, "/my9s/enter_edit_profile_mode", {
//		onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
//	});
//}

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

