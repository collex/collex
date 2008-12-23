

ModalDialog = Class.create();

ModalDialog.prototype = {
	initialize: function () {
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
		
		// if it already exists, destroy and recreate it
		if( $('modal_dialog') ) {
			this.dialog.destroy();
		}

		var modalDialogDiv = new Element("div", { id: 'modal_dialog' });
		$$('body').first().appendChild(modalDialogDiv);

		//create Dialog:
		this.dialog = new YAHOO.widget.Dialog('modal_dialog', {
			x: left,
			y: top,
			width: width,
			height: height,
			constraintoviewport: true,
			// fixedcenter: true,
			modal: true
		});

		var klEsc = new YAHOO.util.KeyListener(document, { keys:27 },  							
			{ fn:this.dialog.hide,
				scope:this.dialog,
				correctScope:true }, "keyup" ); 
			// keyup is used here because Safari won't recognize the ESC
			// keydown event, which would normally be used by default
		this.dialog.cfg.queueProperty("keylisteners", klEsc);

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
		
		// fix the tab order: we don't want the close X in it.
		var closeX = $$('.container-close');
		if (closeX.length > 0)
			closeX[0].writeAttribute({ tabindex: 20 });
		
		var textAreas = $$('#'+this.formID+' textarea');
		
		this.usesRichTextArea = (textAreas.length > 0);
		
		textAreas.each( function(textArea) { 
			//create the RTE:
			this.editor = new YAHOO.widget.SimpleEditor(textArea.id, {
				  width: '702px',
					height: '200px',
					toolbar: {
						//titlebar: 'My tool',
						draggable: false,
						buttons: [{
							group: 'fontstyle',
							label: 'Font Name and Size',
							buttons: [{
								type: 'select',
								label: 'Arial',
								value: 'fontname',
								disabled: true,
								menu: [{ text: 'Arial', checked: true },
									{ text: 'Arial Black' },
									{ text: 'Comic Sans MS' },
									{ text: 'Courier New' },
									{ text: 'Lucida Console' },
									{ text: 'Tahoma' },
									{ text: 'Times New Roman' },
									{ text: 'Trebuchet MS' },
									{ text: 'Verdana' } ]},
								{
								type: 'spin',
								label: '13',
								value: 'fontsize',
								range: [9, 75],
								disabled: true
							}]
						}, {
							type: 'separator'
						}, {
							group: 'textstyle',
							label: 'Font Style',
							buttons: [{
								type: 'push',
								label: 'Bold CTRL + SHIFT + B',
								value: 'bold'
							}, {
								type: 'push',
								label: 'Italic CTRL + SHIFT + I',
								value: 'italic'
							}, {
								type: 'push',
								label: 'Underline CTRL + SHIFT + U',
								value: 'underline'
							}]
						}, {
							type: 'separator'
						}, {
							group: 'indentlist',
							label: 'Lists',
							buttons: [{
								type: 'push',
								label: 'Create an Unordered List',
								value: 'insertunorderedlist'
							}, {
								type: 'push',
								label: 'Create an Ordered List',
								value: 'insertorderedlist'
							}]
						}, {
							type: 'separator'
						}, {
							group: 'insertitem',
							label: 'Insert Item',
							buttons: [{
								type: 'push',
								label: 'HTML Link CTRL + SHIFT + L',
								value: 'createlink',
								disabled: true
							}]
						}]
					}
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
				
		// If there is a rich text editor on the form, then allow the dlg to be resized.
		if (this.usesRichTextArea)
		{
			var resizer = new YAHOO.util.Resize("modal_dialog");
			resizer.subscribe( 'resize', this.dlgResized, textAreas[0].id, this);
		}
	},
	
	dlgResized: function (event, elementIdToResize)
	{
		var el = $(elementIdToResize+"_container");
		var elForm = el.up(".modal_dialog_form");
		var fontSize = parseFloat(elForm.getStyle("fontSize"));
		var margin = parseInt(fontSize*2 + "");
		el.setStyle({ width: event.width - margin - 10 + 'px'});
		
		var elFt = $("modal_dialog").down('.ft');
		var ftHeight = parseInt(elFt.getStyle('height'));
		var elHd = $("modal_dialog").down('.hd');
		var hdHeight = parseInt(elHd.getStyle('height'));
		var elTb = el.down(".yui-toolbar-container");
		var tbHeight = parseInt(elTb.getStyle('height'));
		var yEl = getY(el);
		var yDlg = getY($("modal_dialog"));
		var relPos = yEl - yDlg;
		
		var elHeight = el.down(".yui-editor-editable-container");
		elHeight.setStyle({ height: event.height - relPos - margin/2 - ftHeight - hdHeight - tbHeight + 'px'});
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
		
		var onCompleteCallback = function() {
		  Try.these(
		    function() { initializeElementEditing() },
				function() {}
		  );
		}
	
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
				onComplete : onCompleteCallback,				
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
						onComplete : onCompleteCallback,						
						onFailure : function(resp) { alert("Oops, there's been an error."); }
					});
				},
				onFailure : function(resp) { alert("Oops, there's been an error."); }
			});
		}
	}
}



