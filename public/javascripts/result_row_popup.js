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

/*global Class, $, $$, $H, Element, Ajax, Form */
/*global MessageBoxDlg, GeneralDialog, doSingleInputPrompt, SignInDlg, ninesObjCache, ConfirmDlg, TextInputDlg, LinkDlgHandler */
/*global document, window */
/*global exhibit_names */
/*extern ResultRowDlg, StartDiscussionWithObject, bulkCollect, bulkTag, bulk_checked, doAddTag, doAddToExhibit, doAnnotation, doCollect, doRemoveCollect, doRemoveTag, encodeForUri, expandAllItems, getFullText, realLinkToEditorLink, removeHidden, tagFinishedUpdating, toggleAllBulkCollectCheckboxes */

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
		// This puts up a modal dialog that allows the administrator to change information about a site or category.
		this.class_type = 'ResultRowDlg';	// for debugging

		// private variables
		//var This = this;
		var dlg = null;
		var obj = '';
		
		// private functions
		var ajax_params = extra_button_data;
		ajax_params.uri = uri;
		var populate = function() {
			new Ajax.Request(populate_action, { method: 'get', parameters: ajax_params,
				evalScripts : true,
				onSuccess : function(resp) {
					dlg.setFlash('', false);
					try {
						obj = resp.responseText; //.evalJSON(true);
					} catch (e) {
						new MessageBoxDlg("Error", e);
					}
					
					
					// We got the details. Now put it on the dialog.
					var details_arr = $$('.result_row_details');
					var details = details_arr[0];
					details.update(obj);
					var hidden_els = details.select(".search_result_data .hidden");
					hidden_els.each(function(el) {
						el.removeClassName('hidden');
					});
				},
				onFailure : function(resp) {
					dlg.setFlash(resp.responseText, true);
				}
			});			
		};
		
		// privileged functions
		var dlgLayout = {
				page: 'layout',
				rows: [
					[ { text: '<img src="' + progress_img + '" alt="" />', klass: 'result_row_details' } ],
					[ { rowClass: 'last_row' }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
				]
			};
		
		var params = { this_id: "result_row_dlg", pages: [ dlgLayout ], body_style: "result_row_dlg", row_style: "result_row_row", title: "Object Details" };
		dlg = new GeneralDialog(params);
		dlg.changePage('layout', null);
		dlg.center();
		populate();
	}
});

// -----

function bulkTag(event)
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
		doSingleInputPrompt("Add Tag To All Checked Objects", 'Tag:', 'tag', 'bulk_tag',
			"",
			"/results/bulk_add_tag",
			$H({ uris: uris }), 'text', null, null );
	}
	else
	{
		new MessageBoxDlg("Error", "You must select one or more objects before clicking this button.");
	}
}

function bulkCollect(event)
{
	var checkboxes = Form.getInputs('bulk_collect_form', 'checkbox');

	var has_one = false;
	for (var i = 0; i < checkboxes.length; i++) {
		var checkbox = checkboxes[i];
		if (checkbox.checked) {
			has_one = true;
		}
	}

	if (has_one)
	{
		var form = document.getElementById('bulk_collect_form');
		form.submit();
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
	$$('.search_result_data .hidden').each(function (el) { el.removeClassName('hidden'); el.addClassName('was_hidden'); });
	$$('.more').each(function (el) { el.update(el.innerHTML.gsub("more", "less")); });
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

	var ptr = $(row_id);
	ptr.removeClassName('result_without_tag');
	ptr.addClassName('result_with_tag');
	var full_text = getFullText(row_id);

	var less = $('less-search_result_'+row_num);
	var params = { partial: partial, uri: uri, row_num: row_num, full_text: full_text };
	new Ajax.Updater(row_id, "/results/collect", {
		parameters : params,
		evalScripts : true,
		onSuccess: function(resp) {
			if (successCallback) successCallback(resp);
			if (less) removeHidden.delay(0.1, 'more-search_result_'+row_num, 'search_result_'+row_num);
		},
		onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
	});

	// This operation changes the set of collected objects, so we need to request them again next time.
	if (ninesObjCache)
		ninesObjCache.reset('/forum/get_nines_obj_list');	// TODO-PER: don't hard code this value!
}

function tagFinishedUpdating()
{
	var el_sidebar = document.getElementById('tag_cloud_div');
	if (el_sidebar)
	{
		new Ajax.Updater('tag_cloud_div', "/tag/update_tag_cloud", {
			onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
		});
	}
}

function doRemoveTag(uri, row_id, tag_name)
{
	var full_text = getFullText(row_id);
	var row_num = row_id.substring(row_id.lastIndexOf('_')+1);

	var less = $('less-search_result_'+row_num);
	new Ajax.Updater(row_id, "/results/remove_tag", {
		parameters : "uri="+ encodeForUri(uri) + "&row_num=" + row_num + "&tag=" + encodeForUri(tag_name) + "&full_text=" + full_text,
		evalScripts : true,
		onComplete : function(resp) {
			tagFinishedUpdating();
			if (less) removeHidden.delay(0.1, 'more-search_result_'+row_num, 'search_result_'+row_num);
		},
		onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
	});
}

function doRemoveCollect(partial, uri, row_num, row_id, successCallback)
{
	var uncollect = function() {
		var tr = document.getElementById(row_id);
		tr.className = 'result_without_tag';
		var full_text = getFullText(row_id);
		var params = { partial: partial, uri: uri, row_num: row_num, full_text: full_text };

		var less = $('less-search_result_'+row_num);
		new Ajax.Updater(row_id, "/results/uncollect", {
			parameters : params,
			evalScripts : true,
			onSuccess: function(resp) {
				if (successCallback) successCallback(resp);
				if (less) removeHidden.delay(0.1, 'more-search_result_'+row_num, 'search_result_'+row_num);
			},
			onFailure : function(resp) { new MessageBoxDlg("Error", "Oops, there's been an error."); }
		});

		// This operation changes the set of collected objects, so we need to request them again next time.
		if (ninesObjCache)
			ninesObjCache.reset('/forum/get_nines_obj_list');	// TODO-PER: don't hard code this value!
	};
	new ConfirmDlg("Remove Object from Collection?", "Are you sure you wish to remove this object from your collection?", "Yes", "No", uncollect);
}

function doAddTag(parent_id, uri, row_num, row_id)
{
	var less = $('less-search_result_'+row_num);
	var params = {
		title: "Add Tag",
		prompt: 'Tag:',
		id: 'tag',
		okStr: 'Save',
		extraParams: { uri: uri, row_num: row_num, row_id: row_id, full_text: getFullText(row_id) },
		actions: [ '/results/add_tag', '/tag/update_tag_cloud' ],
		target_els: [ row_id, 'tag_cloud_div' ],
		onComplete: function(resp) { if (less) removeHidden.delay(0.1, 'more-search_result_'+row_num, 'search_result_'+row_num); }
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

function doAnnotation(parent_id, uri, row_num, row_id, curr_annotation_id, populate_nines_obj_url, progress_img)
{
	var existing_note = $(curr_annotation_id).innerHTML;
	existing_note = existing_note.gsub("<br />", "\n");
	existing_note = existing_note.gsub("<br>", "\n");
	existing_note = realLinkToEditorLink(existing_note);

	doSingleInputPrompt("Edit Private Annotation", 'Annotation:', 'note', parent_id,
		row_id,
		"/results/set_annotation",
		$H({ uri: uri, row_num: row_num, full_text: getFullText(row_id), note: existing_note }), 'textarea',
		$H({ width: 370, height: 100, linkDlgHandler: new LinkDlgHandler(populate_nines_obj_url, progress_img) }), null );
}

var StartDiscussionWithObject = Class.create({
	initialize: function (url_get_topics, url_update, uri, discussion_button, is_logged_in, populate_nines_obj_url, progress_img) {
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
			new Ajax.Request(url_get_topics, { method: 'get', parameters: { },
				onSuccess : function(resp) {
					var topics = null;
					dlg.setFlash('', false);
					try {
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
				},
				onFailure : function(resp) {
					dlg.setFlash(resp.responseText, true);
				}
			});
		};

		// privileged functions
		this.sendWithAjax = function (event, params)
		{
			//var curr_page = params.curr_page;
			var url = params.destination;
			var dlg = params.dlg;

			dlg.setFlash('Updating Discussion Topics...', false);
			var data = dlg.getAllData();
			data.inet_thumbnail = "";
			data.thread_id = "";
			data.nines_exhibit = "";
			data.nines_object = uri;
			data.inet_url = "";
			data.disc_type = "NINES Object";

			new Ajax.Request(url, {
				parameters : data,
				evalScripts : true,
				onSuccess : function(resp) {
					$(discussion_button).hide();
					dlg.cancel();
					window.location = resp.responseText;
				},
				onFailure : function(resp) {
					dlg.setFlash(resp.responseText, true);
				}
			});
		};

		var dlgLayout = {
				page: 'start_discussion',
				rows: [
					[ { text: 'Title', klass: 'new_exhibit_label' }, { input: 'title', klass: 'new_exhibit_input_long' } ],
					[ { text: 'Select the topic you want this discussion to appear under', klass: 'new_exhibit_label' }, { select: 'topic_id', klass: 'discussion_topic_select', options: [ { value: -1, text: 'Loading user names. Please Wait...' } ] } ],
					[ { textarea: 'description' } ],
					[ { rowClass: 'last_row' }, { button: 'Ok', url: url_update, callback: this.sendWithAjax }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
				]
			};

		var params = { this_id: "start_discussion_with_object_dlg", pages: [ dlgLayout ], body_style: "edit_palette_dlg", row_style: "new_exhibit_row", title: "Choose Discussion Topic" };
		dlg = new GeneralDialog(params);
		dlg.initTextAreas([ 'fontstyle', 'link' ], new LinkDlgHandler(populate_nines_obj_url, progress_img));
		dlg.changePage('start_discussion', null);
		dlg.center();
		populate(dlg);
	}
});

function doAddToExhibit(partial, uri, index, row_id)
{
	if (exhibit_names.length === 0) {
		new MessageBoxDlg('Exhibits',
			'You have not yet created any exhibits. <a href="/my9s" class="nav_link" >Click here</a> to get started with the Exhibit Wizard.');
	} else {
		//var arr = row_id.split('-');
		//var row_num = arr[arr.length-1];

		doSingleInputPrompt("Choose exhibit",
			'Exhibit:',
			'exhibit',
			"exhibit_" + index,
			row_id + ",exhibited_objects_container",
			"/results/add_object_to_exhibit,/my9s/resend_exhibited_objects",
			$H({ partial: partial, uri: uri, row_num: index }), 'select',
			exhibit_names, null);
	}
}

