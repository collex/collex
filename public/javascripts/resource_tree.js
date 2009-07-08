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

/*global $, $$ */
/*extern close_tree, open_tree, toggle_tree */

// For the resources on the search page (also used in the administrator to modify the resources)
function open_tree(event, id)
{
	var This = $("site_opened_" + id);
	var That = $("site_closed_" + id);
	This.addClassName('hidden');
	That.removeClassName('hidden');
	var child_class = "child_of_" + id;
	var children = $$('.' + child_class);
	children.each(function(child) { child.removeClassName('hidden'); });
}

function close_tree(event, id)
{
	var This = $("site_closed_" + id);
	var That = $("site_opened_" + id);
	This.addClassName('hidden');
	That.removeClassName('hidden');
	var child_class = "child_of_" + id;
	var children = $$('.' + child_class);
	children.each(function(child) { child.addClassName('hidden'); });
}

function toggle_tree(event, id)
{
	var open = $("site_opened_" + id);
	if (open.hasClassName('hidden'))
		close_tree(event, id);
	else
		open_tree(event, id);
}
