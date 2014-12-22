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

/*global Class, $, $$, Element, Hash */
/*global YAHOO */
/*global GeneralDialog, MessageBoxDlg, serverRequest */
/*extern CacheObjects, CreateListOfObjects, LinkDlgHandler, ninesObjCache */

////////////////////////////////////////////////////////////////////////////
/// Create the controls that select an object or an exhibit.
////////////////////////////////////////////////////////////////////////////

var CacheObjects = Class.create({
	initialize: function(){
		var cache = new Hash();

		this.get = function(populate_url) {
			return cache.get(populate_url);
		};

		this.reset = function(populate_url) {
			cache.set(populate_url, null);
		};

		this.set = function(populate_url, c) {
			cache.set(populate_url, c);
		};

		this.resetAll = function() {
			cache = new Hash();
		};
	}
});

var ninesObjCache = new CacheObjects();

var CreateListOfObjects = Class.create({
	initialize: function(populate_collex_obj_url, initial_selection, parent_id, progress_img, selectionCallBack){
		var selClass = "linkdlg_item_selected";
		var parent = $(parent_id);	// If the element exists already, then use it, otherwise we'll create it below
		var id_prefix = null;
		var noObjMsg = null;
		var This = this;

		// Handles the user's selection
		this.getSelection = function(){
			var el = parent.down("." + selClass);
			if (!el) return { field: null, value: null };
			var sel = el.id.substring(el.id.indexOf('_')+1);
			return { field: parent_id, value: sel };
		};

		this.clearSelection = function() {
			var el = parent.down("." + selClass);
			if (el)
				el.removeClassName(selClass);
		};

		var populate_all;
		var populate_exhibit_only;
		var curr_populate;
		this.useTabs = function(populate_all_, populate_exhibit_only_) {
			populate_all = populate_all_;
			curr_populate = populate_exhibit_only = populate_exhibit_only_;
		};

		this.ninesObjView = function(event, params) {
			var scope;
			if (params.arg0 === 'all') scope = populate_all;
			else scope = populate_exhibit_only;
			if (scope !== curr_populate) {
				This.repopulate(params.dlg, scope);
				curr_populate = scope;
				var parent = params.dlg.getOuterDomElement();
				var el = parent.select('.dlg_tab_link');
				var elSel = parent.select('.dlg_tab_link_current');
				el[0].addClassName("dlg_tab_link_current");
				el[0].removeClassName("dlg_tab_link");
				elSel[0].addClassName("dlg_tab_link");
				elSel[0].removeClassName("dlg_tab_link_current");
			}
		};

		this.resetCacheIfNecessary = function() {
			if (curr_populate !== populate_exhibit_only)
				ninesObjCache.reset(populate_exhibit_only);
		};


		// Creates one line in the list.
		var linkItem = function(id, img, alt, strFirstLine, strSecondLine){
			// Create all the elements we're going to need.
			var div = new Element('div', {
				id: id
			});
			div.addClassName('linkdlg_item');
			var imgdiv = new Element('div');
			imgdiv.addClassName('linkdlg_img_wrapper');
			var spinner;
			var imgEl;
			if (img && img.length > 0) {
				spinner = new Element('img', {
					src: progress_img,
					alt: alt,
					title: alt
				});
				spinner.addClassName('linkdlg_img');

				imgEl = new Element('img', {
					id: id + "_img",
					src: img,
					alt: alt,
					title: alt
				});
				imgEl.addClassName('linkdlg_img');
				imgEl.addClassName('hidden');
			}
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
			if (img && img.length > 0) {
				imgdiv.appendChild(spinner);
				imgdiv.appendChild(imgEl);
			}
			div.appendChild(imgdiv);
			div.appendChild(text);
			div.appendChild(spacer);
			parent.appendChild(div);

			// Add the handler for when the picture has finished loading.
			var finishedLoadingImage = function(ev) {
				// This replaces the spinny with the real image.
				// We don't have any control over the size of the image, so we need to scale it so that the
				// larger size fits in the outer div. We do this by only setting one of the height or width, whichever is bigger.
				// Then we want to center the image. Centering horizontally is easy and can be done with CSS. Centering vertically,
				// however, requires us to figure out how much blank space is around the image, and using padding to move the image down.
				var elThis = $(this);
				elThis.previous().addClassName('hidden');
				var targetSize = parseInt(elThis.getStyle('height'));
				elThis.removeClassName('linkdlg_img');
				var height = elThis.height;
				var width = elThis.width;
				if (height === 0 && width === 0) {
					// This happens in IE
					elThis.height = targetSize;
					elThis.width = targetSize;
				} else if (height >= width) {
					elThis.height = targetSize;
				} else {
					elThis.width = targetSize;
					var newHeight = targetSize * height / width; // ratio of x/height = target/width
					var pad = parseInt((targetSize - newHeight) / 2);
					elThis.style.paddingTop = pad + 'px';
				}
				elThis.removeClassName('hidden');
			};
			YAHOO.util.Event.addListener(id + "_img", 'load', finishedLoadingImage);

			// Add the selection event
			var userSelect = function(ev) {
				$(parent_id).select("." + selClass).each(function(el){
					el.removeClassName(selClass);
				});
				$(this.id).addClassName(selClass);
				if (selectionCallBack)
					selectionCallBack(this.id);
			};
			YAHOO.util.Event.addListener(id, 'click', userSelect);
		};

		var createRows = function(objs, selectFirst, id_prefix) {
			parent.innerHTML = "";
			objs.each(function(obj){
				linkItem(id_prefix + '_' + obj.id, obj.img, obj.title, obj.strFirstLine, obj.strSecondLine);
			});

			noObjMsg = new Element('div', { id: 'noObjMsg' }).update('<< No objects >>');
			noObjMsg.addClassName('empty_list_text');
			parent.appendChild(noObjMsg);
			if (objs.length !== 0)
				noObjMsg.hide();

			if (initial_selection) {
				var sel = $(id_prefix + "_" + initial_selection);
				if (sel) {
					sel.addClassName(selClass);
					YAHOO.util.Event.onAvailable(sel.id, function() {
						var selOffset = sel.offsetTop;	// This is to the top of the outer container div, not the container with the scroll bar
						var divTop = parent.offsetTop;
						var selTop = selOffset - divTop;	// NOW this is the distance from the container with the scrollbar
						var selMiddle = parseInt(sel.getStyle('height')) / 2;
						var divHeight = parseInt(parent.getStyle('height'));
						if (selTop + selMiddle > divHeight) { // Only scroll if the selection isn't on the first page
							parent.scrollTop = selTop + selMiddle - divHeight / 2;
						}
					});
				} else {
					var first_item = parent.down();
					if (first_item && first_item.id !== 'noObjMsg')	// this can be null if there are no objects in the list.
						first_item.addClassName(selClass);
				}
			} else if (selectFirst) {
				var first_item2 = parent.down();
				if (first_item2 && first_item2.id !== 'noObjMsg')	// this can be null if there are no objects in the list.
					first_item2.addClassName(selClass);
			}
		};

		var clearAllRows = function() {
			var rows = $(parent).select('.linkdlg_item');
			rows.each(function(row) { row.remove(); });
			if (noObjMsg.parent)
				noObjMsg.remove();
		};

		// privileged functions
		var populate_url = populate_collex_obj_url;
		this.repopulate = function(dlg, new_url) {
			populate_url = new_url;
			clearAllRows();
			this.populate(dlg, false, id_prefix);
		};
		this.populate = function(dlg, selectFirst, id_prefix_){
			// See if the item's in the cache first, and if not, call the server for it.
			var objs = ninesObjCache.get(populate_url);
			id_prefix = id_prefix_;

			dlg.setFlash('', false);
			if (objs)
				createRows(objs, selectFirst, id_prefix);
			else {
				// Call the server to get the data, then pass it to the ObjectLists
				dlg.setFlash('Getting objects...', false);
				var onSuccess = function(resp){
					dlg.setFlash('', false);
					try {
						if (resp.responseText.length > 0) {
							objs = resp.responseText.evalJSON(true);
							ninesObjCache.set(populate_url, objs);
							createRows(objs, selectFirst, id_prefix);
						}
					}
					catch (e) {
						new MessageBoxDlg("Error", e);
					}

				};
				serverRequest({ url: populate_url, onSuccess: onSuccess});
			}

		};

		this.add = function(object)
		{
			parent.appendChild(object);
			parent.down("#noObjMsg").hide();
		};

		this.popSelection = function()
		{
			var sel = parent.down("." + selClass);
			if (sel) {
				sel.removeClassName(selClass);
				sel.remove();
			}
			if (parent.childNodes.length === 1)
				parent.down("#noObjMsg").show();
			ninesObjCache.resetAll();

			return sel;
		};

		this.getAllObjects = function()
		{
			var objs = [];
			var sel = parent.select('.linkdlg_item');
			sel.each(function(el) {
				var url = el.readAttribute('id');
				url = url.substring(url.indexOf('_')+1);
				objs.push(url);
			});
			return objs;
		};

		this.getMarkup = function() {
			if (!parent) {
				parent = new Element("div", { id: parent_id });
				var spinner = new Element('img', {
					src: progress_img
				});
				spinner.addClassName('link_dlg_object_progress');
				parent.appendChild(spinner);
				var msg = new Element('div');
				$(msg).setStyle({'padding': '8px', 'text-align': 'center'});
				msg.innerHTML = "Please wait while your collected objects are being loaded";
				parent.appendChild(msg);
			}
			parent.addClassName('linkdlg_list');
			return parent;
		};

		var filterString = "";
		var doFilter = function() {
			var rows = $(parent).select('.linkdlg_item');
			var matchedOne = false;
			rows.each(function(row) {
				var inner = row.innerHTML;
				inner = inner.stripTags();
				if( filterString.blank() || (inner.toLowerCase().indexOf( filterString ) >= 0) ) {
					row.show();
					matchedOne = true;
				}
				else {
					row.hide();
				}
			});
			if (!matchedOne)	// If we've filtered out all the objects, tell the user that.
				noObjMsg.show();
			else
				noObjMsg.hide();
		};

		this.filter = function(str) {
			filterString = str.toLowerCase();
			doFilter();
		};

		this.sortby = function(id, field) {
			var objs = ninesObjCache.get(populate_collex_obj_url);
			if (field !== 'date_collected') {	// The objects are already sorted by Date Collected
				objs = objs.sortBy(function(obj) {
					if (field === 'title') {
						if (obj.strFirstLine.length === 0)
							return 'ZZZZZZ';
						return obj.strFirstLine.toUpperCase().gsub(/[^A-Z]/, '');
					} else {
						if (obj.strSecondLine.length === 0)
							return 'ZZZZZZ';
						return obj.strSecondLine.toUpperCase().gsub(/[^A-Z]/, '');
					}
				});
			}
			clearAllRows();
			createRows(objs, true, id_prefix);
			doFilter();
		};
	}
});

////////////////////////////////////////////////////////////////////////////
/// Create the control that pops up when the RTE's link button is clicked.
////////////////////////////////////////////////////////////////////////////

var LinkDlgHandler = Class.create({
	initialize: function (populate_urls, progress_img) {

		var objRTE = null;
		var iStartPos = null;
		var iEndPos = null;
		var rawHtmlOfEditor = null;

		this.getPopulateUrls = function() { return populate_urls; };
		var getEncompassingLink = function ( rawHtmlOfEditor, iPos ) {
			// The html passed may have multiple levels of spans and other tags. We only care about spans, though.
			// We know if we got this far that the selection completely is encompassed by legal html, so we only need
			// to look at the starting position, since the end position will give the same results.
			// The algorithm is: look backwards in the string for either "</span>" or "real_link".
			// If "</span" is found, then ignore anything until before the next "<span" element.
			// If "real_link" is found, then look backwards for the "<span" element. That is the start.
			// If the start was not found, then return null.
			// If the start was found, then look forward for "<span" and "</span>".
			// If "<span" was found, then ignore everything until after the next "</span>".
			// If "</span>" was found, then that is the end. Return the [start, end] pair.

			var getFirstOf = function (str, start, match1, match2) {
				var i = str.substring(start).indexOf(match1);
				var j = str.substring(start).indexOf(match2);
				if (i >= 0 && (j === -1 || i < j))
					return { found: match1, index: start + i };
				if (j >= 0)
					return { found: match2, index: start + j };
				return { found: "" };
			};

			var getLastOf = function (str, end, match1, match2) {
				var i = str.substring(0, end).lastIndexOf(match1);
				var j = str.substring(0, end).lastIndexOf(match2);
				if (i >= 0 && i > j)
					return { found: match1, index: i };
				if (j >= 0)
					return { found: match2, index: j };
				return { found: "" };
			};

			var done = false;
			var iStart = iPos;
			while (!done) {
				var ret = getLastOf(rawHtmlOfEditor, iStart, "</span>", "real_link");
				if (ret.found === "</span>") {
					iStart = rawHtmlOfEditor.substring(0, ret.index).lastIndexOf("<span");	// skip this span, so set the index to just before it.
				} else if (ret.found === "real_link") {
					iStart = rawHtmlOfEditor.substring(0, ret.index).lastIndexOf("<span");
					done = true;
				} else
					return null;
			}

			done = false;
			var iEnd = iPos;
			while (!done) {
				var ret2 = getFirstOf(rawHtmlOfEditor, iEnd, "</span>", "<span");
				if (ret2.found === "</span>") {
					iEnd = ret2.index + 7;	// add the length of the tag itself
					done = true;
				} else if (ret2.found === "<span") {
					iEnd = rawHtmlOfEditor.substring(ret2.index).lastIndexOf("</span>");	// skip this span, so set the index to just before it.
				} else
					return null;
			}

			return [ iStart, iEnd ];
		};

		var createLinkDlg = function(starting_type, starting_selection)
		{
			var linkTypes = [ 'Collected Object', 'External Link' ];

			var selChanged = function(id, currSelection) {
				var hideClass = (currSelection === linkTypes[0]) ? '.ld_link_only' : '.ld_nines_only';
				var showClass = (currSelection !== linkTypes[0]) ? '.ld_link_only' : '.ld_nines_only';
				$$(hideClass).each(function(el) { el.addClassName('hidden'); });
				$$(showClass).each(function(el) { el.removeClassName('hidden'); });
			};

			var removeLinksFromSelection = function (strSel)
			{
				var str = strSel;
				// find "<span....real_link...>" and remove it, and also remove the matching "</span>"
				var iRealLink = str.indexOf("real_link");
				while (iRealLink > 0) {
					var iStart = str.substring(0, iRealLink).lastIndexOf("<span");
					var iEnd = str.substring(iRealLink).indexOf(">");
					var iClose = str.substring(iRealLink).indexOf("</span>");	// TBD-PER: This might not work if there is a complicated set of spans in the selection.
					if (iStart < 0 || iEnd < 0 || iClose < 0)
						return strSel;	// something went wrong, so it is safe to not remove anything
					str = str.substring(0, iStart) + str.substring(iRealLink+iEnd+1, iRealLink+iClose) + str.substring(iRealLink+iClose+7);
					iRealLink = str.indexOf("real_link");
				}
				return str;
			};

			var splitRawHtml = function ()
			{
				return { prologue: rawHtmlOfEditor.substring(0, iStartPos),
					selection: rawHtmlOfEditor.substring(iStartPos, iEndPos),
					ending: rawHtmlOfEditor.substring(iEndPos)
				};
			};

			var removeLink = function(event, params)
			{
				var html = splitRawHtml();
				html.selection = removeLinksFromSelection(html.selection);
				objRTE.updateContents(html.prologue + html.selection + html.ending);
//				objRTE.editor.setEditorHTML(html.prologue + html.selection + html.ending);
				params.dlg.cancel();
			};

			var saveLink = function(event, params) {
				// Save has been pressed.
				var dlg = params.dlg;
				var data = dlg.getAllData();

				var html = splitRawHtml();
				html.selection = removeLinksFromSelection(html.selection);

				if (data.ld_type === "Collected Object")
				{
					if (data.ld_nines_object) {
						//<span title="NINES Object: uri" real_link="uri" class="nines_linklike">target</span>
						html.selection = '<span title="' + linkTypes[0] + ': ' + data.ld_nines_object + '" real_link="' +
							data.ld_nines_object + '" class="nines_linklike">' + html.selection + "</span>";
						objRTE.updateContents(html.prologue + html.selection + html.ending);
					}
				}
				else
				{
					//<span title="External Link: url" real_link="url" class="ext_linklike">target</span>
					html.selection = '<span title="' + linkTypes[1] + ': ' + data.ld_link_url + '" real_link="' +
						data.ld_link_url + '" class="ext_linklike">' + html.selection + "</span>";
					objRTE.updateContents(html.prologue + html.selection + html.ending);
//					objRTE.editor.setEditorHTML(html.prologue + html.selection + html.ending);
				}
				params.dlg.cancel();
			};

			var objlist = new CreateListOfObjects(populate_urls[0], (starting_type === 0 ? starting_selection : null), 'ld_nines_object', progress_img);
			if (populate_urls.length === 2)
				objlist.useTabs(populate_urls[1], populate_urls[0]);

			var dlgLayout = {
					page: 'layout',
					rows: [
						[ { text: 'Type of Link:', klass: 'link_dlg_label' }, { select: 'ld_type', callback: selChanged, klass: 'link_dlg_select', value: linkTypes[starting_type], options: [{ text:  'Collected Object', value:  'Collected Object' }, { text:  'External Link', value:  'External Link' }] } ],
						[ { text: 'Sort objects by:', klass: 'link_dlg_label ld_nines_only hidden' }, { select: 'sort_by', callback: objlist.sortby, klass: 'link_dlg_select ld_nines_only hidden', value: 'date_collected', options: [{ text:  'Date Collected', value:  'date_collected' }, { text:  'Title', value:  'title' }, { text:  'Author', value:  'author' }] },
							{ text: 'and', klass: 'link_dlg_label_and ld_nines_only hidden' }, { inputFilter: 'filterObjectsLnk', prompt: 'type to filter objects', callback: objlist.filter, klass: 'ld_nines_only hidden' } ],
						[ { link: '[Remove Link]', callback: removeLink, klass: 'remove nav_link hidden' }],
						[ { custom: objlist, klass: 'link_dlg_label ld_nines_only hidden' },
						  { text: 'Link URL', klass: 'link_dlg_label ld_link_only hidden' }, { input: 'ld_link_url', value: (starting_type === 1) ? starting_selection : "", klass: 'link_dlg_input_long ld_link_only hidden' } ],
						[ { rowClass: 'gd_last_row' }, { button: 'Save', callback: saveLink, isDefault: true }, { button: 'Cancel', callback: GeneralDialog.cancelCallback } ]
					]
				};
			if (populate_urls.length === 2) {
				dlgLayout.rows[2].push( { link: "Exhibit Palette", klass: 'dlg_tab_link_current ld_nines_only hidden', callback: objlist.ninesObjView, arg0: 'exhibit' });
				dlgLayout.rows[2].push( { link: "All My Objects", klass: 'dlg_tab_link ld_nines_only hidden', callback: objlist.ninesObjView, arg0: 'all' });
			}

			var dlgParams = { this_id: "link_dlg", pages: [ dlgLayout ], body_style: "link_dlg", row_style: "link_dlg_row", title: "Set Link", focus: 'link_dlg_sel0' };
			var dlg = new GeneralDialog(dlgParams);
			//dlg.changePage('layout', 'link_dlg_sel0');
			objlist.populate(dlg, true, 'rte');
			if (starting_selection.length > 0)
				$$(".remove").each(function(el) { el.removeClassName('hidden'); });
			selChanged(null, linkTypes[starting_type]);
			dlg.center();
		};

		this.show = function(objRTE_, rawHtmlOfEditor_, iStartPos_, iEndPos_)
		{
			objRTE = objRTE_;
			iStartPos = iStartPos_;
			iEndPos = iEndPos_;
			rawHtmlOfEditor = rawHtmlOfEditor_;

			var getInternalLink = function (str)
			{
				// This will only find the first link. That's ok, that's what we want.
				var i = str.indexOf('real_link');
				if (i < 0)
					return null;

				var j = str.substring(i+11).indexOf('"');
				return str.substring(i+11, i+11+j);
			};

			// See if there is already a link. There is a link if there is one of our spans either inside the selection or outside the selection.
			// The which one it is matters. If there is a link outside the selection, then we want to expand the selection area to the size of the link
			// and pass the selection value to the dialog as a starting place.
			// If there is a link inside the selection (and there could potentially be two links!) then we keep the selection size as it is passed to us, start
			// the dialog with the first link found, and, if the user presses ok, then remove the interior links and replace them with the larger link.
			// If there are neither of the above is true, then we put up the dialog with the first NINES link selected.

			var starting_selection = "";
			var starting_type = 0;

			// See if a link encompasses the selection.
			var ret = getEncompassingLink(rawHtmlOfEditor, iStartPos);
			if (ret) {
				iStartPos = ret[0];
				iEndPos = ret[1];
				var selStr = rawHtmlOfEditor.substring(iStartPos, iEndPos);
				if (selStr.indexOf('ext_linklike') > 0)
					starting_type = 1;
				var i = selStr.indexOf('real_link') + 11;
				var j = selStr.substring(i).indexOf('"');
				starting_selection = selStr.substring(i, i+j);
			} else { // see if a link is contained in the selection. If so, use the first one.
				ret = getInternalLink(rawHtmlOfEditor.substring(iStartPos, iEndPos));
				if (ret) {
					starting_selection = ret;
				}
			}

			// Put up the selection dialog
			createLinkDlg(starting_type, starting_selection);
		};
	}
});
