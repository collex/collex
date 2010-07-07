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

/*global $, $$ */
/*global window */
/*extern changeFederation */

function changeFederation(checkbox) {
	// there are three checkboxes on the search page.
	// The one that says "search (OtherFed) too!" is always synced up with the second checkbox on the federation list.
	// The two items in the federation list cannot both be unchecked at the same time, but they can both be checked at the same time.
	var too = $('search_federation');
	var federationChecks = $$('.limit_to_federation input[type="checkbox"]');
	if (federationChecks.length >= 2) {
		if (checkbox.name === federationChecks[1].name) {
			if (too !== null)
				too.checked = checkbox.checked;
			if (checkbox.checked === false && federationChecks[0].checked === false)
				federationChecks[0].checked = true;
		}
		if (checkbox.name === federationChecks[0].name) {
			if (checkbox.checked === false && federationChecks[1].checked === false) {
				federationChecks[1].checked = true;
				if (too !== null)
					too.checked = true;
			}
		}

		if (too !== null && checkbox.name === too.name) {
			federationChecks[1].checked = checkbox.checked;
			if (checkbox.checked === false && federationChecks[0].checked === false)
				federationChecks[0].checked = true;
		}
	}

	// Now that the checkboxes are set, tell the server. If both are set, then we don't want to send a federation parameter
	var param = {};
	if (federationChecks[0].checked === true && federationChecks[1].checked === false)
		param.federation = federationChecks[0].name;
//		param = "?federation=" + federationChecks[0].name;
	else if (federationChecks[0].checked === false && federationChecks[1].checked === true)
		param.federation = federationChecks[1].name;
//		param = "?federation=" + federationChecks[1].name;
	param.phrs = $('search_phrase') ? $('search_phrase').getRealValue() : null;
	ajaxWithProgressSpinner([ "/search/add_federation_constraint" ], [ null ], { waitMessage: 'Changing federation...' }, param);
//	window.location = "/search/add_federation_constraint" + param;
}

