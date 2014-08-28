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

/*global Class, $, $$ */
/*global CreateListOfObjects, GeneralDialog, SelectInputDlg, serverAction */
/*extern editExhibitProfile, CreateSharingList */
/*extern doPublish, selectGroup, selectCluster */

var selectGroup = function(id, options, value) {
	new SelectInputDlg({
		title: 'Change Group',
		prompt: 'Group',
		id: 'group',
		options: options,
		okStr: 'Save',
		value: value,
		extraParams: { id: id },
		actions: [ '/builder/change_exhibits_group' ],
		target_els: [ null ] });
};

var selectCluster = function(id, options, value, clusterLabel) {
	new SelectInputDlg({
		title: 'Select ' + clusterLabel,
		prompt: clusterLabel,
		id: 'cluster',
		options: options,
		okStr: 'Save',
		value: value,
		extraParams: { id: id },
		actions: [ '/builder/change_exhibits_cluster' ],
		target_els: [ null ] });
};

function doPublish(exhibit_id, publish_state) {
	serverAction({action:{actions: ["/builder/publish_exhibit"], els: ["overview_data"], params: { id: exhibit_id, publish_state: publish_state }}, progress: { waitMessage: 'Updating...' }});
}

function editExhibitProfile(update_id, exhibit_id, data_class, populate_all, populate_exhibit_only, progress_img, genreList, disciplineList)
{
//	$(update_id).setAttribute('action', "/builder/edit_exhibit_overview,/builder/update_title");
//	$(update_id).setAttribute('ajax_action_element_id', "overview_data,overview_title");

	var data = $$("." + data_class);

	// Now populate a hash with all the starting values.	 The data we are starting with is all on the page with the data_class class.
	var values = {};
	data.each(function(fld) {
		values[fld.id + '_dlg'] = fld.innerHTML.unescapeHTML();
	});
	values.exhibit_id = exhibit_id;
	values.element_id = update_id;

	var changeView = function (event, param)
	{
		var view = param.arg0;
		var dlg = param.dlg;

		dlg.changePage(view, 'overview_title_dlg');

		return false;
	};

	var updateGenres = function(event, param)
	{
		var list = $('genre_list');
		var retData = param.dlg.getAllData();
		var str = "";
		for (var el in retData) {
			if (el.startsWith('genre[')) {
				var gen = el.substring(6, el.indexOf(']'));
				if (retData[el] === true) {
					if (str.length > 0)
						str += ', ';
					str += gen;
				}
			}
		}
		list.update(str);

		list = $('discipline_list');
		retData = param.dlg.getAllData();
		str = "";
		for (var el in retData) {
			if (el.startsWith('discipline[')) {
				var gen = el.substring(11, el.indexOf(']'));
				if (retData[el] === true) {
					if (str.length > 0)
						str += ', ';
					str += gen;
				}
			}
		}
		list.update(str);
		changeView(event, param);
	};

	this.sendWithAjax = function (event, params)
	{
		//var curr_page = params.curr_page;
		var dlg = params.dlg;
		dlg.setFlash("Updating exhibit...", false);
		var onSuccess = function() {
			dlg.cancel();
		};
		var onFailure = function(resp) {
			dlg.setFlash(resp.responseText, true);
		};

		var retData = dlg.getAllData();
		retData.exhibit_id = exhibit_id;
		retData.element_id = update_id;

		serverAction({action:{actions: ["/builder/edit_exhibit_overview", "/builder/update_title"], els: ["overview_data", "overview_title"], onSuccess: onSuccess, onFailure: onFailure, params: retData}});
	};

	this.deleteExhibit = function(event, params)
	{
		serverAction({confirm: { title: 'Delete Exhibit', message: 'Warning: This will permanently remove this exhibit. Are you sure you want to continue?' },
			action: { actions: { method: 'DELETE', url: "/builder/"+exhibit_id } },
			progress: { waitMessage: "Deleting exhibit..." }});
	};

	var profile = {
			page: 'profile',
			rows: [
				[ { text: 'Exhibit Title:', klass: 'new_exhibit_title' }, { input: 'overview_title_dlg', value: values.overview_title_dlg, klass: 'new_exhibit_input_long' } ],
				[ { text: 'Exhibit Short Title:', klass: 'new_exhibit_title' }, { text: '(Used for display in lists)', klass: 'link_dlg_label_and' }, { input: 'overview_resource_name_dlg', value: values.overview_resource_name_dlg, klass: 'new_exhibit_input_long' } ],
				[ { text: 'Visible URL:', klass: 'new_exhibit_title' } ],
				[ { text: "http://nines.org/exhibits/", klass: "link_prefix_text" }, { input: 'overview_visible_url_dlg', value: values.overview_visible_url_dlg, klass: 'new_exhibit_input' } ],
				[ { text: 'Thumbnail:', klass: 'new_exhibit_title' }, { input: 'overview_thumbnail_dlg', value: values.overview_thumbnail_dlg, klass: 'new_exhibit_input_long' } ],
				[ { link: '[Choose Thumbnail from Collected Objects]', klass: 'nav_link', callback: changeView, arg0: 'choose_thumbnail' }],
				[ { text: 'Genres:', klass: 'new_exhibit_title' }, { text: '&nbsp;' + values.overview_genres_dlg + '&nbsp;', id: 'genre_list' }, { link: '[Select Genres]', klass: 'nav_link', callback: changeView, arg0: 'genres' } ],
				[ { text: 'Disciplines:', klass: 'new_exhibit_title' }, { text: '&nbsp;' + values.overview_disciplines_dlg + '&nbsp;', id: 'discipline_list' }, { link: '[Select Disciplines]', klass: 'nav_link', callback: changeView, arg0: 'disciplines' } ],
				[ { text: "(" + window.gFederationName + " contributors are required to assign at least one genre to their objects. Please choose one or more from this list.)", klass: "link_dlg_label_and" }],
				[ { link: '[Completely Delete Exhibit]', klass: 'nav_link', callback: this.deleteExhibit }],
				[ { rowClass: 'gd_last_row' }, { button: 'Save', callback: this.sendWithAjax, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
			]
		};

	var selectObject = function(id) {
		// This is a callback that is called when the user selects a NINES Object.
		var thumbnail = $('overview_thumbnail_dlg');
		var selection = $(id + '_img');
		thumbnail.value = selection.src;
	};
	var objlist = new CreateListOfObjects(populate_exhibit_only, null, 'nines_object', progress_img, selectObject);
	objlist.useTabs(populate_all, populate_exhibit_only);

	var choose_thumbnail = {
			page: 'choose_thumbnail',
			rows: [
				[ { text: 'Choose Thumbnail from the list.', klass: 'new_exhibit_title' } ],
				[ { text: 'Sort objects by:', klass: 'forum_reply_label' },
					{ select: 'sort_by', callback: objlist.sortby, klass: 'link_dlg_select', value: 'date_collected', options: [{ text:  'Date Collected', value:  'date_collected' }, { text:  'Title', value:  'title' }, { text:  'Author', value:  'author' }] },
					{ text: 'and', klass: 'link_dlg_label_and' }, { inputFilter: 'filterObjects', klass: '', prompt: 'type to filter objects', callback: objlist.filter } ],
				[ { link: "Exhibit Palette", klass: 'dlg_tab_link_current', callback: objlist.ninesObjView, arg0: 'exhibit' }, { link: "All My Objects", klass: 'dlg_tab_link', callback: objlist.ninesObjView, arg0: 'all' } ],
				[ { custom: objlist, klass: 'dlg_tab_contents new_exhibit_label' } ],
				[ { rowClass: 'gd_last_row' }, { button: 'Ok', arg0: 'profile', callback: changeView }, { button: 'Cancel', arg0: 'profile', callback: updateGenres } ]
			]
		};

	var genres = {
		page: 'genres',
		rows: [
			[ { text: 'Select all the genres that apply:', klass: 'new_exhibit_title' } ],
			[ { checkboxList: 'genre', klass: 'checkbox_label', columns: 3, items: genreList, selections: values.overview_genres_dlg.split(', ') }  ],
			[ { rowClass: 'gd_last_row' }, { button: 'Ok', arg0: 'profile', callback: updateGenres }, { button: 'Cancel', arg0: 'profile', callback: updateGenres } ]	// TODO-PER: Cancel should undo any user's changes
		]
	};

	var disciplines = {
		page: 'disciplines',
		rows: [
			[ { text: 'Select all the disciplines that apply:', klass: 'new_exhibit_title' } ],
			[ { checkboxList: 'discipline', klass: 'checkbox_label', columns: 3, items: disciplineList, selections: values.overview_disciplines_dlg.split(', ') }  ],
			[ { rowClass: 'gd_last_row' }, { button: 'Ok', arg0: 'profile', callback: updateGenres }, { button: 'Cancel', arg0: 'profile', callback: updateGenres } ]	// TODO-PER: Cancel should undo any user's changes
		]
	};

	var pages = [ profile, choose_thumbnail, genres, disciplines ];

	var params = { this_id: "new_exhibit_wizard", pages: pages, body_style: "new_exhibit_div", row_style: "new_exhibit_row", title: "Edit Exhibit Profile" };
	var dlg = new GeneralDialog(params);
	changeView(null, { curr_page: '', arg0: 'profile', dlg: dlg });
	dlg.center();
	objlist.populate(dlg, false, 'thumb');
}

var CreateSharingList = Class.create({
	list : null,
	initialize : function(items, initial_selection, value_field)
	{
		var This = this;
		This.list = "<table class='input_dlg_list input_dlg_license_list' cellspacing='0'>";
		var iCount = 0;
		items.each(function(obj) {
			This.list += This.constructItem(obj.text, obj.icon, iCount, iCount === initial_selection, value_field);
			iCount++;
		});
		This.list += "</table>";
	},

	constructItem: function(text, icon, index, is_selected, value_field)
	{
		var str = "";
		if (is_selected)
			str = " class='input_dlg_list_item_selected' ";
		return "<tr " + str + "onclick='CreateSharingList.prototype.select(this,\"" + value_field + "\" );' index='" + index + "' >" +
		"<td>" + icon + "</td><td>" + text + "</td></tr>\n";
	}
});

CreateSharingList.prototype.select = function(item, value_field)
{
	var selClass = "input_dlg_list_item_selected";
	$$("." + selClass).each(function(el)
	{
		el.removeClassName(selClass);
	});
	$(item).addClassName(selClass);
	$(value_field).value = $(item).getAttribute('index');
};

