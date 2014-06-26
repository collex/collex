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

/*global Class, $, $$, Element, $A */
/*global MessageBoxDlg, GeneralDialog, serverRequest, serverAction, genericAjaxFail, submitForm, reloadPage */
/*extern AddCategoryDlg, AddSiteDlg, RemoveSiteDlg, DeleteFacetDialog, EditFacetDialog, AjaxUpdate, addBadgeDlg, stopAddBadgeUpload */
/*extern AddBadgeDlg, AddPublicationImageDlg, EditGroupType, addPublicationImageDlg, stopAddPublicationImageUpload, impersonateUser */

var AjaxUpdate = Class.create({
	initialize: function (parent_div, progressMsg, validationCallback) {
		var reentrant = false;
		this.sendWithAjax = function (event, params)
		{
			if (!reentrant) {
				reentrant = true;
				//var curr_page = params.curr_page;
				var url = params.arg0;
				var dlg = params.dlg;
				var data = dlg.getAllData();

				dlg.setFlash(progressMsg, false);
				if (validationCallback) {
					var errorMsg = validationCallback(data);
					if (errorMsg) {
						dlg.setFlash(errorMsg, true);
						reentrant = false;
						return;
					}
				}

				var onSuccess = function(resp) {
					dlg.cancel();
					$(parent_div).update(resp.responseText);
					reentrant = false;
				};
				var onFailure = function(resp) {
					genericAjaxFail(dlg, resp, url);
					reentrant = false;
				};

				serverRequest({ url: url, params: data, onSuccess: onSuccess, onFailure: onFailure});
			}
		};
	}
});

var AddCategoryDlg = Class.create({
	initialize: function (parent_div, ok_action, get_categories_action) {
		// This puts up a modal dialog that allows the admin to add a category to the resource tree.
		this.class_type = 'AddCategoryDlg';	// for debugging

		// private variables
		//var This = this;
		var dlg = null;
		var categories = [];
		
		// private functions
		var populate = function()
		{
			var onSuccess = function(resp) {
				dlg.setFlash('', false);
				try {
					if (resp.responseText.length > 0)
						categories = resp.responseText.evalJSON(true);
				} catch (e) {
					new MessageBoxDlg("Error", e);
				}
				// We got all the categories. Now put it on the dialog
				var sel_arr = $$('.categories_select');
				var select = sel_arr.pop();
				select.update('');
				categories = categories.sortBy(function(category) { return category.text; });
				var value = 0;
				categories.each(function(category) {
					if (category.text === '[root]') {
						value = category.value;
						select.appendChild(new Element('option', { value: category.value, selected: 'selected' }).update(category.text));
					}
					else
						select.appendChild(new Element('option', { value: category.value }).update(category.text));
				});
				$('parent_category_id').value = value;
			};
			serverRequest({ url: get_categories_action, onSuccess: onSuccess});
		};
		
		// privileged functions
		var validation = function(data) {
			// Be sure that the user entered something
			if (data.category_name.length < 1)
				return "Please enter a name for the Resource Tree.";
			
			// Be sure that the user hasn't entered a duplicate name
			var found = false;
			categories.each(function(category) {
				if (category.text === data.category_name)
					found = true;
			});
			if (found)
				return "That category name has already been used.";
			
			return null;
		};

		var updater = new AjaxUpdate(parent_div, 'Adding Category...', validation);
		
		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { text: 'This is a label that sites and other categories can be attached to.', klass: 'new_exhibit_instructions' } ],
					[ { text: 'Category Name:', klass: 'admin_dlg_label' }, { input: 'category_name', klass: 'new_exhibit_input' } ],
					[ { text: 'Parent Category:', klass: 'admin_dlg_label' }, { select: 'parent_category_id', klass: 'categories_select', options: [ { value: -1, text: 'Loading categories. Please Wait...' } ] } ],
					[ { rowClass: 'gd_last_row' }, { button: 'Ok', arg0: ok_action, callback: updater.sendWithAjax, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
				]
			};
		
		var params = { this_id: "add_category_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Add Category To Resource Tree", focus: 'category_name' };
		dlg = new GeneralDialog(params);
		//dlg.changePage('layout', 'category_name');
		dlg.center();
		populate(dlg);
	}
});

var AddSiteDlg = Class.create({
	initialize: function (parent_div, ok_action, resource, get_categories_action) {
		// This puts up a modal dialog that allows the administrator to add sites that were found in solr to the resource tree.
		this.class_type = 'AddSiteDlg';	// for debugging

		// private variables
		//var This = this;
		var dlg = null;
		
		// private functions
		var populate = function()
		{
			var categories = [];
			var onSuccess = function(resp) {
				dlg.setFlash('', false);
				try {
					if (resp.responseText.length > 0)
						categories = resp.responseText.evalJSON(true);
				} catch (e) {
					new MessageBoxDlg("Error", e);
				}
				// We got all the categories. Now put it on the dialog
				var sel_arr = $$('.categories_select');
				var select = sel_arr.pop();
				select.update('');
				categories = categories.sortBy(function(category) { return category.text; });
				var value = 0;
				categories.each(function(category) {
					if (category.text === '[root]') {
						value = category.value;
						select.appendChild(new Element('option', { value: category.value, selected: 'selected' }).update(category.text));
					}
					else
						select.appendChild(new Element('option', { value: category.value }).update(category.text));
				});
				$('parent_category_id').value = value;
			};
			serverRequest({ url: get_categories_action, onSuccess: onSuccess});
		};
		
		// privileged functions
		var validation = function(data) {
			if (data.display_name.length < 1)
				return "Please enter a name for the Resource Tree.";
			return null;
		};

		var updater = new AjaxUpdate(parent_div, 'Adding Site...', validation);
		
		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { text: 'Enter the information for the site labeled \"' + resource + '\" in solr.', klass: 'new_exhibit_instructions' } ],
					[ { text: 'Name in Resource Tree:', klass: 'admin_dlg_label' }, { input: 'display_name', klass: 'new_exhibit_input' } ],
					[ { text: 'Parent Category:', klass: 'admin_dlg_label' }, { select: 'parent_category_id', klass: 'categories_select', options: [ { value: -1, text: 'Loading categories. Please Wait...' } ] } ],
					[ { rowClass: 'gd_last_row' }, { button: 'Ok', arg0: ok_action, callback: updater.sendWithAjax, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback }, { hidden: 'site', value: resource } ]
				]
			};
		
		var params = { this_id: "add_site_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Add Site To Resource Tree", focus: 'display_name' };
		dlg = new GeneralDialog(params);
		//dlg.changePage('layout', 'display_name');
		dlg.center();
		populate(dlg);
	}
});

var RemoveSiteDlg = Class.create({
	initialize: function (parent_div, ok_action, resource) {
		// This puts up a modal dialog that allows the administrator to remove a dead site from the resources.
		this.class_type = 'RemoveSiteDlg';	// for debugging

		// private variables
		//var This = this;
		
		// private functions
		
		// privileged functions
		var updater = new AjaxUpdate(parent_div, 'Removing the site...', null);
		
		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { text: 'You are about to delete the resource "' + resource + '" from the Resource Tree. This is probably ok because the resource doesn\'t appear to be returned by solr. However, this could also happen if the solr index is corrupted.', klass: 'new_exhibit_instructions' } ],
					[ { rowClass: 'gd_last_row' }, { button: 'Ok', arg0: ok_action, callback: updater.sendWithAjax, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback }, { hidden: 'site', value: resource } ]
				]
			};
		
		var params = { this_id: "remove_site_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Remove Site From Resource Tree" };
		var dlg = new GeneralDialog(params);
		//dlg.changePage('layout', null);
		dlg.center();
	}
});

var DeleteFacetDialog = Class.create({
	initialize: function (parent_div, ok_action, resource, is_category) {
		// This puts up a modal dialog that allows the administrator to remove a category or site from the resources.
		this.class_type = 'DeleteSiteDlg';	// for debugging

		// private variables
		//var This = this;
		
		// private functions
		
		// privileged functions
		var updater = new AjaxUpdate(parent_div, 'Deleting the site...', null);

		var dlgLayout = null;
		if (is_category) {
			dlgLayout = {
					page: 'layout',
					rows: [
						[ { text: 'You are about to delete the category "' + resource + '" from the Resource Tree. All of its children will be moved up to its parent.', klass: 'new_exhibit_instructions' } ],
						[ { rowClass: 'gd_last_row' }, { button: 'Ok', arg0: ok_action, callback: updater.sendWithAjax }, { button: 'Cancel', callback: GeneralDialog.cancelCallback, isDefault: true }, { hidden: 'site', value: resource } ]
					]
				};
		} else {
			dlgLayout = {
					page: 'layout',
					rows: [
						[ { text: 'You are about to delete the site "' + resource + '" from the Resource Tree. This resource is indexed in solr so results from this resource can be seen in the search page. Are you sure?', klass: 'new_exhibit_instructions' } ],
						[ { rowClass: 'gd_last_row' }, { button: 'Ok', arg0: ok_action, callback: updater.sendWithAjax }, { button: 'Cancel', callback: GeneralDialog.cancelCallback, isDefault: true }, { hidden: 'site', value: resource } ]
					]
				};
		}
		
		var params = { this_id: "delete_site_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Delete Site From Resource Tree" };
		var dlg = new GeneralDialog(params);
		//dlg.changePage('layout', null);
		dlg.center();
	}
});

var EditFacetDialog = Class.create({
	initialize: function (parent_div, ok_action, resource, get_resource_details_action) {
		// This puts up a modal dialog that allows the administrator to change information about a site or category.
		this.class_type = 'EditFacetDialog';	// for debugging

		// private variables
		//var This = this;
		var dlg = null;
		var categories = [];
		
		// private functions
		var populate = function()
		{
			dlg.setFlash('Loading data, please wait...', false);
			var obj = null;
			var onSuccess = function(resp) {
				dlg.setFlash('', false);
				try {
					if (resp.responseText.length > 0) {
						var ret = resp.responseText.evalJSON(true);
						categories = ret.categories;
						obj = ret.details;
					}
				} catch (e) {
					new MessageBoxDlg("Error", e);
				}
				// We got all the categories. Now put it on the dialog
				var sel_arr = $$('.categories_select');
				var select = sel_arr.pop();
				select.update('');
				categories = categories.sortBy(function(category) { return category.text; });
				categories.each(function(category) {
					if (category.text !== resource)
						select.appendChild(new Element('option', { value: category.value }).update(category.text));
				});

				// Put the details on the dialog.
				var par = $('edit_facet_dlg_sel0');
				$A(par.options).each(function(option) {
					if (parseInt(option.value) === obj.parent_id)
						option.selected = 'selected';
				});
				$('parent_category_id').value = obj.parent_id;
				if (obj.is_category) {
					$('display_name').value = resource;
					var to_hide = $$('.hide_if_category');
					to_hide.each(function(el) { el.hide(); });
					$('carousel_url').value = obj.carousel_url;
				} else {
					var to_hide2 = $$('.hide_if_site');
					to_hide2.each(function(el) { el.hide(); });
					$('display_name').value = obj.display_name;
					$('site_url').value = obj.site_url;
					$('site_thumbnail').value = obj.site_thumbnail;
				}
				$('carousel_include').checked = (obj.carousel_include === 1);
				$('carousel_description').value = obj.carousel_description;
				var img = $('carousel_thumbnail_img');
				if (img)
					img.src = obj.image;
			};
			serverRequest({ url: get_resource_details_action, params: { site: resource }, onSuccess: onSuccess});
		};
		
		// privileged functions
		this.sendWithAjax = function (event, params)
		{
			//var curr_page = params.curr_page;
			var url = params.arg0;
			var dlg = params.dlg;
			
			dlg.setFlash('Updating Facet...', false);
			var data = dlg.getAllData();
			data.site = resource;

			// Be sure that the user hasn't entered a duplicate name
			var found = false;
			if (data.display_name !== resource) {
				categories.each(function(category) {
					if (category.text === data.display_name)
						found = true;
				});
				if (found) {
					dlg.setFlash("That category name has already been used.", true);
					return;
				}
			}
			
			// This is complicated by the file upload. That can't be done in Ajax because security doesn't let javascript manipulate file data.
			// Therefore, we do both the normal ajax submit, then we submit the file with a normal html submit afterwards.
			var onSuccess = function(resp) {
				var thumb = $('carousel_thumbnail');
				var form = thumb.up('form');
				form.appendChild(new Element('input', { type: 'hidden', name: 'value', value: resource }));
//					thumb.up().appendChild(new Element('input', { id: 'value', value: resource }));
				submitForm('layout', ok_action + "_upload");	// we have to submit the form normally to get the uploaded file to get transmitted.
				dlg.cancel();
			};
			serverAction({ action: { actions: url, els: parent_div, params: data, onSuccess:onSuccess }});
		};
		
		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { text: 'Edit the facet "' + resource + '" for both the Resource Tree and the Carousel.', klass: 'new_exhibit_instructions' } ],
					[ { text: 'Parent Category:', klass: 'edit_facet_label' }, { select: 'parent_category_id', klass: 'categories_select', options: [ { value: -1, text: 'Loading categories. Please Wait...' } ] } ],
					[ { text: 'Name in Resource Tree:', klass: 'edit_facet_label' }, { input: 'display_name', klass: 'edit_facet_input' } ],
					[ { text: 'Site URL:', klass: 'hide_if_category edit_facet_label' }, { input: 'site_url', klass: 'hide_if_category edit_facet_input' } ],
					[ { text: window.gFederationName + ' Thumbnail:', klass: 'hide_if_category edit_facet_label' }, { input: 'site_thumbnail', klass: 'hide_if_category edit_facet_input' } ],
					[ { text: 'Include in Carousel:', klass: 'edit_facet_label' }, { checkbox: 'carousel_include', klass: '' } ],
					[ { text: 'Carousel Description:', klass: 'edit_facet_label' }, { textarea: 'carousel_description', klass: 'edit_facet_textarea' } ],
					[ { text: 'Carousel URL:', klass: 'hide_if_site edit_facet_label' }, { input: 'carousel_url', klass: 'hide_if_site edit_facet_input' } ],
					[ { text: 'Carousel Thumbnail:', klass: 'edit_facet_label' }, { image: 'carousel_thumbnail', klass: 'edit_profile_image', removeButton: 'Remove Thumbnail', value: " " } ],
					[ { rowClass: 'gd_last_row' }, { button: 'Ok', arg0: ok_action, callback: this.sendWithAjax, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
				]
			};
		
		var params = { this_id: "edit_facet_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Edit Facet", focus: 'display_name' };
		dlg = new GeneralDialog(params);
		//dlg.changePage('layout', 'display_name');
		dlg.center();
		populate(dlg);
	}
});

//var EditExhibitCategory = Class.create({
//	initialize: function (parent_div, ok_action, exhibit_id, starting_selection, badge_id, badges) {
//		// This puts up a modal dialog that allows the administrator to change the category of an exhibit.
//		this.class_type = 'EditExhibitCategory';	// for debugging
//
//		// private variables
//		//var This = this;
//
//		// private functions
//
//		// privileged functions
//		var updater = new AjaxUpdate(parent_div, 'Updating Exhibit Category...', null);
//
//		var dlgLayout = {
//				page: 'layout',
//				rows: [
//					[ { text: 'Choose the category that this exhibit will appear under in the Exhibit List.', klass: 'new_exhibit_instructions' } ],
//					[ { text: 'Category:', klass: 'edit_facet_label' }, { select: 'category_id', value: starting_selection, klass: 'categories_select', options: [ { value: 'peer-reviewed', text: 'Peer Reviewed' }, { value: 'community', text: 'Community' }, { value: 'classroom', text: 'Classroom' } ] } ],
//					[ { text: 'Badge:', klass: 'edit_facet_label' }, { select: 'badge_id', value: badge_id, options: badges } ],
//					[ { rowClass: 'gd_last_row' }, { button: 'Ok', url: ok_action, callback: updater.sendWithAjax, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback }, { hidden: 'exhibit_id', value: exhibit_id } ]
//				]
//			};
//
//		var params = { this_id: "change_exhibit_category_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Change Exhibit Category" };
//		var dlg = new GeneralDialog(params);
//		dlg.changePage('layout', 'category_id');
//		dlg.center();
//	}
//});

var EditGroupType = Class.create({
	initialize: function (parent_div, ok_action, group_id, starting_selection, options, badge_id, badges, publication_image_id, publication_images, header_text_color, header_background_color, link_color) {
		// This puts up a modal dialog that allows the administrator to change the category of an exhibit.
		this.class_type = 'EditGroupType';	// for debugging

		// private variables
		//var This = this;

		// private functions
		options.each(function(option) {
			if (option.text === starting_selection)
				starting_selection = option.value;
		});

		// privileged functions
		var updater = new AjaxUpdate(parent_div, 'Updating Group Type...', null);

		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { text: 'Choose the type that this group will appear under in the Exhibit List.', klass: 'new_exhibit_instructions' } ],
					[ { text: 'Type:', klass: 'edit_facet_label' }, { select: 'group_type', value: starting_selection, klass: 'categories_select', options: options } ],
					[ { text: 'Badge:', klass: 'edit_facet_label' }, { select: 'badge_id', value: badge_id, options: badges } ],
					[ { text: 'Publication Image:', klass: 'edit_facet_label' }, { select: 'publication_image_id', value: publication_image_id, options: publication_images } ],
					[ { text: 'Header Text Color:', klass: 'edit_facet_label' }, { input: 'header_text_color', value: header_text_color }],
					[ { text: 'Header Bkgd Color:', klass: 'edit_facet_label' }, { input: 'header_background_color', value: header_background_color }],
					[ { text: 'Link Color:', klass: 'edit_facet_label' }, { input: 'link_color', value: link_color }],
					[ { rowClass: 'gd_last_row' }, { button: 'Ok', arg0: ok_action, callback: updater.sendWithAjax, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback }, { hidden: 'group_id', value: group_id } ]
				]
			};

		var params = { this_id: "change_exhibit_category_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Edit Group Type", focus: 'category_id' };
		var dlg = new GeneralDialog(params);
		//dlg.changePage('layout', 'category_id');
		dlg.center();
	}
});

var addBadgeDlg = null;
function stopAddBadgeUpload(errMessage){
	if (errMessage.startsWith('OK:'))
		addBadgeDlg.fileUploadFinished(errMessage.substring(3));
	else
		addBadgeDlg.fileUploadError(errMessage);
	return true;
}

var AddBadgeDlg = Class.create({
	initialize: function (url) {
		this.class_type = 'AddBadgeDlg';	// for debugging
		var This = this;
		var dlg = null;

		var sendWithAjax = function (event, params)
		{
			addBadgeDlg = This;
			dlg.setFlash('Adding badge thumbnail...', false);
			submitForm('layout', url);	// we have to submit the form normally to get the uploaded file transmitted.
		};

		this.fileUploadError = function(errMessage) {
			dlg.setFlash(errMessage, true);
		};

		this.fileUploadFinished = function(id) {
			dlg.setFlash('Badge updated...', false);
			reloadPage();
		};
		var show = function () {
			var layout = {
					page: 'layout',
					rows: [
						[ { text: 'Choose Badge:' } ],
						[ { image: 'image', size: '47', klass: 'edit_group_thumbnail' } ],
						[ { rowClass: 'gd_last_row' }, { button: 'Upload Badge', callback: sendWithAjax }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
					]
				};

			var params = { this_id: "add_badge", pages: [ layout ], body_style: "add_badge_div", row_style: "new_exhibit_row", title: "Add Badge" };
			dlg = new GeneralDialog(params);
			//dlg.changePage('layout', null);
			dlg.center();
		};

		show();
	}
});

var addPublicationImageDlg = null;
function stopAddPublicationImageUpload(errMessage){
	if (errMessage.startsWith('OK:'))
		addPublicationImageDlg.fileUploadFinished(errMessage.substring(3));
	else
		addPublicationImageDlg.fileUploadError(errMessage);
	return true;
}

var AddPublicationImageDlg = Class.create({
	initialize: function (url) {
		var This = this;
		var dlg = null;

		var sendWithAjax = function (event, params)
		{
			addPublicationImageDlg = This;
			dlg.setFlash('Adding publication image...', false);
			submitForm('layout', url);	// we have to submit the form normally to get the uploaded file transmitted.
		};

		this.fileUploadError = function(errMessage) {
			dlg.setFlash(errMessage, true);
		};

		this.fileUploadFinished = function(id) {
			dlg.setFlash('Publication Image updated...', false);
			reloadPage();
		};
		var show = function () {
			var layout = {
					page: 'layout',
					rows: [
						[ { text: 'Choose Publication Image:' } ],
						[ { image: 'image', size: '47', klass: 'edit_group_thumbnail' } ],
						[ { rowClass: 'gd_last_row' }, { button: 'Upload Image', callback: sendWithAjax }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
					]
				};

			var params = { this_id: "add_badge", pages: [ layout ], body_style: "add_badge_div", row_style: "new_exhibit_row", title: "Add Publication Image" };
			dlg = new GeneralDialog(params);
			//dlg.changePage('layout', null);
			dlg.center();
		};

		show();
	}
});

function impersonateUser(url_get_users, url_change_user) {
	new SelectInputDlg({
		title: "Choose User to Impersonate",
		prompt: 'Select the user that you wish to impersonate',
		id: 'user_id',
		actions: url_change_user,
		target_els: null,
		pleaseWaitMsg: 'Changing apparent logged in user...',
		body_style: "edit_palette_dlg",
		options: [ { value: -1, text: 'Loading user names. Please Wait...' } ],
		populateUrl: url_get_users
	});
}

