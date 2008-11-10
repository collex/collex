/**
 * @author paulrosen
 */

 document.observe('dom:loaded', function() {
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
			});
	}
	
	var el = $('exhibit_outline');
	if (el)
		Sortable.create(el);
	//Sortable.create('exhibit_outline_page');
	//Sortable.create('exhibit_outline_section');
	
	el = $('full_window');
	if (el)
		FullWindow.initialize('full_window', "OUTLINE");
		
	els = $$('.exhibit_illustration img');
	els.each(function(el) { Widenable.prepare(el, imgResized); });
 });

function imgResized(illustration_id, width)
{
	new Ajax.Request("/my9s/change_img_width", {
		parameters : "illustration_id="+ illustration_id + "&width=" + width,
		onFailure : function(resp) { alert("Oops, there's been an error: "); }
	});
}

function elementTypeChanged(div, element_id, newType)
{
	new Ajax.Updater(div, "/my9s/change_element_type", {
		parameters : "element_id="+ element_id + "&type=" + newType,
		onFailure : function(resp) { alert("Oops, there's been an error."); }
	});
}

function insertIllustration(div, element_id, illustration_position)
{
	new Ajax.Updater(div, "/my9s/insert_illustration", {
		parameters : "element_id="+ element_id + "&position=" + illustration_position,
		onFailure : function(resp) { alert("Oops, there's been an error."); }
	});
}

function change_illustration(element_id, illustration_id, parent_id)
{
	new Effect.Appear('illustration_form_div', { duration: 0.5 }); 
	moveObjectToLeftTopOfItsParent('illustration_form_div', parent_id);

	$('ill_element_id').value = element_id;
	$('illustration_id').value = illustration_id;
	var par = $(parent_id);
	var arrLinks = par.getElementsByTagName('a');
	var arrImg = par.getElementsByTagName('img');
	var arrDiv = par.getElementsByTagName('div');
	if (arrImg.length > 0)
		$('image_url').value = arrImg[0].src;
	if (arrLinks.length > 0)
		$('link').value = arrLinks[0].href;
	if (arrImg.length > 0)
		$('width').value = arrImg[0].width;
	for (var i = 0; i < arrDiv.length; i++)
	{
		if (arrDiv[i].className == 'exhibit_caption1')
		{
			var str = arrDiv[i].innerHTML;
			var idx = str.indexOf("<div class=");
			if (idx >= 0)
				str = str.substring(0, idx);
			str = str.strip();
			$('caption1').value = str;
		}
		if (arrDiv[i].className == 'exhibit_caption2')
			$('caption2').value = arrDiv[i].innerHTML;
	}

	var existing_note = document.getElementById(parent_id).innerHTML;
	existing_note = existing_note.gsub("<br />", "\n");
	existing_note = existing_note.gsub("<br>", "\n");
	$('text').value = existing_note;

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
		onFailure : function(resp) { alert("Oops, there's been an error."); }
	});
}
