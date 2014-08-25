jQuery(document).ready(function($) {
	"use strict";
	var body = $("body");

	function create_facet_button(label, value, action, key) {
		return window.pss.createHtmlTag("button", { 'class': 'select-facet nav_link', 'data-action': action, 'data-key': key, 'data-value': value }, label);
	}

	function number_with_delimiter(number) {
		var delimiter = ',';
		var separator = '.';
		var parts = (""+number).split('.');
		parts[0] = parts[0].replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1" + delimiter);
		return parts.join(separator);
	}

	function getArchive(handle) {
		function getArchiveOneBranch(branch, handle) {
			for (var i = 0; i < branch.length; i++) {
				var archive = branch[i];
				if (archive.handle === handle)
					return archive;
				if (archive.children) {
					var a = getArchiveOneBranch(archive.children, handle);
					if (a)
						return a;
				}
			}
			return null;
		}
		return getArchiveOneBranch(window.collex.facetNames.archives, handle);
	}

	function getSite(archive) {
		var resource = getArchive(archive);
		if (resource)
			return window.pss.createHtmlTag("a", { 'class': 'nines_link', target: '_blank', href: resource.site_url  }, resource.name);
	else
			return archive;
	}

	var progressLinkCounter = 0; // Just need a unique number, so we'll just keep counting here.

	function thumbnailImageTag(hit) {
		// The image comes from one of these places:
		// There may be keys for 'image' and 'thumbnail' in the hit.
		// There may be a thumbnail associated with the archive.
		// There is definitely a thumbnail associated with the active federation.
		var thumbnail = hit.thumbnail;
		var image = thumbnail ? hit.image : undefined; // If we don't have our own thumbnail, we never want to have a lightbox. (That probably doesn't exist in any RDF, anyway.)
		if (!thumbnail) {
			var archive = getArchive(hit.archive);
			if (archive)
				thumbnail = archive.thumbnail;
		}
		if (!thumbnail)
			thumbnail = window.collex.images.federationThumbnail;

		var progressId = "progress_" + progressLinkCounter++;
		var title = hit.title ? hit.title : "Image";
		var imageEl = window.pss.createHtmlTag("img", { 'src': thumbnail, alt: title, 'class': 'result_row_img hidden', onload: "finishedLoadingImage(\"" + progressId + "\", this, 100, 100);" });
		var progressEl = window.pss.createHtmlTag("img",
			{ id: progressId, 'class': 'progress_timeout result_row_img_progress', src: window.collex.images.spinner, alt: 'loading...',
				'data-noimage': window.collex.images.spinnerTimeout });
		if (image) {
			// Wrap the image in an anchor that will pull up the lightbox.
			if (title.length > 60)
				title = title.substr(0,59) + "...";
			var lightboxCall = 'showInLightbox({ title: "' + title + '", img: "' + image + '", spinner: "' + window.collex.images.spinner + '", size: 500 }); return false;';
			imageEl = window.pss.createHtmlTag("a", { 'class': 'nines_pic_link', onclick: lightboxCall, href: '#' }, imageEl);
		}
		return progressEl + imageEl;
	}
	function createImageBlock(index, hit) {
		var check = "";
		var isLoggedIn = window.collex.currentUserId && window.collex.currentUserId > 0;
		if (isLoggedIn)
			check = window.pss.createHtmlTag("input", { 'type': 'checkbox', 'id': "bulk_collect_"+index, 'name': "bulk_collect_"+index, 'value': hit.uri });
		var image = thumbnailImageTag(hit);
		var icons = "";
		if (hit.freeculture === 'true')
			icons += window.pss.createHtmlTag("span", { 'class': 'tooltip free_culture' }, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
				window.pss.createHtmlTag("span", { 'class': 'result_row_tooltip' }, "Free Culture resource"));
		if (hit.has_full_text === 'true')
			icons += window.pss.createHtmlTag("span", { 'class': 'tooltip full_text' }, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
				window.pss.createHtmlTag("span", { 'class': 'result_row_tooltip' }, "Full text provided for this document"));
		if (hit.source_xml === 'true')
			icons += window.pss.createHtmlTag("span", { 'class': 'tooltip has_xml_source' }, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
				window.pss.createHtmlTag("span", { 'class': 'result_row_tooltip' }, "XML source available for this document"));

		var resultRowIcons = window.pss.createHtmlTag("div", { 'class': 'result_row_icons' }, icons);
		var thumbnail = window.pss.createHtmlTag("div", { 'class': 'search_result_image' }, image+resultRowIcons);
		return window.pss.createHtmlTag("div", { 'class': 'search_result_left' }, check+thumbnail);
	}

	function createActionButtons(hit, isCollected) {
		var collect = isCollected ? '' : window.pss.createHtmlTag("button", { 'class': 'collect' }, "Collect");
		var uncollect = isCollected ? window.pss.createHtmlTag("button", { 'class': 'uncollect' }, "Uncollect") : '';
		var discuss = window.pss.createHtmlTag("button", { 'class': 'discuss' }, "Discuss");
		var exhibit = isCollected ? window.pss.createHtmlTag("button", { 'class': 'exhibit' }, "Exhibit") : '';
		var typewright = window.collex.hasTypewright && hit.typewright ? window.pss.createHtmlTag("button", { 'class': 'edit' }, "Edit") : '';
		return window.pss.createHtmlTag("div", { 'class': 'search_result_buttons' }, collect+uncollect+discuss+exhibit+typewright);
	}

	function createZoteraTitle(obj) {
		var eUrl = encodeURIComponent(obj.url);
		var eTitle = obj.title ? encodeURIComponent(obj.title) : '';
		var eAut = obj.role_AUT ? encodeURIComponent(obj.role_AUT) : '';
		var eDat = obj.date_label ? encodeURIComponent(obj.date_label) : '';
		var ePub = obj.role_PBL ? encodeURIComponent(obj.role_PBL) : '';

		var arr = [ "ctx_ver=Z39.88-2004",
			"rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook",
			"rft_id=" + eUrl,
			"rfr_id=info%3Asid%2Focoins.info%3Agenerator",
			"rft.genre=book",
			"rft.btitle=" + eTitle,
			"rft.title=" + eTitle,
			"rft.aulast=" + eAut,
			"rft.aufirst=",
			"rft.au=" + eAut,
			"rft.date=" + eDat,
			"rft.pub=" + ePub ];
		return arr.join("&amp;");
	}

	var titleLinkCounter = 0; // Just need a unique number, so we'll just keep counting here.
	function createTitleLink(title, url) {
		if (title.length < 200)
			return window.pss.createHtmlTag("a", { 'class': 'nines_link doc-title', 'href': url, target: '_blank', title: ' ' }, title);
		else {
			titleLinkCounter++;
			var title1 = title.substr(0, 199);
			var title2 = title.substr(199);
			var id = "title_more_" + titleLinkCounter;
			var initial_title = title1 + window.pss.createHtmlTag("span", { id: id, style: 'display:none;' }, title2);
			return window.pss.createHtmlTag("a", { class: 'nines_link doc-title', title: title, target: '_blank', href: url }, initial_title) +
				window.pss.createHtmlTag("a", { href: '#', onclick: 'return false;', class: 'nav_link more_link', 'data-div': id, 'data-less': '[show less]', title: ' ' }, '...[show full title]');
		}
	}

	function createResultHeader(obj) {
		var uriLink = '';
		if (window.collex.isAdmin)
			uriLink = window.pss.createHtmlTag("a",
				{ 'class': 'uri_link', 'href': '#' }, 'uri') +
				window.pss.createHtmlTag("span", { 'style': 'display:none;' }, obj.uri+ "&nbsp;");

		var a = createTitleLink(obj.title, obj.url);

		var titleEl = window.pss.createHtmlTag("div", { 'class': 'search_result_header' }, uriLink+a);
		return window.pss.createHtmlTag("span", { 'class': 'Z3988', title: createZoteraTitle(obj) }, titleEl);
	}

	var needShowMoreLink = false;

	function createResultContentItem(type, label, value, startHidden, rowClass) {
		if (!value)
			return "";

		var klass = "row";
		if (startHidden) {
			klass += ' hidden';
			needShowMoreLink = true;
		}
		if (rowClass)
			klass += " " + rowClass;

		switch (type) {
			case "separate_lines":
				var html = window.pss.createHtmlTag("div", { 'class': klass },
						window.pss.createHtmlTag("span", { 'class': 'label' }, label) +
						window.pss.createHtmlTag("span", { 'class': 'value' }, value[0]));
				for (var i = 1; i < value.length; i++) {
					html += window.pss.createHtmlTag("div", { 'class': klass },
							window.pss.createHtmlTag("span", { 'class': 'label' }, '') +
							window.pss.createHtmlTag("span", { 'class': 'value' }, value[i]));
				}
				return html;
			case "single_item":
				return window.pss.createHtmlTag("div", { 'class': klass },
						window.pss.createHtmlTag("span", { 'class': 'label' }, label) +
						window.pss.createHtmlTag("span", { 'class': 'value' }, value));
			case "multiple_item":
				return window.pss.createHtmlTag("div", { 'class': klass },
						window.pss.createHtmlTag("span", { 'class': 'label' }, label) +
						window.pss.createHtmlTag("span", { 'class': 'value' }, value.join("; ")));
			case "one_col":
				return window.pss.createHtmlTag("div", { 'class': klass },
						window.pss.createHtmlTag("span", { 'class': 'one-col' }, value));
		}
	}

	function createFullTextExcerpt(text) {
		if (!text || text.length === 0) return "";
		return window.pss.createHtmlTag("div", { 'class': 'search_result_full_text_label' }, 'Excerpt from Full Text:') +
			window.pss.createHtmlTag("span", { 'class': 'snippet' }, text);
	}

	function formatTags(uri, index, tags) {
		// TODO-PER: Make distinction between "my tag" and not.
		if (!tags) return "";
		var html = "";
		for (var i = 0; i < tags.length; i++) {
			if (i !== 0)
				html += " | ";
			html += window.pss.createHtmlTag("a", { 'class': 'tag_link my_tag', title: "view all objects tagged &quot;" + tags[i] + "&quot;", href: '/tags/results?tag="ajax"&amp;view=tag' }, tags[i]);
			var remove = "doRemoveTag('" + uri + "', 'search_result_" + index + "', '" + tags[i] + "'); return false;";
			html += window.pss.createHtmlTag("a", { 'class': 'modify_link my_tag remove_tag', title: "delete tag &quot;" + tags[i] + "&quot;", onclick: remove,  href: '#' }, 'X');
		}
		return html;
	}

	function formatDate(date) {
		var months = ["January", "February", "March",
			"April", "May", "June", "July", "August", "September",
			"October", "November", "December"];

		var arr = date.split('T');
		arr = arr[0].split('-');
		var day = parseInt(arr[2], 10);
		var month = parseInt(arr[1], 10) - 1;
		var year = arr[0];
		return months[month] + " " + day + ", " + year;
	}

	function createResultContents(obj, index, collectedDate) {
		needShowMoreLink = false;
		var html = "";
		html += createResultContentItem('one_col', '', obj.alternative, false);
		html += createResultContentItem('separate_lines', 'Source:', obj.source, false);
		html += createResultContentItem('multiple_item', 'By:', obj.role_AUT, false);
		html += createResultContentItem('multiple_item', 'Artist:', obj.role_ART, false);
		if (collectedDate)
			html += createResultContentItem('single_item', 'Collected&nbsp;on:', formatDate(collectedDate), false);

		var click = "doAddTag('/tag/tag_name_autocomplete', 'add_tag_" + index + "', '" + obj.uri + "', " + index + ", 'search_result_" + index + "', event); return false;";
		var tags = formatTags(obj.uri, index, obj.tags) + window.pss.createHtmlTag("button", { 'class': 'modify_link', id: "add_tag_"+index, onclick: click }, "[add&nbsp;tag]");
		html += createResultContentItem('single_item', 'Tags:', tags, false, 'tag-list');

//<%################### -%>
		// TODO-PER: do tags
		//<% tags = Tag.get_tags_for_uri(hit['uri']) -%>
//<% if no_links -%>
//<% result_row_tags_no_links(rows, "Tags:", tags) -%>
//<% else # if we want links on the tags -%>
//<% result_row_tags_links(rows, index, row_id, hit, "Tags:", tags, item, user_signed_in?, is_collected) %>
//<% end # if no_links -%>
//<%################### -%>
		var site = getSite(obj.archive);
		html += createResultContentItem('single_item', 'Site:', site, false);
		html += createResultContentItem('multiple_item', 'Genre:', obj.genre, true);
		html += createResultContentItem('multiple_item', 'Discipline:', obj.discipline, true);
		html += createResultContentItem('multiple_item', 'Subject:', obj.subject, true);
		html += createResultContentItem('single_item', 'Exhibit&nbsp;type:', obj.exhibit_type, false);
		html += createResultContentItem('single_item', 'License:', obj.license, false);

		html += createResultContentItem('multiple_item', 'Editor:', obj.role_EDT, true);
		html += createResultContentItem('multiple_item', 'Publisher:', obj.role_PBL, true);
		html += createResultContentItem('multiple_item', 'Owner:', obj.role_OWN, true);
		html += createResultContentItem('multiple_item', 'Translator:', obj.role_TRL, true);
		html += createResultContentItem('multiple_item', 'Date:', obj.date_label, true);
		html += createResultContentItem('multiple_item', 'Provenance:', obj.provenance, true);
		html += createResultContentItem('multiple_item', 'Architect:', obj.role_ARC, true);
		html += createResultContentItem('multiple_item', 'Binder:', obj.role_BND, true);
		html += createResultContentItem('multiple_item', 'Book Designer:', obj.role_BKD, true);
		html += createResultContentItem('multiple_item', 'Book Producer:', obj.role_BKP, true);
		html += createResultContentItem('multiple_item', 'Broadcaster:', obj.role_BRD, true);
		html += createResultContentItem('multiple_item', 'Calligrapher:', obj.role_CLL, true);
		html += createResultContentItem('multiple_item', 'Cartographer:', obj.role_CTG, true);
		html += createResultContentItem('multiple_item', 'Collector:', obj.role_COL, true);
		html += createResultContentItem('multiple_item', 'Colorist:', obj.role_CLR, true);
		html += createResultContentItem('multiple_item', 'Commentator:', obj.role_CWT, true);
		html += createResultContentItem('multiple_item', 'Compiler:', obj.role_COM, true);
		html += createResultContentItem('multiple_item', 'Compositor:', obj.role_CMT, true);
		html += createResultContentItem('multiple_item', 'Cinematographer:', obj.role_CNG, true);
		html += createResultContentItem('multiple_item', 'Conductor:', obj.role_CND, true);
		html += createResultContentItem('multiple_item', 'Creator:', obj.role_CRE, true);
		html += createResultContentItem('multiple_item', 'Director:', obj.role_DRT, true);
		html += createResultContentItem('multiple_item', 'Dubious Author:', obj.role_DUB, true);
		html += createResultContentItem('multiple_item', 'Facsimilist:', obj.role_FAC, true);
		html += createResultContentItem('multiple_item', 'Former Owner:', obj.role_FMO, true);
		html += createResultContentItem('multiple_item', 'Illuminator:', obj.role_ILU, true);
		html += createResultContentItem('multiple_item', 'Illustrator:', obj.role_ILL, true);
		html += createResultContentItem('multiple_item', 'Interviewer:', obj.role_IVR, true);
		html += createResultContentItem('multiple_item', 'Interviewee:', obj.role_IVE, true);
		html += createResultContentItem('multiple_item', 'Lithographer:', obj.role_LTG, true);
		html += createResultContentItem('multiple_item', 'Owner:', obj.role_OWN, true);
		html += createResultContentItem('multiple_item', 'Performer:', obj.role_PRF, true);
		html += createResultContentItem('multiple_item', 'Printer:', obj.role_PRT, true);
		html += createResultContentItem('multiple_item', 'Printer of plates:', obj.role_POP, true);
		html += createResultContentItem('multiple_item', 'Printmaker:', obj.role_PRM, true);
		html += createResultContentItem('multiple_item', 'Producer:', obj.role_PRO, true);
		html += createResultContentItem('multiple_item', 'Production Company:', obj.role_PRN, true);
		html += createResultContentItem('multiple_item', 'Repository:', obj.role_RPS, true);
		html += createResultContentItem('multiple_item', 'Rubricator:', obj.role_RBR, true);
		html += createResultContentItem('multiple_item', 'Scribe:', obj.role_SCR, true);
		html += createResultContentItem('multiple_item', 'Sculptor:', obj.role_SCL, true);
		html += createResultContentItem('multiple_item', 'Translator:', obj.role_TRL, true);
		html += createResultContentItem('multiple_item', 'Type Designer:', obj.role_TYD, true);
		html += createResultContentItem('multiple_item', 'Typographer:', obj.role_TYG, true);
		html += createResultContentItem('multiple_item', 'Wood Engraver:', obj.role_WDE, true);
		html += createResultContentItem('multiple_item', 'Wood Cutter:', obj.role_WDC, true);
		html += createResultContentItem('multiple_item', 'Has Part:', obj.hasPart, true);
		html += createResultContentItem('multiple_item', 'Is Part Of:', obj.isPartOf, true);
		// TODO-PER: do the exhibit links.
//<%################### -%>
//<% if !no_links -%>
//<% result_row_exhibits(rows, hit, current_user) %>
//<% end %>

		if (needShowMoreLink) {
			html += window.pss.createHtmlTag("button", { id: "more-search_result_"+index,  'class': 'nav_link more', onclick: 'removeHidden("more-search_result_' + index + '", "search_result_' + index + '");return false;'}, '[more...]');
		}

		if (collectedDate) {
			var doAnnotation = "doAnnotation('" + obj.uri + "', " + index + ", 'search_result_" + index + "', 'annotation_" + index + "', '/forum/get_nines_obj_list', '" +
				window.collex.images.spinner + "'); return false;";
			var linkLabel;
			var currentAnnotation = "<br>" + window.pss.createHtmlTag("span", { id: 'annotation_' + index, 'class': 'annotation' }, obj.annotation);
			if (obj.annotation) {
				linkLabel = "Edit Private Annotation";
			} else
				linkLabel = "Add Private Annotation";
			html += window.pss.createHtmlTag("div", { 'class': 'row' },
				window.pss.createHtmlTag("button", { 'class': 'modify_link', onclick: doAnnotation }, linkLabel)+currentAnnotation);
		}

		html += createFullTextExcerpt(obj.text);
		return window.pss.createHtmlTag("div", { 'class': 'search_result_data_container' }, html);
	}

	function createMediaBlock(obj, index, isCollected, collectedDate) {
		var imageBlock = createImageBlock(index, obj);
		var actionButtons = createActionButtons(obj, isCollected);
		var resultHeader = createResultHeader(obj);
		var resultContents = createResultContents(obj, index, collectedDate);
		var results = window.pss.createHtmlTag("div", { 'class': 'search_result_right' }, resultHeader+resultContents);
		var html = window.pss.createHtmlTag("div", { 'class': 'clear_both' }, "") +
			window.pss.createHtmlTag("hr", { 'class': 'search_results_hr' });
		var klass = "search-result";
		if (isCollected)
			klass += " result_row_collected";
		html += window.pss.createHtmlTag("div", { 'id': 'search_result_'+ index, 'class': klass, 'data-index': index, 'data-uri': obj.uri }, imageBlock+actionButtons+results);
		return html;
	}

	function createPagination(curr_page, total, page_size) {
		var html = "";
		total = parseInt(total, 10);
		page_size = parseInt(page_size, 10);
		curr_page = parseInt(curr_page, 10);
		var num_pages = Math.ceil(total / page_size);

		// If there's only one page, don't show any pagination
		if (num_pages === 1)
			return "";

		//Show only a maximum of 11 items, with the current item centered if possible.
		//First figure out the start and end points we want to display.
		var first;
		var last;
		if (num_pages < 11) {
			first = 1;
			last = num_pages;
		} else {
			first = curr_page - 5;
			last = curr_page + 5;
			if (first < 1) {
				first = 1;
				last = first + 10;
			}
			if (last > num_pages) {
				last = num_pages;
				first = last - 10;
			}
		}

		if (first > 1) {
			html += create_facet_button('first', '1', "replace", 'page');
			html += "&nbsp;&nbsp;";
		}

		if (curr_page > 1) {
			html += create_facet_button('<<', curr_page - 1, "replace", 'page');
			html += "&nbsp;&nbsp;";
		}

		for (var pg = first; pg <= last; pg++) {
			if (pg === curr_page)
				html += window.pss.createHtmlTag("span", { 'class': "current_serp" }, pg);
			else
				html += create_facet_button(pg, pg, "replace", 'page');
			html += "&nbsp;&nbsp;";
		}

		if (last < num_pages) {
			html += "...&nbsp;&nbsp;";
			if (num_pages > 12)
				html += create_facet_button(num_pages, num_pages, "replace", 'page');
			html += "&nbsp;&nbsp;";
		}

		if (curr_page < num_pages) {
			html += create_facet_button('>>', curr_page + 1, "replace", 'page');
			html += "&nbsp;&nbsp;";
		}

		if (last < num_pages) {
			html += create_facet_button('last', num_pages, "replace", 'page');
			html += "&nbsp;&nbsp;";
		}

		return html;
	}

	function createFacetRow(name, count, dataKey, isSelected, label) {
		if (!label) label = name;
		if (isSelected) {
			var remove = create_facet_button('[X]', name, "remove", dataKey);
			return window.pss.createHtmlTag("tr", { 'class': "limit_to_selected" },
					window.pss.createHtmlTag("td", { 'class': "limit_to_lvl1" }, label + "&nbsp;&nbsp;" + remove) +
					window.pss.createHtmlTag("td", { 'class': "num_objects" }, number_with_delimiter(count)));
		} else {
			var button = create_facet_button(label, name, "add", dataKey);
			return window.pss.createHtmlTag("tr", {},
				window.pss.createHtmlTag("td", { 'class': "limit_to_lvl1" }, button) +
				window.pss.createHtmlTag("td", { 'class': "num_objects" }, number_with_delimiter(count)));
		}
	}

	function createFacetBlock(facet_class, hash, dataKey, selected, labels) {
		var html = "";
		if (typeof selected === 'string') selected = [ selected ];
		for (var key in hash) {
			if (hash.hasOwnProperty(key)) {
				var selectedIndex = $.inArray(key, selected);
				var label = key;
				if (labels) label = labels[key];
				html += createFacetRow(key, hash[key], dataKey, selectedIndex !== -1, label);
			}
		}

		var block = $("."+facet_class);
		var header = window.pss.createHtmlTag("tr", {}, block.find("tr:first-of-type").html());
		block.html(header + html);
	}

	function createResourceNode(id, level, label, total, childClass) {
		// TODO-PER: figure out how to decide whether the item starts open.
		var open = window.pss.createHtmlTag("button", { 'class': 'nav_link  limit_to_category', 'data-action': "open" },
			window.pss.createHtmlTag("img", { 'alt': 'Arrow Open', src: window.collex.images.arrow_open }));
		var close = window.pss.createHtmlTag("button", { 'class': 'nav_link  limit_to_category', 'data-action': "close" },
			window.pss.createHtmlTag("img", { 'alt': 'Arrow Close', src: window.collex.images.arrow_close }));
		var name = window.pss.createHtmlTag("button", { 'class': 'nav_link limit_to_category', 'data-action': "toggle" }, label);

		var left = window.pss.createHtmlTag("td", { 'class': 'resource-tree-node limit_to_lvl'+level, 'data-id': id }, open+close+name);
		var right = window.pss.createHtmlTag("td", { 'class': 'num_objects' }, number_with_delimiter(total));
		var trClass = "resource_node " + childClass;
		return window.pss.createHtmlTag("tr", { id: 'resource_'+id, 'class': trClass }, left+right);
	}

	function createResourceLeaf(id, level, label, total, handle, childClass) {
		var left = window.pss.createHtmlTag("td", { 'class': 'limit_to_lvl'+level }, create_facet_button(label, handle, 'replace', 'archive'));
		var right = window.pss.createHtmlTag("td", { 'class': 'num_objects' }, total);
		return window.pss.createHtmlTag("tr", { id: 'resource_'+id, 'class': childClass }, left+right);
	}

	function createResourceSection(resources, hash, level, childClass) {
		var html = "";
		var total = 0;
		for (var i = 0; i < resources.length; i++) {
			var archive = resources[i];
			if (archive.children) {
				var section = createResourceSection(archive.children, hash, level + 1, childClass + ' child_of_'+archive.id);
				total += section.total;
				if (total > 0) {
					var thisNode = createResourceNode(archive.id, level, archive.name, number_with_delimiter(total), childClass);
					html += thisNode + section.html;
				}
			} else {
				if (hash[archive.handle]) { // If there are no results, then we don't show that archive.
					html += createResourceLeaf(archive.id, level, archive.name, hash[archive.handle], archive.handle, childClass);
					total += parseInt(hash[archive.handle], 10);
				}
			}
		}
		return { html: html, total: total };
	}

	function createResourceBlock(hash) {

		var html = createResourceSection(window.collex.facetNames.archives, hash, 1, '').html;

		var block = $(".facet-archive");
		var header = window.pss.createHtmlTag("tr", {}, block.find("tr:first-of-type").html());
		block.html(header + html);
	}

	function createTotals(total) {
		$("#search_result_count").text("Search Results (" + number_with_delimiter(total)+")");
	}

	function setFederations(federations, selected) {
		var federationCounts = $(".limit_to_federation .num_objects");
		federationCounts.each(function(index, el) {
			el = $(el);
			var fed = el.attr("data-federation");
			if (federations[fed])
				el.text(number_with_delimiter(federations[fed]));
			else
				el.text("");
		});
		var federationChecks = $(".limit_to_federation input");
		if (!selected)
			federationChecks.prop('checked', true);
		else {
			federationChecks.each(function(index, el) {
				var name = el.name;
				$(el).prop('checked', selected[name]);
			});
		}
	}

	body.bind('RedrawSearchResults', function(ev, obj) {
		if (!obj || !obj.hits || !obj.facets || !obj.query) {
			window.console.log("error redrawing search results", obj);
			return;
		}

		var html = "";
		for (var i = 0; i < obj.hits.length; i++) {
			var isCollected = obj.collected[obj.hits[i].uri] !== undefined;
			html += createMediaBlock(obj.hits[i], i, isCollected, obj.collected[obj.hits[i].uri]);
		}
		$('.search-results').html(html);

		createFacetBlock('facet-genre', obj.facets.genre, 'g', obj.query.g);
		createFacetBlock('facet-discipline', obj.facets.discipline, 'discipline', obj.query.discipline);
		createFacetBlock('facet-format', obj.facets.doc_type, 'doc_type', obj.query.doc_type);
		createFacetBlock('facet-access', obj.facets.access, 'o', obj.query.o, window.collex.facetNames.access);
		createResourceBlock(obj.facets.archive);

		var page = obj.query.page ? obj.query.page : 1;
		html = createPagination(page, obj.total_hits, obj.page_size);
		$('.pagination').html(html);

		createTotals(obj.total_hits);
		setFederations(obj.facets.federation, obj.query.f);
	});
});
