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
			check = window.pss.createHtmlTag("input", { 'type': 'checkbox', 'id': "bulk_collect_"+index, 'name': "bulk_collect["+index+"]", 'value': hit.uri });
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

	function createBlankResultContentItem(klass) {
		return window.pss.createHtmlTag("div", { 'class': klass, style: 'display:none;' },
			window.pss.createHtmlTag("span", { 'class': 'label' }, '') +
			window.pss.createHtmlTag("span", { 'class': 'value' }, ''));
	}

	function fillInRow(row, label, value) {
		row.find('.label').html(label);
		row.find('.value').html(value);
	}

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
			html += window.pss.createHtmlTag("a", { 'class': 'tag_link my_tag', title: "view all objects tagged &quot;" + tags[i] + "&quot;", href: '/tags/results?tag=' + tags[i] + '&amp;view=tag' }, tags[i]);
			var remove = "doRemoveTag('" + uri + "', 'search_result_" + index + "', '" + tags[i] + "'); return false;";
			html += window.pss.createHtmlTag("a", { 'class': 'modify_link my_tag remove_tag', title: "delete tag &quot;" + tags[i] + "&quot;", onclick: remove,  href: '#' }, 'X');
		}
		return html;
	}

	function createTagLine(uri, index, tags) {
		var click = "doAddTag('/tag/tag_name_autocomplete', '" + uri + "', " + index + ", 'search_result_" + index + "', event); return false;";
		return formatTags(uri, index, tags) + window.pss.createHtmlTag("button", { 'class': 'modify_link', id: "add_tag_"+index, onclick: click }, "[add&nbsp;tag]");
	}

	function createAnnotationBody(index, uri, text) {
		var doAnnotation = "doAnnotation('" + uri + "', " + index + ", 'search_result_" + index + "', 'annotation_" + index + "', '/forum/get_nines_obj_list', '" +
			window.collex.images.spinner + "'); return false;";
		var linkLabel;
		var currentAnnotation = "<br>" + window.pss.createHtmlTag("span", { id: 'annotation_' + index, 'class': 'annotation' }, text);
		if (text && text.length > 0) {
			linkLabel = "Edit Private Annotation";
		} else
			linkLabel = "Add Private Annotation";

		return window.pss.createHtmlTag("button", { 'class': 'modify_link', onclick: doAnnotation }, linkLabel)+currentAnnotation;
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

	function formatExhibit(exhibit) {
		var html = exhibit.title + "&nbsp;" + window.pss.createHtmlTag("a", { 'class': 'nav_link', href: exhibit.view_path }, "[view]");
		if (exhibit.edit_path && exhibit.edit_path.length > 0)
			html += "&nbsp;" + window.pss.createHtmlTag("a", { 'class': 'nav_link', href: exhibit.edit_path }, "[edit]");
		return html;
	}

	function createResultContents(obj, index, collectedDate) {
		needShowMoreLink = false;
		var html = "";
		html += createResultContentItem('one_col', '', obj.alternative, false);
		html += createResultContentItem('separate_lines', 'Source:', obj.source, false);
		html += createResultContentItem('multiple_item', 'By:', obj.role_AUT, false);
		html += createResultContentItem('multiple_item', 'Artist:', obj.role_ART, false);
		if (collectedDate)
			html += createResultContentItem('single_item', 'Collected&nbsp;on:', formatDate(collectedDate), false, 'collected-on');
		else
			html += createBlankResultContentItem('row collected-on');

		var tags = createTagLine(obj.uri, index, obj.tags);
		html += createResultContentItem('single_item', 'Tags:', tags, false, 'tag-list');

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
		var exhibits;
		if (obj.exhibits) {
			exhibits = [];
			for (var i = 0; i < obj.exhibits.length; i++) {
				exhibits.push(formatExhibit(obj.exhibits[i]));
			}
		}
		if (exhibits)
			html += createResultContentItem('multiple_item', 'Exhibits:', exhibits, true, 'exhibits-row');
		else
			html += createBlankResultContentItem('row exhibits-row');

		if (needShowMoreLink) {
			html += window.pss.createHtmlTag("button", { id: "more-search_result_"+index,  'class': 'nav_link more', onclick: 'removeHidden("more-search_result_' + index + '", "search_result_' + index + '");return false;'}, '[more...]');
		}

		var annotation = createAnnotationBody(index, obj.uri, obj.annotation);
		var annotationOptions = { 'class': 'row annotation-row' };
		if (!collectedDate)
			annotationOptions.style = "display:none;";

		html += window.pss.createHtmlTag("div", annotationOptions, annotation);

		html += createFullTextExcerpt(obj.text);
		return window.pss.createHtmlTag("div", { 'class': 'search_result_data_container', 'data-uri': obj.uri }, html);
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

	window.collex.setCollected = function(index, collectedDate) {
		var el = $("#search_result_"+index);
		if (el.length) {
			el.addClass('result_row_collected');
			var actionButtons = createActionButtons({}, true); // TODO-PER: the empty has should actually include { typewright: true } if it is typewrightable.
			el.find(".search_result_buttons").html(actionButtons);
			var collectedOn = el.find('.collected-on');
			fillInRow(collectedOn, 'Collected&nbsp;on:', formatDate(collectedDate));
			el.find('.collected-on').show();
			el.find(".annotation-row").show();
		}
	};

	window.collex.setUncollected = function(index) {
		var el = $("#search_result_"+index);
		if (el.length) {
			el.removeClass('result_row_collected');
			var actionButtons = createActionButtons({}, false); // TODO-PER: the empty has should actually include { typewright: true } if it is typewrightable.
			el.find(".search_result_buttons").html(actionButtons);
			el.find('.collected-on').hide();
			var annotation = el.find(".annotation-row");
			annotation.find("button").text("Add Private Annotation");
			annotation.find(".annotation").text('');
			annotation.hide();
		}
	};

	window.collex.redrawTags = function(index, myTags, otherTags) {
		var el = $("#search_result_"+index);
		if (el.length) {
			var value = el.find('.tag-list .value');
			var container = el.closest(".search_result_data_container");
			var uri = container.attr("data-uri");
			var tags = createTagLine(uri, index, myTags);
			value.html(tags);
		}
	};

	window.collex.redrawAnnotation = function(index, text) {
		var el = $("#search_result_"+index);
		if (el.length) {
			var value = el.find('.annotation-row');
			var container = el.closest(".search_result_data_container");
			var uri = container.attr("data-uri");
			var annotation = createAnnotationBody(index, uri, text);
			value.html(annotation);
		}
	};

	window.collex.redrawExhibits = function(index, exhibits) {
		var el = $("#search_result_"+index);
		if (el.length) {
			var row = el.find('.exhibits-row');
			var container = el.closest(".search_result_data_container");
			var uri = container.attr("data-uri");
			var output = [];
			if (exhibits) {
				for (var i = 0; i < exhibits.length; i++) {
					output.push(formatExhibit(exhibits[i]));
				}
				row.find(".value").html(output.join("<br>"));
				row.find(".label").html("Exhibits:");
				row.show();
			} else
				row.hide();
		}
	};

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
		var open = window.pss.createHtmlTag("button", { 'class': 'nav_link  limit_to_arrow', 'data-action': "open" },
			window.pss.createHtmlTag("img", { 'alt': 'Arrow Open', src: window.collex.images.arrow_open }));
		var close = window.pss.createHtmlTag("button", { 'class': 'nav_link  limit_to_arrow', 'data-action': "close" },
			window.pss.createHtmlTag("img", { 'alt': 'Arrow Close', src: window.collex.images.arrow_close }));
		var name = window.pss.createHtmlTag("button", { 'class': 'nav_link limit_to_category', 'data-action': "toggle" }, label);

		var left = window.pss.createHtmlTag("td", { 'class': 'resource-tree-node limit_to_lvl'+level, 'data-id': id }, open+close+name);
		var right = window.pss.createHtmlTag("td", { 'class': 'num_objects' }, number_with_delimiter(total));
		var trClass = "resource_node " + childClass;
		return window.pss.createHtmlTag("tr", { id: 'resource_'+id, 'class': trClass }, left+right);
	}

	function createResourceLeaf(id, level, label, total, handle, childClass, isSelected) {
		var trClass = childClass;
		var left;
		if (isSelected) {
			trClass += ' limit_to_selected';
			left = window.pss.createHtmlTag("td", { 'class': 'limit_to_lvl'+level }, label + '&nbsp;&nbsp;' + create_facet_button('[X]', handle, 'remove', 'a'));
		} else {
			left = window.pss.createHtmlTag("td", { 'class': 'limit_to_lvl'+level }, create_facet_button(label, handle, 'replace', 'a'));
		}
		var right = window.pss.createHtmlTag("td", { 'class': 'num_objects' }, number_with_delimiter(total));
		return window.pss.createHtmlTag("tr", { id: 'resource_'+id, 'class': trClass }, left+right);
	}

	function createResourceSection(resources, hash, level, childClass, handleOfSelected) {
		var html = "";
		var total = 0;
		for (var i = 0; i < resources.length; i++) {
			var archive = resources[i];
			if (archive.children) {
				var section = createResourceSection(archive.children, hash, level + 1, childClass + ' child_of_'+archive.id, handleOfSelected);
				total += section.total;
				if (section.total > 0) {
					var thisNode = createResourceNode(archive.id, level, archive.name, number_with_delimiter(section.total), childClass);
					html += thisNode + section.html;
				}
			} else {
				if (hash[archive.handle]) { // If there are no results, then we don't show that archive.
					html += createResourceLeaf(archive.id, level, archive.name, hash[archive.handle], archive.handle, childClass, archive.handle === handleOfSelected);
					total += parseInt(hash[archive.handle], 10);
				}
			}
		}
		return { html: html, total: total };
	}

	function setResourceToggle(block, resources) {
		for (var i = 0; i < resources.length; i++) {
			var archive = resources[i];
			if (archive.children) {
				if (archive.toggle === 'open') {
					block.find("#resource_" + archive.id + ' button[data-action="open"]').hide();
				} else {
					block.find("#resource_" + archive.id + ' button[data-action="close"]').hide();
					block.find('.child_of_'+archive.id).hide();
				}
				setResourceToggle(block, archive.children);
			}
		}
	}

	function createResourceBlock(hash, handleOfSelected) {

		var html = createResourceSection(window.collex.facetNames.archives, hash, 1, '', handleOfSelected).html;

		var block = $(".facet-archive");
		var header = window.pss.createHtmlTag("tr", {}, block.find("tr:first-of-type").html());
		block.html(header + html);
		// Now close the items that need to be closed.
		setResourceToggle(block, window.collex.facetNames.archives);
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

	function searchFormType(key) {
		var types = {
			a: 'Archive',
			discipline: 'Discipline',
			g: 'Genre',
			q: 'Search Term',
			doc_type: 'Format',
			t: "Title",
			aut: "Author",
			ed: 'Editor',
			pub: "Publisher",
			art: 'Artist',
			own: 'Owner',
			y: 'Year',
			lang: 'Language'
		};
		if (types[key])
			return types[key];
		return key;
	}

	function searchNot() {
		return '<select class="query_and-not_select"><option>AND</option><option>NOT</option></select>';
	}

	function searchRemove(key, value) {
		return window.pss.createHtmlTag("button", {'class': "trash select-facet", 'data-key': key, 'data-value': value, 'data-action': 'remove' }, '<img alt="Remove Term" src="/assets/lvl2_trash.gif">' );

	}

	function newSearchTerm() {
		var searchTypes = [ ['Search Term', 'q'], ['Title', 't'] ];
		if (window.collex.hasFuzzySearch) {
			searchTypes.push(['Language', 'lang']);
			searchTypes.push(['Year (YYYY)', 'y']);
			// TODO-PER: get the roles that are in the facets.
		} else {
			searchTypes.push(['Author', 'aut']);
			searchTypes.push(['Editor', 'ed']);
			searchTypes.push(['Publisher', 'pub']);
			searchTypes.push(['Artist', 'art']);
			searchTypes.push(['Owner', 'own']);
			searchTypes.push(['Year (YYYY)', 'y']);
		}
		var selectTypeOptions = "";
		for (var i = 0; i < searchTypes.length; i++)
			selectTypeOptions += window.pss.createHtmlTag("option", {value: searchTypes[i][1] }, searchTypes[i][0]);
		var selectType = window.pss.createHtmlTag("select", {'class': "query_type_select" }, selectTypeOptions); // TODO-PER: onchange='searchTypeChanged(this);'
		var searchBox = window.pss.createHtmlTag("input", { type: 'text', placeholder: "click here to add new search term", autocomplete: 'off' }) +
			window.pss.createHtmlTag("div", {'class': "auto_complete", id: "search_phrase_auto_complete", style: "display: none;" }, '');
		var submitButton = window.pss.createHtmlTag("button", { 'class': "query_add" }, 'Add');
		return window.pss.createHtmlTag("tr", { },
			window.pss.createHtmlTag("td", {'class': "query_type" }, selectType) +
			window.pss.createHtmlTag("td", {'class': "query_term" }, searchBox) +
			window.pss.createHtmlTag("td", {'class': "query_and-not" }, searchNot()) +
			window.pss.createHtmlTag("td", { 'class': "query_remove" }, submitButton) );
	}

	function createSearchForm(query) {
		var table = $('.search-form');
		var html = "";
		for (var key in query) {
			if (query.hasOwnProperty(key) && key !== 'page' && key !== 'srt' && key !== 'dir') {
				var values = (typeof query[key] === 'string') ? [ query[key] ] : query[key];
				for (var i = 0; i < values.length; i++) {
					var value = values[i];
					var displayedKey = key;
					if (key === 'a') {
						var a = getArchive(value);
						if (a) value = a.name;
					} else if (key === 'o') {
						switch (value) {
							case 'typewright': displayedKey = 'TypeWright'; value = 'Only resources that can be edited.'; break;
							case 'freeculture': displayedKey = 'Free Culture'; value = 'Only resources that are freely available in their full form.'; break;
							case 'fulltext': displayedKey = 'Full Text'; value = 'Only resources that contain full text.'; break;
						}
					}
					html += window.pss.createHtmlTag("tr", {},
						window.pss.createHtmlTag("td", {'class': "query_type"}, searchFormType(displayedKey)) +
						window.pss.createHtmlTag("td", {'class': "query_term"}, value) +
						window.pss.createHtmlTag("td", {'class': "query_and-not"}, searchNot()) +
						window.pss.createHtmlTag("td", {'class': "query_remove"}, searchRemove(key, values[i])));
				}
			}
		}
		html += newSearchTerm();
		return table.html(html);
	}

	function isEmptyObject(obj) {
		for (var key in obj) {
			if (obj.hasOwnProperty(key)) {
				return false;
			}
		}
		return true;
	}

	function showResultSections(obj) {
		if (isEmptyObject(obj.query)) {
			// this is a blank page, with no search.
			$(".has-results").hide();
			$(".add_constraint_form").show();
		} else {
			$(".add_constraint_form").hide();
			$(".has-results").show();
			if (obj.hits.length === 0) {
				// there was a search, but there were no results.
				$(".not-empty").hide();
				$(".no_results_msg").show();
			} else {
				// there was a search, and it returned some results.
				$(".not-empty").show();
				$(".no_results_msg").hide();
			}
		}
	}

	function showMessage(message) {
		var el = $(".search_error_message");
		el.text(message);
		if (message && message.length > 0)
			el.show();
		else
			el.hide();
	}

	function fixExpandAllLink() {
		$("#expand_all").show();
		$("#collapse_all").hide();
	}

	// has-results add_constraint_form not-empty no_results_msg
	body.bind('RedrawSearchResults', function(ev, obj) {
		if (!obj || !obj.hits || !obj.facets || !obj.query) {
			window.console.log("error redrawing search results", obj);
			return;
		}

		showResultSections(obj);
		showMessage(obj.message);

		var html = "";
		for (var i = 0; i < obj.hits.length; i++) {
			var isCollected = obj.collected[obj.hits[i].uri] !== undefined;
			html += createMediaBlock(obj.hits[i], i, isCollected, obj.collected[obj.hits[i].uri]);
		}
		$('.search-results').html(html);

		createSearchForm(obj.query);
		createFacetBlock('facet-genre', obj.facets.genre, 'g', obj.query.g);
		createFacetBlock('facet-discipline', obj.facets.discipline, 'discipline', obj.query.discipline);
		createFacetBlock('facet-format', obj.facets.doc_type, 'doc_type', obj.query.doc_type);
		createFacetBlock('facet-access', obj.facets.access, 'o', obj.query.o, window.collex.facetNames.access);
		createResourceBlock(obj.facets.archive, obj.query.a);

		var page = obj.query.page ? obj.query.page : 1;
		html = createPagination(page, obj.total_hits, obj.page_size);
		$('.pagination').html(html);

		createTotals(obj.total_hits);
		setFederations(obj.facets.federation, obj.query.f);
		fixExpandAllLink();
	});
});
