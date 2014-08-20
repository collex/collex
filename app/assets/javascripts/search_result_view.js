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

	function createImageBlock() {
/*
// TODO-PER: do logged in version
 <% if user_signed_in? -%>
 <div class="search_result_left_logged_in">
 <table><tr>
 <td><input type="checkbox" id="bulk_collect_<%=index%>" name="bulk_collect[<%=index%>]" value="<%=hit['uri']%>" /></td>
 <td><div class="search_result_image">
 <%= render :partial => '/results/thumbnail_image', :locals => { :hit => hit } %>
 </div></td>
 </tr>

 </table>
 </div>
 <% else -%>
 <div class="search_result_left">
 <%= render :partial => '/results/thumbnail_image', :locals => { :hit => hit } %>
 </div>
 <% end -%>

 <%# thumbnail_image params: (hash hit) -%>
 <div class="search_result_image"><%= thumbnail_image_tag(hit) %>
 <% if hit['freeculture'] == 'true' || hit['has_full_text'] == 'true'  || hit['source_xml'] != nil -%>
 <div class="result_row_icons">
 <% if hit['freeculture'] == 'true' -%>
 <span class="tooltip free_culture">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="result_row_tooltip">Free Culture resource</span></span>
 <% end -%>
 <% if hit['has_full_text'] == 'true' -%>
 <span class="tooltip full_text">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="result_row_tooltip">Full text provided for this document</span></span>
 <% end -%>
 <% if hit['source_xml'] != nil -%>
 <span class="tooltip has_xml_source">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="result_row_tooltip">XML source available for this document</span></span>
 <% end -%>
 <% if COLLEX_PLUGINS['typewright'] && !hit['typewright'].blank? -%>
 <span class="tooltip can_typewright" data-uri="<%= hit['uri'] %>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="result_row_tooltip">This document can be corrected using TypeWright</span></span>
 <% end -%>
 </div>
 <% end -%>
 </div>

 def thumbnail_image_tag(hit, options = {})
 thumb = CachedResource.get_thumbnail_from_hit(hit)
 image = CachedResource.get_image_from_hit(hit)
 progress_id = "progress_#{make_id(hit['uri'])}"
 title = hit['title'] ? hit['title'] : "Image"
 str = tag "img", options.merge({:alt => title, :src => get_image_url(thumb), :id => "thumbnail_#{make_id(hit['uri'])}", :class => 'result_row_img hidden', :onload => "finishedLoadingImage('#{progress_id}', this, 100, 100);" })
 if image != thumb
 title = title[0,60]+'...' if title.length > 62
 title = title.gsub("'", "&apos;")
 title = title.gsub('"', "\\\"")
 str = "<a class='nines_pic_link' onclick='showInLightbox({ title: \"#{title}\", img: \"#{image}\", spinner: \"#{image_path(PROGRESS_SPINNER_PATH)}\", size: 500 }); return false;' href='#'>#{str}</a>"
 end
 str = "<img id='#{progress_id}' class='progress_timeout result_row_img_progress' src='#{image_path(PROGRESS_SPINNER_PATH)}' alt='loading...' data-noimage='#{image_path(SPINNER_TIMEOUT_PATH)}' />\n" + str
 return raw(str)
 end

*/
//		<div class="search_result_left_logged_in">
//			<table><tbody><tr>
//				<td><input type="checkbox" id="bulk_collect_0" name="bulk_collect[0]" value="http://petrusplaoul.org/text/uri/sorb/lectio75"></td>
//					<td><div class="search_result_image">
//						<div class="search_result_image"><img id="progress_http-__petrusplaoul-org_text_uri_sorb_lectio75" class="progress_timeout result_row_img_progress" src="/assets/18th/no_image.jpg" alt="loading..." data-noimage="/assets/18th/no_image.jpg">
//							<img alt="Lectio 75, de Trinitate [Sorbonne Transcription]" class="result_row_img hidden" id="thumbnail_http-__petrusplaoul-org_text_uri_sorb_lectio75" onload="finishedLoadingImage('progress_http-__petrusplaoul-org_text_uri_sorb_lectio75', this, 100, 100);" src="http://petrusplaoul.org/plaoulCover.jpg">
//								<div class="result_row_icons">
//									<span class="tooltip free_culture">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="result_row_tooltip">Free Culture resource</span></span>
//									<span class="tooltip full_text">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="result_row_tooltip">Full text provided for this document</span></span>
//									<span class="tooltip has_xml_source">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="result_row_tooltip">XML source available for this document</span></span>
//								</div>
//							</div>
//
//						</div></td>
//					</tr>
//
//					</tbody></table>
//			</div>
		return window.pss.createHtmlTag("div", { 'class': 'search_result_left' }, "");
	}

	function createActionButtons(hit, isCollected) {
		var collect = isCollected ? '' : window.pss.createHtmlTag("button", { 'class': 'collect' }, "Collect");
		var uncollect = isCollected ? window.pss.createHtmlTag("button", { 'class': 'uncollect' }, "Uncollect") : '';
		var discuss = window.pss.createHtmlTag("button", { 'class': 'discuss' }, "Discuss");
		var exhibit = isCollected ? window.pss.createHtmlTag("button", { 'class': 'exhibit' }, "Exhibit") : '';
		var typewright = window.collex.hasTypewright && hit.typewright ? window.pss.createHtmlTag("button", { 'class': 'edit' }, "Edit") : '';
		return window.pss.createHtmlTag("div", { 'class': 'search_result_buttons' }, collect+uncollect+discuss+exhibit+typewright);
	}

	function createResultHeader(obj) {
//		<div class="search_result_header">
		// TODO-PER:handle admin link
//			<a class="uri_link" href="#" onclick="$('uri_0').toggleClassName('hidden');; return false;">uri</a><span id="uri_0" class="hidden">&nbsp;http://petrusplaoul.org/text/uri/sorb/lectio75</span>
		// TODO-PER: handle zotera
		//		<% aut = hit['role_AUT'] == nil ? '' : hit['role_AUT'][0] -%>
		//				<% pub = hit['role_PBL'] == nil ? '' : hit['role_PBL'][0] -%>
		//				<% dat = hit['date_label'] == nil ? '' : hit['date_label'][0] -%>
		//				<% esc_title = CGI::escape(title.gsub('&quot;', '"').gsub('&amp;', '&')) %>
		//			<span class="Z3988"
		//			title="ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook&amp;rft_id=<%= CGI::escape(url) %>&amp;rfr_id=info%3Asid%2Focoins.info%3Agenerator&amp;rft.genre=book&amp;rft.btitle=<%= esc_title %>&amp;rft.title=<%= esc_title %>&amp;rft.aulast=<%= CGI::escape(aut) %>&amp;rft.aufirst=&amp;rft.au=<%= CGI::escape(aut) %>&amp;rft.date=<%= CGI::escape(dat) %>&amp;rft.pub=<%= CGI::escape(pub) %>">
		//				<%= result_row_title(title, url, index) %>

		// TODO-PER: handle case where the title is longer than 200 chars
//				<a class="nines_link" href="http://petrusplaoul.org/text/textdisplay.php?fs=lectio75&amp;ms=sorb" target="_blank" title=" ">Lectio 75, de Trinitate [Sorbonne Transcription]</a>
//			</span>
//		</div>

		var a = window.pss.createHtmlTag("a", { 'class': 'nines_link doc-title', 'href': obj.url, target: '_blank', title: ' ' }, obj.title);

		return window.pss.createHtmlTag("div", { 'class': 'search_result_header' }, a);
	}

	var needShowMoreLink = false;

	function createResultContentItem(type, label, value, startHidden) {
		if (!value)
			return "";

		var klass = "row";
		if (startHidden) {
			klass += ' hidden';
			needShowMoreLink = true;
		}

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
			case 'site':
				// TODO-PER: create site link
				//					this_site = site(archive)
				//				if this_site
				//					str = "<a class='nines_link' target='_blank' href='#{this_site['site_url']}'>#{this_site['name']}</a>"
				//				else
				//					str = archive
				//				end
				return window.pss.createHtmlTag("div", { 'class': klass },
						window.pss.createHtmlTag("span", { 'class': 'label' }, label) +
						window.pss.createHtmlTag("span", { 'class': 'value' }, value));
	case "alternative":
				// TODO-PER: implement alternative.
//hit[key].each do |alt|
//rows.push({:hidden => is_hidden, :one_col => true, :value => h(alt)})
//end
				return "";
		}
	}

	function createFullTextExcerpt(text) {
		if (!text || text.length === 0) return "";
		return window.pss.createHtmlTag("div", { 'class': 'search_result_full_text_label' }, 'Excerpt from Full Text:') +
			window.pss.createHtmlTag("span", { 'class': 'snippet' }, text);
	}

	function createResultContents(obj, index) {
		needShowMoreLink = false;
		var html = "";
		html += createResultContentItem('alternative', 'Alternative:', obj.alternative, false);
		html += createResultContentItem('separate_lines', 'Source:', obj.source, false);
		html += createResultContentItem('multiple_item', 'By:', obj.role_AUT, false);
		html += createResultContentItem('multiple_item', 'Artist:', obj.role_ART, false);
//<%################### -%>
		// TODO-PER: do collected
		//<% item = get_collected_item(hit) -%>
		//<% is_collected = !item.nil?  -%>
//<%  result_row_collected(rows, is_collected, item) %>
//<%################### -%>
		// TODO-PER: do tags
		//<% tags = Tag.get_tags_for_uri(hit['uri']) -%>
//<% if no_links -%>
//<% result_row_tags_no_links(rows, "Tags:", tags) -%>
//<% else # if we want links on the tags -%>
//<% result_row_tags_links(rows, index, row_id, hit, "Tags:", tags, item, user_signed_in?, is_collected) %>
//<% end # if no_links -%>
//<%################### -%>
		html += createResultContentItem('single_item', 'Site:', obj.archive, false);
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
			// TODO-PER: clean up "more" link so that it is non-obtrusive and uses jQuery, and doesn't need to have an id passed.
			html += window.pss.createHtmlTag("button", { id: "more-search_result_"+index,  'class': 'nav_link more', onclick: 'removeHidden("more-search_result_' + index + '", "search_result_' + index + '");return false;'}, '[more...]');
		}

		html += createFullTextExcerpt(obj.text);
		return window.pss.createHtmlTag("div", { 'class': 'search_result_data_container' }, html);
	}

	function createMediaBlock(obj, index, isCollected) {
		var imageBlock = createImageBlock();
		var actionButtons = createActionButtons(obj, isCollected);
		var resultHeader = createResultHeader(obj);
		var resultContents = createResultContents(obj, index);
		var results = window.pss.createHtmlTag("div", { 'class': 'search_result_right' }, resultHeader+resultContents);
		var html = window.pss.createHtmlTag("div", { 'class': 'clear_both' }, "") +
			window.pss.createHtmlTag("hr", { 'class': 'search_results_hr' });
		html += window.pss.createHtmlTag("div", { 'id': 'search_result_'+ index, 'class': 'search-result', 'data-index': index, 'data-uri': obj.uri }, imageBlock+actionButtons+results);
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
			var isCollected = $.inArray(obj.hits[i].uri, obj.collected) !== -1;
			html += createMediaBlock(obj.hits[i], i, isCollected);
		}
		$('.search-results').html(html);

		createFacetBlock('facet-genre', obj.facets.genre, 'g', obj.query.g);
		createFacetBlock('facet-discipline', obj.facets.discipline, 'discipline', obj.query.discipline);
		createFacetBlock('facet-format', obj.facets.doc_type, 'doc_type', obj.query.doc_type);
		createFacetBlock('facet-access', obj.facets.access, 'o', obj.query.o, window.collex.facetNames.access);

		var page = obj.query.page ? obj.query.page : 1;
		html = createPagination(page, obj.total_hits, obj.page_size);
		$('.pagination').html(html);

		createTotals(obj.total_hits);
		setFederations(obj.facets.federation, obj.query.f);
	});
});
