

ModalDialog = Class.create();

ModalDialog.prototype = {
	initialize: function () {

		// //create Dialog:
		// this.dialog = new YAHOO.widget.Dialog("modal_dialog", {
		// 	width:"725px",
		// 	fixedcenter:true
		// });
		// 
		// //set up buttons for the Dialog and wire them
		// //up to our handlers:
		// var myButtons = [ { text:"Save", 
		// 									  handler: { fn: this.handleSave, obj: null, scope: this } 
		// 									},
		// 				  				{ text:"Cancel", 
		// 										handler: { fn: this.handleCancel, obj: null, scope: this },
		// 										isDefault:true 
		// 									}];
		// this.dialog.cfg.queueProperty("buttons", myButtons);
	},
	
	//if the user clicks "save", then we save the HTML
	//content of the RTE and submit the dialog:
	handleSave: function() {
		
		if( this.usesRichTextArea )
			this.editor.saveHTML();
		
		this.sendToServer(this.targetElement, this.formID);
		this.dialog.hide();
		this.dialog.destroy();
	},

	//if the user clicks cancel, we call Dialog's
	//cancel method:
	handleCancel: function() {
		this.dialog.cancel();
		this.dialog.destroy();
	},	
	
	show: function(title, targetElement, form, left, top, width, height) {

		var modalDialogDiv = new Element("div", { id: 'modal_dialog' });
		$$('body').first().appendChild(modalDialogDiv);

		//create Dialog:
		this.dialog = new YAHOO.widget.Dialog('modal_dialog', {
			x: left,
			y: top,
			width: width,
			height: height,
			modal: true
		});

		//set up buttons for the Dialog and wire them
		//up to our handlers:
		var myButtons = [ { text:"Save", 
											  handler: { fn: this.handleSave, obj: null, scope: this } 
											},
						  				{ text:"Cancel", 
												handler: { fn: this.handleCancel, obj: null, scope: this },
												isDefault:true 
											}];
		this.dialog.cfg.queueProperty("buttons", myButtons);
		
		this.dialog.setHeader(title);
		this.targetElement = targetElement;
		this.formID = form.id;

		// var element = new Element("div", { id: 'descriptionContainer' });
		// form.appendChild(element);
		$("modal_dialog").appendChild(form);			
			
		// this is a hack for IE6 compatibility, render the dialog late so that it works properly. 
		//document.getElementById("modal_dialog").style.display = "block";
		this.dialog.render();
		
		
		var textAreas = $$('#'+this.formID+' textarea');
		
		this.usesRichTextArea = (textAreas.length > 0);
		
		textAreas.each( function(textArea) { 
			//create the RTE:
			this.editor = new YAHOO.widget.SimpleEditor(textArea.id, {
				  width: '702px',
					height: '200px'
			});

			//attach the Editor's reusable property-editor
			//panel to an element inside our main Dialog --
			//this allows it to get focus even when the Dialog
			//is modal:
			// this.editor.on('windowRender', function() {
			// 	document.getElementById('descriptionContainer').appendChild(this.get('panel').element);
			// });

			//render the editor explicitly into a container
			//within the Dialog's DOM:
			this.editor.render();
			
			//RTE needs a little love to work in in a Dialog that can be 
			//shown and hidden; we let it know that it's being
			//shown/hidden so that it can recover from these actions:
			this.dialog.showEvent.subscribe(this.editor.show, this.editor, true);
			this.dialog.hideEvent.subscribe(this.editor.hide, this.editor, true);							
		}, this); 

		this.dialog.show();		
				
	},
	
	sendToServer: function( element_id, form_id ) {
		var el = $(element_id);
		var action = el.readAttribute('action');
		var ajax_action_element_id = el.readAttribute('ajax_action_element_id');
	
		var params = { element_id: element_id };
		var els = $$('#' + form_id + ' input');
		els.each(function(e) { params[e.id] = e.value; });
		els = $$('#' + form_id + ' textarea');
		els.each(function(e) { params[e.id] = e.value; });
		els = $$('#' + form_id + ' select');
		els.each(function(e) { params[e.id] = e.value; });
	
		// If we have a comma separated list, we want to send the alert synchronously to each action
		// (Doing this synchronously eliminates any race condition: The first call can update the data and
		// the rest of the calls just update the page.
		var actions = action.split(',');
		var action_elements = ajax_action_element_id.split(',');
		if (actions.length == 1)
		{
			new Ajax.Updater(ajax_action_element_id, action, {
				parameters : params,
				evalScripts : true,
				onFailure : function(resp) { alert("Oops, there's been an error."); }
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
						onFailure : function(resp) { alert("Oops, there's been an error."); }
					});
				},
				onFailure : function(resp) { alert("Oops, there's been an error."); }
			});
		}
	}
}



