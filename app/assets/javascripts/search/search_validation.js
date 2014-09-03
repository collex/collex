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

/*global MessageBoxDlg */

jQuery(document).ready(function($) {
	"use strict";
	var body = $("body");
	var form = $('#add-search-constraint');

	// Puts up a message, then returns false if the form shouldn't be submitted.
	form.on("submit", function() {
		window.console.log("add-search-constraint onSubmit");
		// IE will try to submit this when the enter key is pressed. Make sure it is visible to prevent that.
		var isVisible = $('.add_constraint_form').is(':visible');
		if (!isVisible) {
			window.console.log("aborted submit");
			return false;
		}

		// First disable the submit buttons so we don't get a double click.
		// The second submit button might be null.
		var submit_buttons = form.find('input[type="submit"]');

		var submit_text = submit_buttons.val();

		submit_buttons.each(function(index, submit_button) {
			submit_button.disabled = true;
			submit_button.value = "......";
			submit_button.addClassName('submitting');
		});

		var restoreSubmitButtons = function() {
			submit_buttons.each(function(index, submit_button) {
				submit_button.disabled = false;
				submit_button.value = submit_text;
				submit_button.removeClassName('submitting');
			});
		};

		var errorDlg = function(message) {
			new MessageBoxDlg("Error", message);
			restoreSubmitButtons();
		};

		// Be sure the user has typed something into at least one field.
		var allInputs = form.find('input[type="text"],select[class="search_language"]');
		var searchHash = {};
		var bFound = false;
		allInputs.each(function(index, el) {
			if ($(el).val().length > 0) {
				bFound = true;
				searchHash[el.name] = $(el).val();
			}
		});

		if (!bFound) {
			errorDlg("Please enter some text before searching.");
			return false;
		}

		var year = searchHash.y;
		if (year && year.length > 0) {
			year = year.trim().replace(/-/, ' TO ').replace(/to/i, 'TO').replace(/\s+/, ' ');
			year = year.trim();
			if (year.length > 0) {
				// At this point, year_val contains the user's input for the year.
				// Make sure it is 4 digits or a valid solr span (e.g. 1700 TO 1900)

				var re = /^\d{4}(\s+TO\s+\d{4})?$/;

				if (!re.match(year)) {
					errorDlg("The year must be 4 digits or a valid year span (e.g. 1700 TO 1900).");
					return false;
				}
				searchHash.y = year;
			} else
				delete searchHash.y;
		}

		// We've passed all the tests, so send the search to the searcher. We still short-circuit the browser's submit.

		body.trigger('SetSearch', searchHash);

		setTimeout(function() { // Don't clear the fields right away. That's disconcerting to the user.
			allInputs.val('');
			restoreSubmitButtons();
		}, 2000);

		return false;
	});
});

//function postToUrl(url, hashParams)
//{
//	var myForm = document.createElement("form");
//	myForm.method="post";
//	myForm.action = url;
//	hashParams.authenticity_token = form_authenticity_token;
//	for (var k in hashParams) {
//		if (hashParams.hasOwnProperty(k)) {
//			var myInput = document.createElement("input") ;
//			myInput.setAttribute("name", k);
//			myInput.setAttribute("value", hashParams[k]);
//			myForm.appendChild(myInput);
//		}
//	}
//	document.body.appendChild(myForm);
//	myForm.submit();
//	document.body.removeChild(myForm);
//}

// This is an extension to prototype from http://mir.aculo.us/2009/1/7/using-input-values-as-hints-the-easy-way
// It allows input fields to have hints
//(function(){
//  var methods = {
//    defaultValueActsAsHint: function(element, default_value){
//      element = $(element);
//      element.default_value = default_value;
//
//    if (element.value === default_value)
//      element.addClassName('gd_input_hint_style');
//
//      return element.observe('focus', function(){
//        if(element.default_value !== element.value) return;
//        element.removeClassName('gd_input_hint_style').value = '';
//      }).observe('blur', function(){
//        if(element.value.strip() !== '') return;
//        element.addClassName('gd_input_hint_style').value = element.default_value;
//      });
//    },
//
//	getRealValue: function(element) {
//    if (element.value === element.default_value)
//      return null;
//    if (element.value.length === 0)
//      return null;
//    return element.value;
//	}
//  };
//
//  $w('input').each(function(tag){ Element.addMethods(tag, methods); });
//})();


