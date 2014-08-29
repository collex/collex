jQuery(document).ready(function($) {
	"use strict";
	var body = $("body");

	window.collex.create_facet_button = function(label, value, action, key) {
		return window.pss.createHtmlTag("button", { 'class': 'select-facet nav_link', 'data-action': action, 'data-key': key, 'data-value': value }, label);
	};

	window.collex.number_with_delimiter = function(number) {
		var delimiter = ',';
		var separator = '.';
		var parts = (""+number).split('.');
		parts[0] = parts[0].replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1" + delimiter);
		return parts.join(separator);
	};

	function createFacetRow(name, count, dataKey, isSelected, label) {
		if (!label) label = name;
		if (isSelected) {
			var remove = window.collex.create_facet_button('[X]', name, "remove", dataKey);
			return window.pss.createHtmlTag("tr", { 'class': "limit_to_selected" },
				window.pss.createHtmlTag("td", { 'class': "limit_to_lvl1" }, label + "&nbsp;&nbsp;" + remove) +
				window.pss.createHtmlTag("td", { 'class': "num_objects" }, window.collex.number_with_delimiter(count)));
		} else {
			var button = window.collex.create_facet_button(label, name, "add", dataKey);
			return window.pss.createHtmlTag("tr", {},
				window.pss.createHtmlTag("td", { 'class': "limit_to_lvl1" }, button) +
				window.pss.createHtmlTag("td", { 'class': "num_objects" }, window.collex.number_with_delimiter(count)));
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
		var right = window.pss.createHtmlTag("td", { 'class': 'num_objects' }, window.collex.number_with_delimiter(total));
		var trClass = "resource_node " + childClass;
		return window.pss.createHtmlTag("tr", { id: 'resource_'+id, 'class': trClass }, left+right);
	}

	function createResourceLeaf(id, level, label, total, handle, childClass, isSelected) {
		var trClass = childClass;
		var left;
		if (isSelected) {
			trClass += ' limit_to_selected';
			left = window.pss.createHtmlTag("td", { 'class': 'limit_to_lvl'+level }, label + '&nbsp;&nbsp;' + window.collex.create_facet_button('[X]', handle, 'remove', 'a'));
		} else {
			left = window.pss.createHtmlTag("td", { 'class': 'limit_to_lvl'+level }, window.collex.create_facet_button(label, handle, 'replace', 'a'));
		}
		var right = window.pss.createHtmlTag("td", { 'class': 'num_objects' }, window.collex.number_with_delimiter(total));
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
					var thisNode = createResourceNode(archive.id, level, archive.name, window.collex.number_with_delimiter(section.total), childClass);
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

	window.collex.createFacets = function(obj) {
		createFacetBlock('facet-genre', obj.facets.genre, 'g', obj.query.g);
		createFacetBlock('facet-discipline', obj.facets.discipline, 'discipline', obj.query.discipline);
		createFacetBlock('facet-format', obj.facets.doc_type, 'doc_type', obj.query.doc_type);
		createFacetBlock('facet-access', obj.facets.access, 'o', obj.query.o, window.collex.facetNames.access);
		createResourceBlock(obj.facets.archive, obj.query.a);
	};
});
