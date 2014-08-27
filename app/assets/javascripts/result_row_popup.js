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

/*global Class, $, $$, Element, Form */
/*global MessageBoxDlg, GeneralDialog, SelectInputDlg, SignInDlg, ninesObjCache, serverAction, TextInputDlg, RteInputDlg, LinkDlgHandler, serverAction, serverRequest, genericAjaxFail, gotoPage */
/*global ForumLicenseDisplay */
/*global document */
/*global submitForm, submitFormWithConfirmation */
/*global exhibit_names */
/*extern collapseAllItems, toggleItemExpand, ResultRowDlg, StartDiscussionWithObject, bulkCollect, bulkUncollect, bulkTag, bulk_checked, doAddTag, doAddToExhibit, doAnnotation, doCollect, doRemoveCollect, doRemoveTag, encodeForUri, expandAllItems, getFullText, realLinkToEditorLink, removeHidden, tagFinishedUpdating, toggleAllBulkCollectCheckboxes */

///////////////////////////////////////////////////////////////////////////

function encodeForUri(str)
{
	var value = str.gsub('%', '%25');
	value = value.gsub('#', '%23');
	value = value.gsub('&', '%26');
	value = value.gsub(/\?/, '%3f');
	return value;
}

// This gets the "full text" field in the search results. That is not saved in the cache,
// so if we do Ajax operations on a row with full text, then we would lose it. Therefore,
// we read it, then send it back to the server.
function getFullText(row_id)
{
	var el_full_text = document.getElementById(row_id+ "_full_text");
	var full_text = "";
	if (el_full_text)
		full_text = encodeForUri(el_full_text.innerHTML);
	return full_text;
}

function removeHidden(more_id, target_id)
{
	// This toggles, so see if the more_id contains the text "more" or "less"
	var btn = $(more_id);
	if (btn.innerHTML.indexOf("more") > 0) {
		$$('#' + target_id + " .hidden").each(function (el) {
			if( el.tagName !== "IMG")
				el.removeClassName('hidden'); el.addClassName('was_hidden');
		});
		btn.update(btn.innerHTML.gsub("more", "less"));
		//btn.innerHTML = btn.innerHTML.gsub("more", "less");
	} else {
		$$('#' + target_id + " .was_hidden").each(function (el) { el.addClassName('hidden'); });
		btn.update(btn.innerHTML.gsub("less", "more"));
	}
}

var ResultRowDlg = Class.create({
	initialize: function (populate_action, uri, progress_img, extra_button_data) {
		this.class_type = 'ResultRowDlg';	// for debugging

		// private variables
		//var This = this;
		var dlg = null;
		var obj = '';
		
		// private functions
		var ajax_params = extra_button_data;
		ajax_params.uri = uri;
		var populate = function() {
			var onSuccess = function(resp) {
				dlg.setFlash('', false);
				try {
					obj = resp.responseText; //.evalJSON(true);
				} catch (e) {
					genericAjaxFail(dlg, e, populate_action);
				}


				// We got the details. Now put it on the dialog.
				var details_arr = $$('.result_row_details');
				var details = details_arr[0];
				details.update(obj);
				var hidden_els = details.select(".search_result_data .hidden");
				hidden_els.each(function(el) {
					el.removeClassName('hidden');
				});
			};
			serverRequest({ url: populate_action, params: ajax_params, onSuccess: onSuccess});
		};
		
		// privileged functions
		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { text: '<img src="' + progress_img + '" alt="Please wait..." />', klass: 'result_row_details' } ],
					[ { rowClass: 'gd_last_row' }, { button: 'Cancel', callback: GeneralDialog.cancelCallback, isDefault: true } ]
				]
			};
		
		var params = { this_id: "result_row_dlg", pages: [ dlgLayout ], body_style: "result_row_dlg", row_style: "result_row_row", title: "Object Details" };
		dlg = new GeneralDialog(params);
		//dlg.changePage('layout', null);
		dlg.center();
		populate();
	}
});

// -----

function bulkTag(autocomplete_url, page)
{
	var checkboxes = Form.getInputs('bulk_collect_form', 'checkbox');

	var uris = "";
	var has_one = false;
	for (var i = 0; i < checkboxes.length; i++) {
		var checkbox = checkboxes[i];
		if (checkbox.checked) {
			uris += checkbox.value + '\t';
			has_one = true;
		}
	}

	if (has_one)
	{
		var params = {
			title: "Add Tag To All Checked Objects",
			prompt: 'Tag:',
			id: 'tag[name]',
			okStr: 'Save',
			explanation_text: 'Add multiple tags by separating them with a comma (e.g. painting, visual_art)',
         explanation_klass: 'gd_text_input_help',
			extraParams: { uris: uris, page: page },
			autocompleteParams: { url: autocomplete_url, token: ','},
      inputKlass: 'new_exhibit_autocomplete',
			actions: [ '/results/bulk_add_tag' ],
			target_els: [ null ]
		};

		new TextInputDlg(params);
	}
	else
	{
		new MessageBoxDlg("Error", "You must select one or more objects before clicking this button.");
	}
}

function bulkCollect(autocompleteUrl)
{
   var BulkTagDlg = Class.create({
      initialize: function ( params ) {
         var title = params.title;
         var addAction = params.addAction;
         var skipAction = params.skipAction; 
         var dlg = null;
         var id='tag[name]';
         var msg = 'Your objects have been collected. Would you like to add a tag to the batch?';
         var prompt = 'Tag:';
         var hint = 'Add multiple tags by separating them with a comma (e.g. painting, visual_art)';
         
         // privileged functions
         this.add = function(event, addParams)
         {
            addParams.dlg.cancel();
            var data = addParams.dlg.getAllData();
            var tag = data[id];
            addAction(tag);
         };
         this.skip = function(event, skipParams)
         {
            skipParams.dlg.cancel();
            skipAction();
         };  
  
         var dlgLayout = {
            page: 'layout',
            rows: 
            [
               [{text: msg, klass: 'gd_text_input_dlg_label'}],
               [ { text: prompt, klass: 'gd_text_input_dlg_label' }, 
                 { autocomplete: id, klass: 'new_exhibit_autocomplete', url: autocompleteUrl, token: ','} ],
               [ {text: hint, id: "gd_postExplanation", klass: 'gd_text_input_help'}], 
               [ { rowClass: 'gd_last_row'}, 
                 {button: "Add Tags", callback: this.add, isDefault: true}, 
                 {button: 'Skip Tags', callback: this.skip} ]
            ]
         };
         dlgLayout.rows.push();
         
         var dlgparams = {this_id: "gd_text_input_dlg", pages: [ dlgLayout ], body_style: "gd_message_box_dlg", row_style: "gd_message_box_row", 
            title: title, focus: GeneralDialog.makeId(id)};
         dlg = new GeneralDialog(dlgparams);
         dlg.center();
      }
   });

   // get all of the checkboxes on the bulk form
	var checkboxes = Form.getInputs('bulk_collect_form', 'checkbox');

   // see if any are checked
	var has_one = false;
	for (var i = 0; i < checkboxes.length; i++) {
		var checkbox = checkboxes[i];
		if (checkbox.checked) {
			has_one = true;
		}
	}

	if (has_one)
	{  
	   var tagAction = function(tagName)
      {   
         var ele = $('bulk_tag_text');
         ele.value = tagName;
         submitForm("bulk_collect_form", "/results/bulk_collect", "post");
      };
      var noTagAction = function()
      {
         submitForm("bulk_collect_form", "/results/bulk_collect", "post");
      };
      
      new BulkTagDlg({title:"Tag Selections", addAction: tagAction, skipAction:noTagAction});
	}
	else
	{
		new MessageBoxDlg("Error", "You must select one or more objects before clicking this button.");
	}
}

function bulkUncollect()
{
	var checkboxes = Form.getInputs('bulk_collect_form', 'checkbox');
	var has_one = false;
	for (var i = 0; i < checkboxes.length; i++) 
	{
		var checkbox = checkboxes[i];
		if (checkbox.checked) 
		{
			has_one = true;
			break;
		}
	}
	
	if (has_one)
	{
			submitFormWithConfirmation({id:"bulk_collect_form", action:"/results/bulk_uncollect",
        title:"Remove Selected Objects from Collection?", 
        message:"Are you sure you wish to remove the selected objects from your collection?"});
	}
	else
	{
		new MessageBoxDlg("Error", "You must select one or more objects before clicking this button.");
	}
}

var bulk_checked = false;

function toggleAllBulkCollectCheckboxes(link) {
  bulk_checked = !bulk_checked;
  var checkboxes = Form.getInputs('bulk_collect_form', 'checkbox');
  for (var i=0; i < checkboxes.length; i++) {
    var checkbox = checkboxes[i];
    checkbox.checked = bulk_checked;
  }

  var elements = document.getElementsByClassName('bulk_select_all');
  for (i=0; i<elements.length; i++) {
    elements[i].toggle();
  }

  elements = document.getElementsByClassName('bulk_unselect_all');
  for (i=0; i<elements.length; i++) {
    elements[i].toggle();
  }
}

function expandAllItems()
{
	var hiddenFields = jQuery('.search_result_data_container .hidden');
	hiddenFields.removeClass('hidden');
	hiddenFields.addClass('was_hidden');
	var more = jQuery('.search_result_data_container .more');
	more.each(function (index, el) { el = jQuery(el); el.html(el.html().replace("more", "less")); });
}

function collapseAllItems()
{
	var hiddenFields = jQuery('.search_result_data_container .was_hidden');
	hiddenFields.addClass('hidden');
	hiddenFields.removeClass('was_hidden');
	var more = jQuery('.search_result_data_container .more');
	more.each(function (index, el) { el = jQuery(el); el.html(el.html().replace("less", "more")); });
}

function toggleItemExpand()
{
   var exp = document.getElementById("expand_all");
   var col = document.getElementById("collapse_all");
   if (col.style.display === 'none')
   {
      exp.style.display = 'none';
      col.style.display = '';
      expandAllItems();
   }
   else
   {
      exp.style.display = '';
      col.style.display = 'none';
      collapseAllItems();
   }
   
}

function doCollect(partial, uri, row_num, row_id, is_logged_in, successCallback)
{
	if (!is_logged_in) {
		var dlg = new SignInDlg();
		dlg.setInitialMessage("Please log in to collect objects");
		dlg.setRedirectPageToCurrentWithParam('script=doCollect&uri='+uri+'&row_num='+row_num+'&row_id='+row_id);
		dlg.show('sign_in');
		return;
	}

	var full_text = getFullText(row_id);

	var params = { partial: partial, uri: uri, row_num: row_num, full_text: full_text };
	var onSuccess = function(resp) {
		var json = JSON.parse(resp.responseText);
		window.collex.setCollected(row_num, json.collected_on);
	};
	serverAction({ action: { actions: "/results/collect.json", els: [], params: params, onSuccess:onSuccess }, progress: { waitMessage: 'Collecting object...' }});

	// This operation changes the set of collected objects, so we need to request them again next time.
	if (ninesObjCache)
		ninesObjCache.reset('/forum/get_nines_obj_list');	// TODO-PER: don't hard code this value!
}

function doRemoveTag(uri, row_id, tag_name)
{
	var full_text = getFullText(row_id);
	var row_num = row_id.substring(row_id.lastIndexOf('_')+1);

	var onSuccess = function(resp) {
		var json = JSON.parse(resp.responseText);
		window.collex.redrawTags(row_num, json.my_tags, json.other_tags);
	};
	serverAction({ action: { actions: "/results/remove_tag.json", els: [], params: { uri: uri, row_num: row_num, tag: tag_name, full_text: full_text }, onSuccess:onSuccess }});
}

function doRemoveCollect(partial, uri, row_num, row_id, successCallback)
{
	var full_text = getFullText(row_id);
	var params = { partial: partial, uri: uri, row_num: row_num, full_text: full_text };

	var onSuccess = function(resp) {
		window.collex.setUncollected(row_num);
		// This operation changes the set of collected objects, so we need to request them again next time.
		if (ninesObjCache)
			ninesObjCache.reset('/forum/get_nines_obj_list');	// TODO-PER: don't hard code this value!
	};

	serverAction({confirm: { title: "Remove Object from Collection?", message: "Are you sure you wish to remove this object from your collection?"}, action: { actions: "/results/uncollect", els: [], onSuccess: onSuccess, params: params }, progress: { waitMessage: 'Removing collected object...' }});
}

function doAddTag(autocomplete_url, uri, row_num, row_id)
{
	var params = {
		title: "Add Tag",
		prompt: 'Tag:',
		explanation_text: 'Add multiple tags by separating them with a comma (e.g. painting, visual_art)',
		explanation_klass: 'gd_text_input_help',
		id: 'tag[name]',
		okStr: 'Save',
		extraParams: { uri: uri, row_num: row_num, row_id: row_id, full_text: getFullText(row_id) },
		autocompleteParams: { url: autocomplete_url, token: ','},
		inputKlass: 'new_exhibit_autocomplete',
		actions: '/results/add_tag.json',
		target_els: [],
		onSuccess: function(resp) {
			var json = JSON.parse(resp.responseText);
			window.collex.redrawTags(row_num, json.my_tags, json.other_tags);
		}
	};

	new TextInputDlg(params);
}

function realLinkToEditorLink(str) {
	// Turn real links into our links. Take this:
	//	<a class="ext_link" target="_blank" href="http://example.com">example</a>
	// and turn it into:
	//	<span class="ext_linklike" real_link="http://example.com" title="NINES Object: http://example.com">example</span>
	var i = str.indexOf("<a");
	if (i < 0)		// If there is no link, we're done.
		return str;
	var prologue = str.substring(0, i);	// strip off and save the part of the string before the link.
	var link = str.substring(i);
	i = link.indexOf("</a>");
	if (i < 0)		// If there is something illformed at any time, then just bail and return the original string.
		return str;
	var ending = link.substring(i+4);	// strip off and save the part of the string after the link.
	link = link.substring(0, i);
	var type = 'ext_linklike';	// If we find nines_link we know what it is, otherwise it is an ext_link. That catches links we didn't make.
	var type2 = 'External Link';
	if (link.indexOf('nines_link') > 0) {
		type = 'nines_linklike';
		type2 = 'NINES Object';
	}

	// If the type is a NINES Object, then we don't want the link, we want the URI.
	if (type === 'nines_linklike')
		i = link.indexOf('uri=');	// find the actual link.
	else
		i = link.indexOf('href=');	// find the actual link.

	if (i < 0)
		return str;
	var equ = link.substring(i).indexOf('=');
	link = link.substring(i+equ+2);
	i = link.indexOf('"');	// could be either kind of quote, so look for both
	var j = link.indexOf("'");
	if (i < 0)
		i = j;
	else {
		if (j >= 0 && j < i)
			i = j;
	}

	var addr = link.substring(0, i);
	//addr = addr.gsub("%7E", '~');	// Firefox, and perhaps other browsers, change this character when returning innerHTML, so we change it back.
	i = link.indexOf('>');
	if (i < 0)
		return str;
	var text = link.substring(i+1);
	link = '<span class="' + type + '" real_link="' + addr + '" title="' + type2 + ': ' + addr +'">' + text + '</span>';
	return realLinkToEditorLink(prologue + link + ending);	// call recursively to get all the links
}

function doAnnotation(uri, row_num, row_id, curr_annotation_id, populate_collex_obj_url, progress_img)
{
	var existing_note = $(curr_annotation_id).innerHTML;
	existing_note = existing_note.gsub("<br />", "\n");
	existing_note = existing_note.gsub("<br>", "\n");
	existing_note = realLinkToEditorLink(existing_note);

	var okCallback = function(value) {
		var onSuccess = function(resp) {
			window.collex.redrawAnnotation(row_num, value);
		};

		serverAction({action:{actions: "/results/set_annotation", els: [], params: { note: value, uri: uri, row_num: row_num, full_text: getFullText(row_id) }, onSuccess:onSuccess}});
	};

	var title = existing_note.length > 0 ? "Edit Private Annotation" : "Add Private Annotation";
	new RteInputDlg({
		title: title,
		value: existing_note,
		populate_urls: [populate_collex_obj_url],
		progress_img: progress_img,
		okCallback: okCallback
	});
}

var StartDiscussionWithObject = Class.create({
	initialize: function (url_get_topics, url_update, uri, title, discussion_button, is_logged_in, populate_collex_obj_url, progress_img) {
		// This puts up a modal dialog that allows the user to select the objects to be in this exhibit.
		this.class_type = 'StartDiscussionWithObject';	// for debugging

		// private variables
		//var This = this;
		var dlg = null;

		if (!is_logged_in) {
			var logdlg = new SignInDlg();
			logdlg.setInitialMessage("Please log in to start a discussion");
			logdlg.setRedirectPageToCurrentWithParam('script=StartDiscussionWithObject');
			logdlg.show('sign_in');
			return;
		}

		// private functions
		var populate = function()
		{
			var onSuccess = function(resp) {
					var topics = [];
					dlg.setFlash('', false);
					try {
						if (resp.responseText.length > 0)
							topics = resp.responseText.evalJSON(true);
					} catch (e) {
						new MessageBoxDlg("Error", e);
					}
					// We got all the topics. Now put them on the dialog.
					var sel_arr = $$('.discussion_topic_select');
					var select = sel_arr[0];
					select.update('');
					topics = topics.sortBy(function(topic) { return topic.text; });
					topics.each(function(topic) {
						select.appendChild(new Element('option', { value: topic.value }).update(topic.text));
					});
					$('topic_id').writeAttribute('value', topics[0].value);
				};
			serverRequest({ url: url_get_topics, onSuccess: onSuccess});
		};

		// privileged functions
		this.sendWithAjax = function (event, params)
		{
			//var curr_page = params.curr_page;
			var url = params.arg0;
			var dlg = params.dlg;

			dlg.setFlash('Updating Discussion Topics...', false);
			var data = dlg.getAllData();
			data.inet_thumbnail = "";
			data.thread_id = "";
			data.nines_exhibit = "";
			data.nines_object = uri;
			data.inet_url = "";
			data.inet_title = "";
			data.disc_type = "NINES Object";

			var onSuccess = function(resp) {
				$(discussion_button).hide();
				dlg.cancel();
				gotoPage(resp.responseText);
			};
			serverRequest({ url: url, params: data, onSuccess: onSuccess});
		};

		var licenseDisplay = new ForumLicenseDisplay({ populateLicenses: '/exhibits/get_licenses?non_sharing=false', currentLicense: 5, id: 'license_list' });
		var dlgLayout = {
				page: 'start_discussion',
				rows: [
					[ { text: 'Starting a discussion of: ' + title, klass: 'new_exhibit_label' } ],
					[ { custom: licenseDisplay, klass: 'forum_reply_license title' }, { text: 'Select the topic you want this discussion to appear under:', klass: 'new_exhibit_label' } ],
					[ { select: 'topic_id', klass: 'discussion_topic_select', options: [ { value: -1, text: 'Loading discussion topics. Please Wait...' } ] } ],
					[ { text: 'Title', klass: 'forum_reply_label title ' } ],
					[ { input: 'title', klass: 'forum_reply_input title' } ],
					[ { textarea: 'description' } ],
					[ { rowClass: 'gd_last_row' }, { button: 'Ok', arg0: url_update, callback: this.sendWithAjax, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
				]
			};

		var params = { this_id: "start_discussion_with_object_dlg", pages: [ dlgLayout ], body_style: "forum_reply_dlg", row_style: "new_exhibit_row", title: "Choose Discussion Topic", focus: 'start_discussion_with_object_dlg_sel0' };
		dlg = new GeneralDialog(params);
		dlg.initTextAreas({ toolbarGroups: [ 'fontstyle', 'link' ], linkDlgHandler: new LinkDlgHandler([populate_collex_obj_url], progress_img) });
		//dlg.changePage('start_discussion', 'start_discussion_with_object_dlg_sel0');
		licenseDisplay.populate(dlg);
		dlg.center();
		populate(dlg);
	}
});

function doAddToExhibit(partial, uri, index, row_id, my_collex_url)
{
	if (exhibit_names.length === 0) {
		new MessageBoxDlg('Exhibits',
			'You have not yet created any exhibits. <a href="/' + my_collex_url + '" class="nav_link" >Click here</a> to get started with the Exhibit Wizard.');
	} else {
		//var arr = row_id.split('-');
		//var row_num = arr[arr.length-1];
		var elFullText = $('search_result_' + index + '_full_text');
		var ft = elFullText ? elFullText.innerHTML : '';
		var options = [];
		exhibit_names.each(function(name) {
			var trunct_name = name.length > 60 ? name.substring(0, 60) + '...' : name;
			options.push({ text: trunct_name, value: name });
		});

		function onSuccess(resp) {
			var json = JSON.parse(resp.responseText);
			window.collex.redrawExhibits(index, json.exhibits);
		}

		new SelectInputDlg({
			title: "Choose exhibit",
			prompt: 'Exhibit:',
			id: 'exhibit',
			actions: "/results/add_object_to_exhibit",
			target_els: [ ],
			okStr: "Save",
			options: options,
			extraParams: { partial: partial, uri: uri, row_num: index, full_text: ft },
			onSuccess: onSuccess
		});
	}
}

