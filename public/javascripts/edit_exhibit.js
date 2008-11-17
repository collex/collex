/**
 * @author paulrosen
 */

 document.observe('dom:loaded', function() {
 	initializeElementEditing();
	
	var el = $('exhibit_outline');
	if (el)
		Sortable.create(el);
	//Sortable.create('exhibit_outline_page');
	//Sortable.create('exhibit_outline_section');
	
	el = $('full_window');
	if (el) {
		FullWindow.initialize('full_window', "OUTLINE");
		$("full_window_full_window").hide();
	}
 });

function initializeElementEditing()
{
 	var els = $$('.exhibit_header');
	for (var i = 0; i < els.length; i++)
	{
		new Ajax.InPlaceEditor(els[i], 'edit_header');
	}
 	
	els = $$('.exhibit_text');
	for (var i = 0; i < els.length; i++)
	{
		new Ajax.InPlaceEditor(els[i], 'edit_text', 
			{ 
				onEnterEditMode: function(form, value) { },
				rows : '20', 
				cols : '60'
				//veButton: true,
				//veIsOn: true,
				//veText: {0: 'Turn on the editor', 1: 'Turn off the editor'} 
			});
	}
	
	els = $$('.exhibit_illustration .widenable');
	els.each(function(el) { Widenable.prepare(el, imgResized); });
}

function imgResized(illustration_id, element_id, width)
{
	new Ajax.Updater("element_"+element_id, "/my9s/change_img_width", {
		parameters : "element_id="+ element_id + "&illustration_id="+ illustration_id + "&width=" + width,
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
		onComplete : setTimeout("initializeElementEditing()", 1000),
		onFailure : function(resp) { alert("Oops, there's been an error."); }
	});
}

function insertIllustration(div, element_id, illustration_position)
{
	new Ajax.Updater(div, "/my9s/insert_illustration", {
		parameters : "element_id="+ element_id + "&position=" + illustration_position,
		onComplete : setTimeout("initializeElementEditing()", 1000),
		onFailure : function(resp) { alert("Oops, there's been an error."); }
	});
}

function change_illustration(element_id, illustration_id, parent_id)
{
	new Effect.Appear('illustration_form_div', { duration: 0.5 }); 
	moveObjectToLeftTopOfItsParent('illustration_form_div', parent_id);

	var strBaseSelector = "#illustration_" + illustration_id + " .ill_";
	var arrIllustrationType = $$(strBaseSelector + "illustration_type");
	var arrImageUrl = $$(strBaseSelector + "image_url");
	var arrLink = $$(strBaseSelector + "link");
	var arrWidth = $$(strBaseSelector + "image_width");
	var arrText = $$(strBaseSelector + "illustration_text");
	var arrCaption1 = $$("#illustration_" + illustration_id + " .exhibit_caption1");
	var arrCaption2 = $$("#illustration_" + illustration_id + " .exhibit_caption2");

	$('ill_element_id').value = element_id;
	$('illustration_id').value = illustration_id;

	$('image_url').value = arrImageUrl[0].innerHTML;
	$('link').value = arrLink[0].innerHTML;
	$('width').value = arrWidth[0].innerHTML;
	$('ill_text').value = arrText[0].innerHTML;
	if (arrCaption1.length > 0) 
	{
		var str = arrCaption1[0].innerHTML;
		var arr = str.split("<div");
		$('caption1').value = arr[0];
		
	}
	if (arrCaption2.length > 0) 
		$('caption2').value = arrCaption2[0].innerHTML;
	
	var opt = $$('#type option');
	if (arrIllustrationType[0].innerHTML == "Text")
	{
		opt[0].removeAttribute('selected');
		opt[1].writeAttribute('selected', 'selected');
	}
	else
	{
		opt[0].writeAttribute('selected', 'selected');
		opt[1].removeAttribute('selected');
	}

	focusedFieldId = 'illustration_form_div';
	setTimeout(focusField, 100);	// We need to delay setting the focus because the annotation isn't on the screen until the Effect.Appear has finished.
}

function doIllustrationFormSubmit()
{
	var element_id = $('ill_element_id').value;
	var illustration_id = $('illustration_id').value;
	var image_url = $('image_url').value;
	var type = $('type').value;
	var link = $('link').value;
	var width = $('width').value;
	var caption1 = $('caption1').value;
	var caption2 = $('caption2').value;
	var ill_text = $('ill_text').value;
	
    Effect.Fade('illustration_form_div', { duration: 0.0 });
	new Ajax.Updater("element_"+element_id, "/my9s/edit_illustration", {
		parameters : "element_id="+ element_id + "&illustration_id=" + illustration_id + "&image_url=" + image_url + 
			"&type=" + type + "&link=" + link + "&width=" + width + "&caption1=" + caption1 + "&caption2=" + caption2 + "&text=" + ill_text,
		onComplete : setTimeout("initializeElementEditing()", 1000),
		onFailure : function(resp) { alert("Oops, there's been an error."); }
	});
}

function doAjaxLink(div, url, params)
{
	new Ajax.Updater(div, url, {
		parameters : params,
		onComplete : setTimeout("initializeElementEditing()", 1000),
		onFailure : function(resp) { alert("Oops, there's been an error."); }});
}

function doAjaxLinkOnSelection(verb, exhibit_id)
{
	var allElements = $$(".outline_tree_element_selected");
	if (allElements.length == 1)
	{
		var id = allElements[0].id;
		var arr = id.split("_");
		var element_id = arr[arr.length-1];
		new Ajax.Updater("full_window", "/my9s/modify_outline", {
			parameters : "verb="+verb+"&element_id="+element_id+"&exhibit_id="+exhibit_id,
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
			parameters : "verb="+verb+"&page_num="+page_num+"&exhibit_id="+exhibit_id,
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

function showExhibitOutline(element_id)
{
	$("full_window_full_window").show();
	if (element_id > 0)
		selectLine('outline_element_' + element_id);
}

function selectLine(id)
{
	exitEditBorderMode();
	
	var allElements = $$(".outline_tree_element_selected");
	allElements.each( function(el) { el.removeClassName( "outline_tree_element_selected" );  });
	
	$(id).addClassName( "outline_tree_element_selected" );
}

Ajax.InPlaceRichEditor = Class.create();
Object.extend(Ajax.InPlaceRichEditor.prototype, Ajax.InPlaceEditor.prototype);
Object.extend(Ajax.InPlaceRichEditor.prototype,
{
	enterEditMode: function(evt)
	{
		if (this.saving) return;
		if (this.editing) return;

		this.editing = true;
		this.onEnterEditMode();

		if (this.options.externalControl)
		{
			Element.hide(this.options.externalControl);
		}

		Element.hide(this.element);
		this.createForm();
		this.element.parentNode.insertBefore(this.form, this.element);
		Field.scrollFreeActivate(this.editField);

		if (this.options.textarea)
		{
			tinyMCE.addMCEControl(this.editField, 'value');
		}

		// stop the event to avoid a page refresh in Safari
		if (evt)
		{
			Event.stop(evt);
		}
		return false;
	},
	onclickCancel: function()
	{
		if (this.options.textarea)
		{
			tinyMCE.removeMCEControl('value');
		}

		this.onComplete();
		this.leaveEditMode();
		return false;
	},
	onSubmit: function()
	{
		// onLoading resets these so we need to save them away for the Ajax call
		var form = this.form;

		if (this.options.textarea)
		{
			var tinyVal = tinyMCE.getContent('value');

			if (tinyVal)
				this.editField.value = tinyVal;

			tinyMCE.removeMCEControl('value');
		}

		var value = this.editField.value;

		// do this first, sometimes the ajax call returns before we get a chance to switch on Saving...
		// which means this will actually switch on Saving... *after* we've left edit mode causing Saving...
		// to be displayed indefinitely
		this.onLoading();

		if (this.options.evalScripts)
		{
			new Ajax.Request(
				this.url, Object.extend(
				{
					parameters: this.options.callback(form, value),
					onComplete: this.onComplete.bind(this),
					onFailure: this.onFailure.bind(this),
					asynchronous:true, 
					evalScripts:true
				}, this.options.ajaxOptions));
		}
		else
		{
			new Ajax.Updater(
				{
					success: this.element,
					// don't update on failure (this could be an option)
					failure: null
				}, 
				this.url, Object.extend(
				{
					parameters: this.options.callback(form, value),
					onComplete: this.onComplete.bind(this),
					onFailure: this.onFailure.bind(this)
				}, this.options.ajaxOptions));
		}
		// stop the event to avoid a page refresh in Safari
		if (arguments.length > 1)
		{
			Event.stop(arguments[0]);
		}
		return false;
	}
});
