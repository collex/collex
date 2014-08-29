jQuery(document).ready(function() {
	"use strict";

	window.collex.getArchive = function(handle) {
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
	};

	window.collex.getSite = function(archive) {
		var resource = window.collex.getArchive(archive);
		if (resource)
			return window.pss.createHtmlTag("a", { 'class': 'nines_link', target: '_blank', href: resource.site_url  }, resource.name);
		else
			return archive;
	};

	window.collex.getArchiveNode = function(id) {
		id = parseInt(id, 10);
		function getArchiveOneBranch(branch, id) {
			for (var i = 0; i < branch.length; i++) {
				var archive = branch[i];
				if (archive.id === id)
					return archive;
				if (archive.children) {
					var a = getArchiveOneBranch(archive.children, id);
					if (a)
						return a;
				}
			}
			return null;
		}
		return getArchiveOneBranch(window.collex.facetNames.archives, id);
	};
});
