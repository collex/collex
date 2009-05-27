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

// TODO: put these inside class / make it work for IE!
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
		var parent = $(parent_id);	// If the element exists already, then use it, otherwise we'll create it below
		
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
		
		this.add = function(object)
		{
			parent.appendChild(object);
		};
		
		this.popSelection = function(object_uri)
		{
			var sel = parent.down("." + selClass);
			if (sel) {
				sel.removeClassName(selClass);
				sel.remove();
			}
			return sel;
		};

		this.getAllObjects = function()
		{
			var objs = [];
			var sel = parent.select('.linkdlg_item');
			sel.each(function(el) {
				objs.push(el.readAttribute('id'));
			});
			return objs;
		}

		this.getMarkup = function() {
			if (!parent)
				parent = new Element("div", { id: parent_id });
			parent.addClassName('linkdlg_list');
			return parent;
		};
	}
});
