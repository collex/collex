// ------------------------------------------------------------------------
//     Copyright 2009 Applied Research in Patacriticism and the University of Virginia
// 
//     Licensed under the Apache License, Version 2.0 (the "License");
//     you may not use this file except in compliance with the License.
//     You may obtain a copy of the License at
// 
//         http://www.apache.org/licenses/LICENSE-2.0
// 
//     Unless required by applicable law or agreed to in writing, software
//     distributed under the License is distributed on an "AS IS" BASIS,
//     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//     See the License for the specific language governing permissions and
//     limitations under the License.
// ----------------------------------------------------------------------------

//////////////////////////////////////////////////////
/// Create the dialog that manipulates the border in edit exhibits.
//////////////////////////////////////////////////////

/*global $, $$, Class, Element, Event, Ajax */
/*global YAHOO */
/*global document */
/*global InputDialog, MessageBoxDlg */
/*extern BorderDialog, borderDialog, createBorderDlg */

var borderDialog = null;

function createBorderDlg()
{
	borderDialog = new BorderDialog();
}

var BorderDialog = Class.create();

BorderDialog.prototype = {
	initialize: function () {
		this.myPanel = new YAHOO.widget.Dialog("edit_border_dlg", {
			width:"380px",
			fixedcenter: true,
			constraintoviewport: true,
			underlay:"shadow",
			close:true,
			visible:true,
			modal: true,
			draggable:true
		});
		this.myPanel.setHeader("Edit Border");

		var myButtons = [ { text:"Submit", handler:this.handleSubmit },
						  { text:"Cancel", handler:this.handleCancel } ];
		this.myPanel.cfg.queueProperty("buttons", myButtons);

		var elOuterContainer = new Element('div', { id: 'border_outer_container' });
		var elDiv = new Element('div', { id: 'border_dlg_instructions' }).update('First, drag the mouse over some sections and then click "Add Border" or "Remove Border".');
		elDiv.addClassName('instructions');
		elOuterContainer.appendChild(elDiv);
		var elContainer = new Element('div', { id: 'border_container' });
		elOuterContainer.appendChild(elContainer);

		// Here's our header
		var headers = $$('.selected_page .exhibit_outline_text');
		var page_num = headers[0].innerHTML;
		var span = new Element('span').update('&nbsp;&nbsp;' + page_num);
		span.addClassName('exhibit_outline_text');
		var span2 = span.wrap('div');
		span2.addClassName('unselected_page');
		span2.addClassName('selected_page');
		elContainer.appendChild(span2);

		// First copy all the elements over that we want to use
		var elements = $$(".selected_page .outline_element");
		elements.each(function(el) {
			var par = el.up();
			var prev = el.previous();
			var next = el.next();
			var cls = 'border_dlg_element';
			if (par.hasClassName('outline_section_with_border'))
			{
				cls += " border_sides";
				if (prev === null)
					cls += " border_top";
				if (next === null)
					cls += " border_bottom";
			}
			var inner = el.innerHTML;
			var elBorder = new Element('div', {id: "border_" + el.id }).update(inner);
			elBorder.addClassName(cls);
			var elBorder2 = elBorder.wrap('div', { id: 'rubberband_' + el.id });
			elBorder2.addClassName('rubberband_dlg_element');
			elContainer.appendChild(elBorder2);
		}, this);

		this.myPanel.setBody(elOuterContainer);
		this.myPanel.render(document.body);

		elements = $$('#border_container .outline_right_controls');
		elements.each(function(el) {
			el.remove();
		}, this);

		elements = $$('#border_container .count');
		elements.each(function(el) {
			var num = el.down().innerHTML;
			el.update(num);
			el.addClassName('count');
		}, this);

		elements = $$('#border_container [onclick]');
		elements.each(function(el) {
			el.removeAttribute('onclick');
		}, this);

		var el = $('border_container');
		el.observe('mousedown', this.mouseDown.bind(this));
		el.observe('mousemove', this.mouseMove.bind(this));
		el.observe('mouseup', this.mouseUp.bind(this));
	},

	isDragging: false,
	anchor: null,
	focus: null,

	redrawRubberband : function(focus_)
	{
		var t = (focus_ > this.anchor) ? this.anchor : focus_;
		var b = (focus_ < this.anchor) ? this.anchor : focus_;

		this.removeRubberband();

		var elements = $$('.rubberband_dlg_element');
		elements.each(function(el) {
			var count = parseInt(el.down('.count').innerHTML);
			if (count === t)
				el.addClassName('selection_border_top');
			if ((count >= t) && (count <= b))
				el.addClassName('selection_border_sides');
			if (count === b)
				el.addClassName('selection_border_bottom');
		});

		this.focus = focus_;
	},

	removeRubberband: function()
	{
		$$('.selection_border_top').each(function(el) { el.removeClassName('selection_border_top'); });
		$$('.selection_border_sides').each(function(el) { el.removeClassName('selection_border_sides'); });
		$$('.selection_border_bottom').each(function(el) { el.removeClassName('selection_border_bottom'); });
	},

	getCurrentElement : function(event)
	{
		var tar = this.getTarget(event);
		var el = (tar.hasClassName('rubberband_dlg_element') ? tar : tar.up('.rubberband_dlg_element'));
		if (el === undefined)
			return -1;
		return parseInt(el.down('.count').innerHTML);
	},

	getTarget : function(event) {
		var tar = $(event.originalTarget);
		if (tar === undefined)
			tar = $(event.srcElement);
		return tar;
	},

	mouseDown: function(event) {

		this.isDragging = true;
		this.anchor = this.getCurrentElement(event);
		this.redrawRubberband(this.anchor);
		Event.stop(event);
	},

	mouseMove: function(event) {
		if (this.isDragging)
		{
			var focus = this.getCurrentElement(event);
			if (focus !== this.focus)
			{
				if (focus >= 0)
					this.redrawRubberband(focus);
			}
		}
		Event.stop(event);
	},

	selectionMenu : null,

	mouseUp: function(event) {
		if (this.isDragging)
		{
			this.isDragging = false;
			this.selectionMenu = new InputDialog("border_selection");
			this.selectionMenu.setNoButtons();
			this.selectionMenu.setNotifyCancel(this.userCanceled, this);
			this.selectionMenu.addButtons([
				{ text: "Add Border", action: BorderDialog.prototype.addBorder },
				{ text: "Remove Border", action: BorderDialog.prototype.removeBorder }
			]);
			this.selectionMenu.show("Border Action", event.clientX, event.clientY, 530, 350, [] );
		}
		Event.stop(event);
	},

	userCanceled: function(This)
	{
		This.removeRubberband();
	},

	adjustOverlappingBorder: function() {
		// If the rubberband overlaps a current border, then adjust the edges of that border.
		var tops = $$('.selection_border_top');
		var bottoms = $$('.selection_border_bottom');
		// There should be exactly one of each of these. If not, then just ignore.
		if (tops.length !== 1 || bottoms.length !== 1)
			return;

		var previous = tops[0].previous();
		if (previous && previous.down().hasClassName('border_sides'))	// if the top isn't the first item, and the item before has a border
			previous.down().addClassName('border_bottom');

		var next = bottoms[0].next();
		if (next && next.down().hasClassName('border_sides'))	// if the bottom isn't the last item, and the item after has a border
			next.down().addClassName('border_top');
	},

	addBorder: function(event) {
		var elements = $$('.rubberband_dlg_element');
		elements.each(function(el) {
			// If the item doesn't have sides then it isn't part of this selection
			if (el.hasClassName('selection_border_sides'))
			{
				el.down().addClassName('border_sides');

				if (el.hasClassName('selection_border_top'))
					el.down().addClassName('border_top');
				else
					el.down().removeClassName('border_top');

				if (el.hasClassName('selection_border_bottom'))
					el.down().addClassName('border_bottom');
				else
					el.down().removeClassName('border_bottom');
			}
		});
		borderDialog.adjustOverlappingBorder();
		borderDialog.removeRubberband();
		borderDialog.selectionMenu.cancel();
	},

	removeBorder: function(event) {
		var elements = $$('.rubberband_dlg_element');
		elements.each(function(el) {
			if (el.hasClassName('selection_border_sides'))
			{
				el.down().removeClassName('border_top');
				el.down().removeClassName('border_sides');
				el.down().removeClassName('border_bottom');
			}
		});
		borderDialog.adjustOverlappingBorder();
		borderDialog.removeRubberband();
		borderDialog.selectionMenu.cancel();
	},

	handleCancel: function() {
		this.cancel();
		this.destroy();
	},

//	_handleCancel2: function() {
//		this.myPanel._handleCancel();
//	},

	handleSubmit: function() {
		var elements = $$('.border_dlg_element');
		var str = "";
		elements.each(function(el) {
			if (el.hasClassName('border_top'))
				str += 'start_border' + ',';
			else if (el.hasClassName('border_sides'))
				str += 'continue_border' + ',';
			else
				str += 'no_border' + ',';
		});

		var els = $$('.outline_tree_element_selected');
		if (els.length > 0)
		{
			var element_id = els[0].id;
			element_id = element_id.substring(element_id.lastIndexOf('_')+1);

			new Ajax.Updater("exhibit_builder_outline_content", "/my9s/modify_border", {
				parameters : { borders: str, element_id: element_id },
				evalScripts : true,
				onSuccess: function(resp) {
					new Ajax.Updater("exhibit_page", "/my9s/redraw_exhibit_page", {
						parameters : { borders: str, element_id: element_id },
						evalScripts : true,
						onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }});
				},
				onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
			});
		}

		this.cancel();
		this.destroy();
		//this.submit();
	}

};
