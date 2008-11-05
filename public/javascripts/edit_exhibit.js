/**
 * @author paulrosen
 */

 document.observe('dom:loaded', function() {
 	var els = document.getElementsByClassName('exhibit_header');
	for (var i = 0; i < els.length; i++)
	{
		new Ajax.InPlaceEditor(els[i], 'edit_header');
	}
 });
