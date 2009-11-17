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

/*global $H */
/*global doSingleInputPrompt */
/*extern showString */

function showString(parent_id, str)
{
	doSingleInputPrompt("Copy and Paste link into E-mail or IM", 'Link:', 'show_save_name', parent_id,
		null,
		null,
		$H( { show_save_name: str } ), 'text', $H( { width: 70 } ), "Ok" );
}

function showHiddenSavedSearches(class_of_button, class_of_hidden_items)
{
	var cntl = $$('.' + class_of_button)[0];
	var hidden_items = $$('.' + class_of_hidden_items);
	var expand = (cntl.innerHTML == '[show all]');
	if (expand) {
		cntl.innerHTML = '[hide some]';
		hidden_items.each(function(item) {
			item.removeClassName('hidden');
		});
	} else {
		cntl.innerHTML = '[show all]';
		hidden_items.each(function(item) {
			item.addClassName('hidden');
		});
	}
}