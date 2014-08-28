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

/*global serverNotify */

jQuery(document).ready(function($) {
	"use strict";
	var body = $("body");

	function getArchiveNode(id) {
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
	}

	body.on("click", ".resource-tree-node button", function () {
		var el = $(this);
		var parent = el.closest(".resource-tree-node");
		var open = parent.find('button[data-action="open"]');
		var close = parent.find('button[data-action="close"]');
		var action = el.attr('data-action');
		var id = parent.attr('data-id');
		if (action === 'toggle') {
			action = open.is(':visible') ? 'open' : 'close';
		}
		var child_class = ".child_of_" + id;
		if (action === 'open') {
			open.hide();
			close.show();
			$(child_class).show();
		} else {
			open.show();
			close.hide();
			$(child_class).hide();
		}
		var archive = getArchiveNode(id);
		if (archive)
			archive.toggle = action;

		serverNotify("/search/remember_resource_toggle", { dir: action, id: id });

	});
});
