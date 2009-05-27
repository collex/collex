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

/*global Class, $, $$, $H, Element, Ajax */
/*global YAHOO */
/*global MessageBoxDlg */

////////////////////////////////////////////////////////////////////////////
/// Create the controls that select an object or an exhibit.
////////////////////////////////////////////////////////////////////////////

function linkdlg_finishedLoadingImage(This)
{
	$(This).previous().addClassName('hidden');
	$(This).removeClassName('hidden');
}

function linkdlg_select(parent_id, selClass, id){
	$(parent_id).select("." + selClass).each(function(el){
		el.removeClassName(selClass);
	});
	$(id).addClassName(selClass);
}

var CreateListOfObjects = Class.create({
	initialize: function(populate_url, initial_selection, parent_id, progress_img){
		var selClass = "linkdlg_item_selected";
		var parent = null;
		
		// Handles the user's selection
		this.getSelection = function(){
			var el = parent.down("." + selClass);
			var sel = el ? el.id : "";
			return { field: parent_id, value: sel };
		};
		
		// Creates one line in the list.
		var linkItem = function(id, img, alt, strFirstLine, strSecondLine){
			// Create all the elements we're going to need.
			var div = new Element('div', {
				id: id,
				onclick: 'linkdlg_select("' + parent_id + '", "' + selClass + '", "' + id + '");'
			});
			div.addClassName('linkdlg_item');
			var imgdiv = new Element('div');
			imgdiv.addClassName('linkdlg_img_wrapper');
			var spinner = new Element('img', {
				src: progress_img,
				alt: alt,
				title: alt
			});
			spinner.addClassName('linkdlg_img');
			var imgEl = new Element('img', {
				src: img,
				alt: alt,
				title: alt,
				onload: 'linkdlg_finishedLoadingImage(this);'
			});
			imgEl.addClassName('linkdlg_img');
			imgEl.addClassName('hidden');
			// onload="$(this).previous().addClassName('hidden'); $(this).removeClassName('hidden');" />
			var text = new Element('div');
			text.addClassName('linkdlg_text');
			var first = new Element('div').update(strFirstLine);
			first.addClassName('linkdlg_firstline');
			var second = new Element('div', { id: id + "_img" }).update(strSecondLine);
			second.addClassName('linkdlg_secondline');
			var spacer = new Element('hr');
			spacer.addClassName('clear_both');
			spacer.addClassName('linkdlg_hr');
			
			// Connect the elements
			text.appendChild(first);
			text.appendChild(second);
			imgdiv.appendChild(spinner);
			imgdiv.appendChild(imgEl);
			div.appendChild(imgdiv);
			div.appendChild(text);
			div.appendChild(spacer);
			parent.appendChild(div);
//			YAHOO.util.Event.addListener(id + "_img", 'load', finishedLoadingImage); 
//			YAHOO.util.Event.addListener($(id), 'click', CreateListOfObjects.select, id); 
		};
		
		// privileged functions
		this.populate = function(dlg){
			// Call the server to get the data, then pass it to the ObjectLists
			dlg.setFlash('Getting objects...', false);
			var objs = null;
			new Ajax.Request(populate_url, {
				method: 'get',
				onSuccess: function(resp){
					dlg.setFlash('', false);
					try {
						objs = resp.responseText.evalJSON(true);
					} 
					catch (e) {
						new MessageBoxDlg("Error", e);
					}
					
					objs.each(function(obj){
						linkItem(obj.id, obj.img, obj.title, obj.strFirstLine, obj.strSecondLine);
					});
					
//					actions.each(function(action){
//						action.el.observe('click', action.action);
//					});
				},
				onFailure: function(resp){
					dlg.setFlash(resp.responseText, true);
				}
			});
		};
		
		this.getMarkup = function() {
			parent = new Element("div", { id: parent_id });
			parent.addClassName('linkdlg_list');
			return parent;
		};
	}
});

/*
var ExhibitItem = Class.create({
	initialize: function (progress_img, title) {
		// This creates a control that contains a list of NINES Objects. When the user clicks on an object, then it is selected.
		// The control is populated by a call that either passes an array (that replaces the contents), or is passed an object and that object
		// is either added or removed.
		// When the control is first created, then an image is displayed instead. This is intended to be a progress spinner.
		this.class_type = 'ObjectList';	// for debugging

		// private variables
		var This = this;
		var outer = null;
		var div = null;
		var objs = null;
		var actions = [];
		
		// private functions
		var select = function(event)
		{
			var sel = $(this);
			var parent = sel.up('.object_list_outer');
			var els = parent.select('.object_list_row_selected');
			els.each(function(el) {
				el.removeClassName('object_list_row_selected');
			});
			sel.addClassName('object_list_row_selected');
		};

		var isEven = function(num) {
		  return !(num % 2);
		};
		
		var formatObj = function(obj, alt)
		{
			var div = new Element('div');
			//div.writeAttribute({ onclick: ObjectList.select });
			actions.push({el: div, action: select });
			div.writeAttribute({ uri: obj.uri });
			div.addClassName('object_list_row');
			div.addClassName(alt ? 'object_list_row_even' : 'object_list_row_odd');
			var img = new Element('img', { src: obj.thumbnail, alt: obj.thumbnail });
			img.addClassName('object_list_img');
			div.appendChild(img);
			div.appendChild(new Element('span').update(obj.title));
			return div;
		};
		
		// privileged functions
		this.populate = function (objects)
		{
			div.update('');
			var alt = false;	// For alternate rows
			objects.each(function(obj) {
				div.appendChild(formatObj(obj, alt));
				alt = !alt;
			});
			actions.each(function(action) {
				action.el.observe('click', action.action);
			});
		};
		
		this.add = function(object)
		{
			var els = div.select('.object_list_row');
			div.appendChild(formatObj(object, isEven(els.length)));
			actions[actions.length-1].el.observe('click', actions[actions.length-1].action);
		};
		
		this.subtract = function(object_uri)
		{
			var sel = div.select('[uri=' + object_uri + ']');
			if (sel.length > 0)
				sel[0].remove();
		};
		
		this.getSelection = function()
		{
			// This returns the object that is currently selected.
			var sel = div.select('.object_list_row_selected');
			if (sel.length === 0)
				return null;
			return sel[0].readAttribute('uri');
		};
		
		this.getMarkup =  function()
		{
			if (outer === null) {
				outer = new Element('div');
				var header = new Element('div').update(title);
				header.addClassName('object_list_title');
				outer.appendChild(header);
				div = new Element('div');
				div.addClassName('object_list_outer');
				outer.appendChild(div);
				div.appendChild(new Element('img', { src: progress_img, alt: 'progress' }));
			}
			return outer;
		};
		
		this.getAllObjects = function()
		{
			var objs = [];
			var sel = div.select('.object_list_row');
			sel.each(function(el) {
				objs.push(el.readAttribute('uri'));
			});
			return objs;
		}
	}
});

var ExhibitList = Class.create({
	initialize: function (progress_img, url_get_objects, exhibit_id) {
		// This creates 4 controls: the unselected list, the selected list, and the buttons to move items between the two
		this.class_type = 'ObjectSelector';	// for debugging

		// private variables
		var This = this;
		var olUnchosen = new ObjectList(progress_img, "Available Objects");
		var olChosen = new ObjectList(progress_img, "Objects In Exhibit");
		var divMarkup = null;
		var actions = [];
		var objs = null;
		
		// private functions
		var addSelection = function()
		{
			var sel = olUnchosen.getSelection();
			var obj = objs.detect(function(o) { return o.uri === sel; });
			if (obj) {
				olUnchosen.subtract(sel);
				olChosen.add(obj);
			}
		};
		
		var removeSelection = function()
		{
			var sel = olChosen.getSelection();
			var obj = objs.detect(function(o) { return o.uri === sel; });
			if (obj) {
				olChosen.subtract(sel);
				olUnchosen.add(obj);
			}
		};
		
		// privileged functions
		this.populate = function(dlg)
		{
			// Call the server to get the data, then pass it to the ObjectLists
			dlg.setFlash('Getting objects...', false);
			new Ajax.Request(url_get_objects, { method: 'get', parameters: { exhibit_id: exhibit_id },
				onSuccess : function(resp) {
					dlg.setFlash('', false);
					try {
						objs = resp.responseText.evalJSON(true);
					} catch (e) {
						new MessageBoxDlg("Error", e);
					}
					// We got all the data, we now want to sort it into two arrays depending on if it has been chosen,
					// then send the arrays to the correct side.
					var chosen = [];
					var unchosen = [];
					objs.each(function(obj) {
						if (obj.chosen)
							chosen.push(obj);
						else
							unchosen.push(obj);
					});
					olChosen.populate(chosen);
					olUnchosen.populate(unchosen);
					actions.each(function(action) {
						action.el.observe('click', action.action);
					});
				},
				onFailure : function(resp) {
					dlg.setFlash(resp.responseText, true);
				}
			});
		};
		
		this.getMarkup =  function()
		{
			if (divMarkup !== null)
				return divMarkup;
				
			divMarkup = new Element('div');
			divMarkup.addClassName('object_selector');
			var table = new Element('table');
			var tbody = new Element('tbody');
			var tr = new Element('tr');
			divMarkup.appendChild(table);
			table.appendChild(tbody);
			tbody.appendChild(tr);
			var td = new Element('td', { valign: 'top' });
			tr.appendChild(td);
			td.appendChild(olUnchosen.getMarkup());
			td = new Element('td');
			tr.appendChild(td);
			var but = new Element('input', { type: 'button', value: '<<' });
			td.appendChild(but);
			actions.push({el: but, action: removeSelection });
			but2 = new Element('input', { type: 'button', value: '>>' });
			td.appendChild(but2);
			actions.push({el: but2, action: addSelection });
			td = new Element('td', { valign: 'top' });
			tr.appendChild(td);
			td.appendChild(olChosen.getMarkup());
			return divMarkup;
		};
		
		this.getSelectedObjects = function()
		{
			return olChosen.getAllObjects();
		}
	}
});
*/
