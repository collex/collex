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

/*global YAHOO */
/*global Class, $, $$, $H, Ajax, Element */
/*global window, document */
/*global RichTextEditor, MessageBoxDlg */
/*extern ModalDialog, showInLightbox, showPartialInLightBox, currentScrollPos, getX, getY */

// Refactoring notes:
// ModalDialog is only used once by InputDialog
// showInLightbox is only used once by thumbnail_image_tag(), in application_helper.
// showPartialInLightBox is used in all the help html pages and in discussion_threads_helper.
// currentScrollPos is used in doSingleInputPrompt and y_distance_that_the_element_is_not_in_view (a function in edit_exhibit)
// getX [possibly can replace with YAHOO.util.Dom.getX(oItemEl)] / used in input_dialog / duplicated in rich_text_editor_wrapper
// getY [see getX] / also y_distance_that_the_element_is_not_in_view (a function in edit_exhibit)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function currentScrollPos() {
	var f_filterResults = function(n_win, n_docel, n_body) {
		var n_result = n_win ? n_win : 0;
		if (n_docel && (!n_result || (n_result > n_docel)))
			n_result = n_docel;
		return n_body && (!n_result || (n_result > n_body)) ? n_body : n_result;
	};

	var pos = [
		f_filterResults (
			window.pageXOffset ? window.pageXOffset : 0,
			document.documentElement ? document.documentElement.scrollLeft : 0,
			document.body ? document.body.scrollLeft : 0),
		f_filterResults (
			window.pageYOffset ? window.pageYOffset : 0,
			document.documentElement ? document.documentElement.scrollTop : 0,
			document.body ? document.body.scrollTop : 0)];
		return pos;
}

function getX( oElement )
{
	var iReturnValue = 0;
	while( oElement !== null ) {
		iReturnValue += oElement.offsetLeft;
		oElement = oElement.offsetParent;
	}
	return iReturnValue;
}

function getY( oElement )
{
	var iReturnValue = 0;
	while( oElement !== null ) {
		iReturnValue += oElement.offsetTop;
		oElement = oElement.offsetParent;
	}
	return iReturnValue;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

var ModalDialog = Class.create();

ModalDialog.prototype = {
	initialize: function () {
		this.editors = [];
	},
	
	_type: "ModalDialog",

	_divId: null,
	dialog: null,
	targetElement: null,
	formID: null,
	_okFunction: null,
	_okObject: null,
	_linkDlgHandler: null,
	_cancelCallback: null,
	_cancelThis: null,
	_onCompleteCallback:null,
	_saveButtonName: 'Save',
	_cancelButtonName: 'Cancel',
	
	showPrompt: function(title, targetElement, form, left, top, width, height, extraButtons, okFunction, okObject) {
		
		this._okFunction = okFunction;
		this._okObject = okObject;
		
		this._divId = title.gsub(' ', '') + "_modal_dialog";
		this._createDiv(this._divId);

		//create Dialog:
		this.dialog = new YAHOO.widget.Dialog(this._divId, {
			x: left, y: top, width: width, height: height,
			constraintoviewport: true,
			modal: true
		});
		
		this._handleEsc();
		this._setButtons();
		this._renderForm(title, targetElement, form);
		this._setRichTextAreas(extraButtons);
		this.dialog.show();
		
		YAHOO.util.Event.on(YAHOO.util.Dom.getElementsByClassName("container-close", "a", this._divId), "click", this._handleCancel, this, true);
	},
	
	show: function(title, targetElement, form, left, top, width, height, extraButtons, linkDlgHandler, noButtons, cancelCallback, cancelThis) {
		
		this._cancelCallback = cancelCallback;
		this._cancelThis = cancelThis;
		this._linkDlgHandler = linkDlgHandler;
		this._divId = title.gsub(' ', '') + "_modal_dialog";
		this._createDiv(this._divId);

		//create Dialog:
		this.dialog = new YAHOO.widget.Dialog(this._divId, {
			x: left, y: top, //width: width, height: height,
			constraintoviewport: true,
			modal: true
		});
		
		this._handleEsc();
		if (!noButtons)
			this._setButtons();
		this._renderForm(title, targetElement, form);
		this._setRichTextAreas(extraButtons);
		this.dialog.show();
		
		YAHOO.util.Event.on(YAHOO.util.Dom.getElementsByClassName("container-close", "a", this._divId), "click", this._handleCancel, this, true);
	},
	
	showLightbox: function(title, targetElement, form, left, top) {
		
		this._divId = title.gsub(' ', '') + "_modal_dialog";
		this._createDiv(this._divId);
		
		//create Dialog:
		this.dialog = new YAHOO.widget.Dialog(this._divId, {
			//constraintoviewport: true,
			//x: currentScrollPos()[0], y: currentScrollPos()[1],
			x: left, y: top,
			modal: true
		});
		
		this._handleEsc();
		this._setCancelButton();
		this._renderForm(title, targetElement, form);
		
		YAHOO.util.Event.on(YAHOO.util.Dom.getElementsByClassName("container-close", "a", this._divId), "click", this._handleCancel, this, true);
	},
	
	setCompleteCallback: function(callBack)
	{
		this._onCompleteCallback = callBack;
	},
	
	setSaveButton: function(name) {
		this._saveButtonName = name;
	},

	setCancelButton: function(name) {
		this._cancelButtonName = name;
	},

	center: function()
	{
		var div = $(this._divId).up();
		var w = parseInt(div.getStyle('width'));
		var h = parseInt(div.getStyle('height'));
		var vpHeight = YAHOO.util.Dom.getViewportHeight();
		var vpWidth = YAHOO.util.Dom.getViewportWidth();
		
		// Now that we see how big the image is, center it
		var left = (vpWidth - w)/2;
		var top = (vpHeight - h)/2;
		div.setStyle({ left: left + currentScrollPos()[0] + 'px', top: top + currentScrollPos()[1] + 'px' });
	},

	///////////////////////// private functions //////////////////////////////////////

	//if the user clicks "save", then we save the HTML
	//content of the RTE and submit the dialog:
	_handleSave: function() {
		
		this.editors.each(function(editor) {
			editor.save();
		});

		this._sendToServer(this.targetElement, this.formID);
		this.dialog.hide();
		this.dialog.destroy();
	},

	//if the user clicks cancel, we call Dialog's
	//cancel method:
	_handleCancel: function() {
		this.dialog.cancel();
		YAHOO.lang.later(500, this.dialog, this.dialog.destroy, null, false);	// Delay destroy to fix crash in IE7 when X is clicked
		if (this._cancelCallback)
		{
			this._cancelCallback(this._cancelThis);
		}
	},	
	
	_createDiv : function(id)
	{
		// if it already exists, destroy and recreate it
//		if( $(id) ) {
//			this.dialog.destroy();
//		}

		var modalDialogDiv = new Element("div", { id: id });
		$$('body').first().appendChild(modalDialogDiv);
	},
	
	_handleEsc : function()
	{
		var klEsc = new YAHOO.util.KeyListener(document, { keys:27 },  							
			{ fn:this._handleCancel,
				scope:this,
				correctScope:true }, "keyup" ); 
			// keyup is used here because Safari won't recognize the ESC
			// keydown event, which would normally be used by default
		this.dialog.cfg.queueProperty("keylisteners", klEsc);
	},
	
	_setButtons : function()
	{
		//set up buttons for the Dialog and wire them
		//up to our handlers:
		var myButtons = [ { text: this._saveButtonName, handler: { fn: this._handleSave, obj: null, scope: this }, isDefault:true 	},
			{ text:this._cancelButtonName, handler: { fn: this._handleCancel, obj: null, scope: this } }];
		this.dialog.cfg.queueProperty("buttons", myButtons);
	},
	
	_setCancelButton : function()
	{
		//set up buttons for the Dialog and wire them
		//up to our handlers:
		var myButtons = [ { text:this._cancelButtonName, handler: { fn: this._handleCancel, obj: null, scope: this }, isDefault:true }];
		this.dialog.cfg.queueProperty("buttons", myButtons);
	},
	
	_setRichTextAreas : function(extraButtons)
	{
		var textAreas = $$('#'+this.formID+' textarea');
		
		textAreas.each( function(textArea) { 
			var editor = new RichTextEditor({ id: textArea.id, toolbarGroups: extraButtons, linkDlgHandler: this._linkDlgHandler });
			editor.attachToDialog(this.dialog);
			this.editors.push(editor);
		}, this);
	},
	
	_renderForm: function(title, targetElement, form)
	{
		this.dialog.setHeader(title);
		this.targetElement = targetElement;
		this.formID = form.id;

		// var element = new Element("div", { id: 'descriptionContainer' });
		// form.appendChild(element);
		$(this._divId).appendChild(form);
		
		// this is a hack for IE6 compatibility, render the dialog late so that it works properly. 
		//document.getElementById(this._divId).style.display = "block";
		this.dialog.render();
		
		// fix the tab order: we don't want the close X in it.
		var closeX = $$('.container-close');
		if (closeX.length > 0)
			closeX[0].writeAttribute({ tabindex: 20 });
	},

	_sendToServer: function( element_id, form_id ) {
		var el = $(element_id);
	
		var params = { element_id: element_id };
		var els = $$('#' + form_id + ' input');
		els.each(function(e) { params[e.id] = e.value; });
		els = $$('#' + form_id + ' textarea');
		els.each(function(e) { params[e.id] = e.value; });
		els = $$('#' + form_id + ' select');
		els.each(function(e) { params[e.id] = e.value.unescapeHTML(); });
		
		if (this._okFunction !== null)
		{
			this._okFunction(	this._okObject, params);	
		}
		else
		{
			// We weren't given a function for ok, therefore we want to ajax the results back to the server.
			var action = el.readAttribute('action');
			var ajax_action_element_id = el.readAttribute('ajax_action_element_id');
			
			if (ajax_action_element_id === "")
			{
				// Instead of replacing an element, we want to redraw the entire page. There seems to be some conflict
				// if the form is resubmitted, so duplicate the form.
				var new_form = new Element('form', { id: form_id + "2", method: 'post', onsubmit: "this.submit();", action: action });
				new_form.observe('submit', "this.submit();");
				document.body.appendChild(new_form);
				$H(params).each(function (p) { new_form.appendChild(new Element('input', { name: p.key, value: p.value, id: p.key })); });

				$(this.targetElement).appendChild(new Element('img', { src: "/images/ajax_loader.gif", alt: ''}));
				new_form.submit();
				
				return;
			}
		
			// If we have a comma separated list, we want to send the request synchronously to each action
			// (Doing this synchronously eliminates any race condition: The first call can update the data and
			// the rest of the calls just update the page.
			var actions = action.split(',');
			var action_elements = ajax_action_element_id.split(',');
			if (actions.length === 1)
			{
				new Ajax.Updater(ajax_action_element_id, action, {
					parameters : params,
					evalScripts : true,
					onComplete : this._onCompleteCallback,				
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
							onComplete : this._onCompleteCallback,						
							onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
						});
					},
					onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
				});
			}
		}
	}
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Take an image and show it in a modal lightbox.
//var _lightboxModalDialog = null;	// There is a problem with the object not destroying itself on close, so this is a hack so there is never more than one created.
function showInLightbox(imageUrl, referenceElementId)
{
	var lightboxCenter = function()
	{
		var img = $('lightbox_img');
		if (!img)	// The user must have cancelled.
			return;

		var img_spinner = $('lightbox_img_spinner');
		if (img_spinner)
			img_spinner.remove();
		img.show();
		var w = parseInt(img.getStyle('width'));
		var vpWidth = YAHOO.util.Dom.getViewportWidth();
		if (w > vpWidth)
			img.width = vpWidth - 40;
		var h = parseInt(img.getStyle('height'));
		var vpHeight = YAHOO.util.Dom.getViewportHeight();
		if (h > vpHeight)
		{
			img.removeAttribute('width');
			img.height = vpHeight - 80;
		}

		this.center();
	};

	var divName = "lightbox";
	var img = new Element('img', { id: 'lightbox_img', src: imageUrl, alt: ""});
	img.setStyle({display: 'none' });
	var form = img.wrap('form', { id: divName + "_id"});
	var progress = new Element('center', { id: 'lightbox_img_spinner'});
	progress.addClassName('lightbox_img_spinner');
	progress.appendChild(new Element('div').update("Image Loading..."));
	progress.appendChild(new Element('img', { src: "/images/ajax_loader.gif", alt: ''}));
	progress.appendChild(new Element('div').update("Please wait"));
	form.appendChild(progress);
	var lightboxModalDialog = new ModalDialog();
	lightboxModalDialog.setCancelButton("Close");
	img.observe('load', lightboxCenter.bind(lightboxModalDialog));
	var el = $(referenceElementId);
	var left = getX(el);
	var top = getY(el);
	lightboxModalDialog.showLightbox("Image", divName, form, left, top);
}


function showPartialInLightBox(ajax_url, title)
{
	var divName = "lightbox";
	var div = new Element('div', { id: 'lightbox_contents' });
	div.setStyle({display: 'none' });
	var form = div.wrap('form', { id: divName + "_id"});
	var progress = new Element('center', { id: 'lightbox_img_spinner'});
	progress.addClassName('lightbox_img_spinner');
	progress.appendChild(new Element('div').update("Loading..."));
	progress.appendChild(new Element('img', { src: "/images/ajax_loader.gif", alt: ''}));
	progress.appendChild(new Element('div').update("Please wait"));
	form.appendChild(progress);
	var lightboxModalDialog = new ModalDialog();
	var scroll = currentScrollPos();
	lightboxModalDialog.showLightbox(title, divName, form, scroll[0]+10, scroll[1]+10);
	new Ajax.Updater('lightbox_contents', ajax_url, {
		evalScripts : true,
		onComplete : function(resp) {
			var img_spinner = $('lightbox_img_spinner');
			if (img_spinner)
				img_spinner.remove();
			$('lightbox_contents').show();
			lightboxModalDialog.center();
		},
		onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
	});
}
