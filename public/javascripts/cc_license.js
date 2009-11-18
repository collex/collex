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

/*global GeneralDialog, MessageBoxDlg */
/*global YAHOO */
/*global Class, $, Element, Ajax */
/*extern ForumLicenseDisplay, CCLicenseDlg */

var CCLicenseDlg = Class.create({
	initialize: function (objs, currentLicense, okCallback, title, name) {
		this.class_type = 'CCLicenseDlg';	// for debugging

		var CreateListOfLicenses = Class.create({
			initialize: function(objs, initial_selection, parent_id){
				var selClass = "license_item_selected";
				var parent = $(parent_id);	// If the element exists already, then use it, otherwise we'll create it below
				if (!parent)
					parent = new Element("div", { id: parent_id });
				parent.addClassName('licensedlg_list');

				// Handles the user's selection
				this.getSelection = function(){
					var el = parent.down("." + selClass);
					var sel = el ? el.id.substring(el.id.indexOf('_')+1) : "";
					var abbrev = objs[parseInt(sel)-1].abbrev;
					return { field: parent_id, value: sel, abbrev: abbrev };
				};

				// Creates one line in the list.
				var createOneItem = function(id, img, text){
					var el_id = 'license_' + id;
					var tr = new Element('tr', { id: el_id });
					if (id === initial_selection)
						tr.addClassName(selClass);
					var td_img = new Element('td').update(img);
					var td_text = new Element('td').update(text);
					tr.appendChild(td_img);
					tr.appendChild(td_text);

					// Add the selection event
					var userSelect = function(ev) {
						$(parent_id).select("." + selClass).each(function(el){
							el.removeClassName(selClass);
						});
						$(this.id).addClassName(selClass);
					};
					YAHOO.util.Event.addListener(el_id, 'click', userSelect);
					return tr;
				};

				var createRows = function() {
					var table = new Element('table', { cellspacing: '0' });
					table.addClassName('input_dlg_list input_dlg_license_list');
					var tbody = new Element('tbody');
					table.appendChild(tbody);

					objs.each(function(obj){
						tbody.appendChild(createOneItem(obj.id, obj.icon, obj.text));
					});
					parent.appendChild(table);
				};

				this.getMarkup = function() {
					return parent;
				};

				createRows();
			}
		});

		var liclist = new CreateListOfLicenses(objs, currentLicense, 'license_list2');

		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { text: 'Share this ' + name + ' under the following license:', klass: 'input_dlg_license_list_header' } ],
					[ { custom: liclist, klass: '' } ],
					[ { text: 'Licenses provided courtesy of Creative Commons&nbsp;&nbsp;', klass: '' }, { page_link: '[ Learn more about CC licenses ]', klass: 'ext_link', new_page: "http://creativecommons.org/about/licenses", callback: GeneralDialog.openInNewWindow } ],
					[ { rowClass: 'last_row' }, { button: 'Save', callback: okCallback, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
				]
			};

		var dlgParams = { this_id: "cc_license_dlg", pages: [ dlgLayout ], body_style: "cc_license_dlg", row_style: "forum_reply_row", title: title };
		var dlg = new GeneralDialog(dlgParams);
		dlg.changePage('layout', null);
		dlg.center();
	}
});

var ForumLicenseDisplay = Class.create({
	initialize: function(params){

		var objs = null;
		var populate_url = params.populateLicenses;
		var selection = params.currentLicense;

		var setInitialSelection = function() {
			var el = $('forum_dlg_chosen_license_img');
			el.update(objs[selection-1].icon);
			el = $('forum_dlg_chosen_license_abbrev');
			el.update(objs[selection-1].abbrev);
		};
		var okCallback = function(event, params) {
			var sel = params.dlg.getAllData();
			selection = parseInt(sel.license_list2);
			setInitialSelection();
			params.dlg.cancel();
		};
		var changeDlg = function() {
			new CCLicenseDlg(objs, selection, okCallback, 'Select License', 'post');
		};
		var parent_id = params.id;
		var parent = $(parent_id);	// If the element exists already, then use it, otherwise we'll create it below
		if (!parent)
			parent = new Element("div", { id: parent_id });
		parent.addClassName('licensedisplay');
		parent.appendChild(new Element('div', { id: 'forum_dlg_chosen_license_img'}));
		parent.appendChild(new Element('span', {id: 'forum_dlg_text1' }).update('This post will be protected by an'));
		parent.appendChild(new Element('span', { id: 'forum_dlg_chosen_license_abbrev' }).update('(Loading...'));
		parent.appendChild(new Element('span', {id: 'forum_dlg_text2' }).update('license. Click <a id="forum_dlg_changedlg" href="#" onclick="return false;">here</a> to change.'));
		YAHOO.util.Event.addListener('forum_dlg_changedlg', 'click', changeDlg);

		// Handles the user's selection
		this.getSelection = function(){
			return { field: parent_id, value: selection };
		};

		// privileged functions
		this.populate = function(dlg){
			// Call the server to get the data, then pass it to the ObjectLists
			dlg.setFlash('Getting objects...', false);
			new Ajax.Request(populate_url, {
				method: 'get',
				onSuccess: function(resp){
					dlg.setFlash('', false);
					try {
						objs = resp.responseText.evalJSON(true);
						setInitialSelection();
					}
					catch (e) {
						new MessageBoxDlg("Error", e);
					}

				},
				onFailure: function(resp){
					dlg.setFlash(resp.responseText, true);
				}
			});

		};

		this.getMarkup = function() {
			return parent;
		};
	}
});
