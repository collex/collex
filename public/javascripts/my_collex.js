// ------------------------------------------------------------------------
//     Copyright 2009 Applied Research in Patacriticism and the University of Virginia
// 
//     Licensed under the Apache License, Version 2.0 (the "License");
//     you may not use this file except in compliance with the License.
//     You may obtain a copy of the License at
// 
//         http://www.apache.org/licenses/LICENSE-2.0
// 
//     Unless required by applicable law or agreed to in writing, software
//     distributed under the License is distributed on an "AS IS" BASIS,
//     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//     See the License for the specific language governing permissions and
//     limitations under the License.
// ----------------------------------------------------------------------------

/*global $, $$, $H, Element */
/*global ConfirmDlg, doSingleInputPrompt */
/*global document */
/*extern editTag, removeTag, toggleElementsByClass */

// Used by Exhibited Objects
function toggleElementsByClass(cls)
{
	var els = $$('.'+cls);
	els.each(function(el){ el.toggle(); });
}

function editTag(parent_id, tag_name)
{
	doSingleInputPrompt("Edit Tag", 'Tag:', 'new_name', parent_id,
		"",
		"/results/edit_tag",
		$H({ old_name: tag_name, new_name: tag_name }), 'text', null, null );
}

function removeTag(parent_id, tag_name)
{
	var remove = function()
	{
		var new_form = new Element('form', { id: "remove_tag", method: 'post', onsubmit: "this.submit();", action: "/results/remove_all_tags" });
		new_form.observe('submit', "this.submit();");
		document.body.appendChild(new_form);
		new_form.appendChild(new Element('input', { name: 'tag', value: tag_name, id: 'tag' }));

		$(parent_id).appendChild(new Element('img', { src: "/images/ajax_loader.gif", alt: ''}));
		new_form.submit();
	};
	new ConfirmDlg("Remove Tag", "Are you sure you want to remove all instances of the \"" + tag_name + "\" tag that you created?", "Yes", "No", remove);
}



