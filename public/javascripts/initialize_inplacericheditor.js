/**
 * @author paulrosen
 */

document.observe('dom:loaded', function() {
	initializeAllInplaceRichEditors();
});

function initializeAllInplaceRichEditors()
{
	var editors = $$('div[inplacericheditor]');
	editors.each( function(ed) {
		var ajaxLink = ed.readAttribute('inplacericheditor');
		initInPlaceRichEditor(ed.id, ajaxLink);
		ed.removeAttribute('inplacericheditor');
	});
}

function initInPlaceRichEditor(el_id, action)
{
	new Ajax.InPlaceRichEditor(
		el_id, 
		action,
		{ 
			ajaxOptions: { /*method: "put"*/ },
		    callback: function(form, value) {
				return "value=" + escape(value);
			},
			onComplete: function(transport, element) {
				// Would be better with onSuccess but no option yet in InPlaceEditor
//				if (transport != undefined && 200 == transport.status)
//					element.innerHTML = transport.responseText;
				new Effect.Highlight(element, {
					startcolor: this.options.highlightColor, keepBackgroundImage: true });
			},
			onFailure: function(ipe, transport) {
				alert("Error communication with the server:\n"+ transport.responseText);
			}
		});
} 