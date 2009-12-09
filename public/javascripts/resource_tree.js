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

/*global $, $$, Class, Ajax */
/*extern ResourceTree */

var ResourceTree = Class.create({
	initialize: function (id, action) {
		if (action === 'toggle') {
			var open = $("site_opened_" + id);
			if (open.hasClassName('hidden')) action = 'close';
			else action = 'open';
		}

		var getId = function(node) {
			var arr = node.split('_');
			id = arr[arr.length-1];
			return id;
		};

		var closeChildren = function(node) {
			// this recursively hides all the children of the specified node.
			var child_class = "child_of_" + node;
			var children = $$('.' + child_class);
			children.each(function(child)
			{
				child.addClassName('hidden');
				if (child.hasClassName('resource_node')) {
					var cid = getId(child.id);
					closeChildren(cid);
				}
			});
		};

		var openChildren = function(node) {
			var child_class = "child_of_" + node;
			var children = $$('.' + child_class);
			children.each(function(child) {
				child.removeClassName('hidden');
				if (child.hasClassName('resource_node')) {
					var cid = getId(child.id);
					var childOpened = $("site_opened_" + cid);
					if (childOpened.hasClassName('hidden') === true)
						openChildren(cid);
				}
			});
		};

		var closeNode = function(id) {
			var This = $("site_closed_" + id);
			var That = $("site_opened_" + id);
			This.addClassName('hidden');
			That.removeClassName('hidden');
			new Ajax.Request("/search/remember_resource_toggle", {
				parameters: { dir: 'close', id: id}
			});
		};

		var openNode = function(id) {
			var This = $("site_opened_" + id);
			var That = $("site_closed_" + id);
			This.addClassName('hidden');
			That.removeClassName('hidden');
			new Ajax.Request("/search/remember_resource_toggle", {
				parameters: { dir: 'open', id: id}
			});
		};

		if (action === 'open') {
			openNode(id);
			openChildren(id);
		} else if (action === 'close') {
			closeNode(id);
			closeChildren(id);
		}
	}
});
