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

/*global $, $w, Element */
/*global MessageBoxDlg, TextInputDlg */
/*extern doSaveSearch, searchValidation */

// Returns true if the form should be submitted.
// Puts up a message, then returns false if the form shouldn't be submitted.
function searchValidation(year_input_id, phrase_input_id, input_type, submit_id, submit_id2)
{
	// First disable the submit buttons so we don't get a double click.
	// The second submit button might be null.
	var submit_buttons = [];
	submit_buttons.push($(submit_id));
	if (submit_id2 !== null && $(submit_id2) !== null)
		submit_buttons.push($(submit_id2));

	var submit_text = submit_buttons[0].value;
	
	submit_buttons.each(function(submit_button) {
		submit_button.disabled = true;
		submit_button.value = "......";
	});

	// Some local functions
	var restoreSubmitButtons = function() {
		submit_buttons.each(function(submit_button) {
		submit_button.disabled = false;
		submit_button.value = submit_text;
		});
	};

	var errorDlg = function(message) {
		new MessageBoxDlg("Error", message);
		restoreSubmitButtons();
	};
	
	var input_year = $(year_input_id);

	// Be sure the user has typed something into at least one field.
	if (input_year) {
		var form = input_year.up('form');
		var allInputs = form.select('input[type=text]');
		var bFound = false;
		allInputs.each(function(el) {
			if (el.value.length > 0)
				bFound = true;
		});

		if (!bFound) {
			errorDlg("Please enter some text before searching.");
			return false;
		}
	}

	// Be sure the hint text isn't still displayed
	var hint_text_id = null;
	if (!input_type)
		hint_text_id = year_input_id;
	else if ($(input_type).selectedIndex === 0)	// If this is the "Search Term" item
		hint_text_id = phrase_input_id;
	else hint_text_id = year_input_id;
	
	if ($(hint_text_id) && $(hint_text_id).hasClassName('gd_input_hint_style'))
	{
		errorDlg("Please enter some text before searching.");
	    return false;
	} 
		
	// Now see if the year item is legal. If input_type is null, then the year_input_id really is
	// just for the year. If input_type is not null, then it is a select control that must have the value "Year".
	if ((input_type !== null) && ($(input_type).value !== "Year (YYYY)"))	// See if the input_year element really contains a year.
		return true;

	if (input_year) {
		var year_val = input_year.value.trim().replace(/to/i, 'TO').replace(/\s+/, ' ');
		if (year_val === "")
			return true;

		// At this point, year_val contains the user's input for the year.
        // Make sure it is 4 digits or a valid solr span (e.g. 1700 TO 1900)

        var re = /^\d{4}(\s+TO\s+\d{4})?$/

        if (!re.match(year_val))
        {
            errorDlg("The year must be 4 digits or a valid year span (e.g. 1700 TO 1900).");
            return false;
        }

	}
	
	// if the two validation steps above pass, submit the form
	return true;
}

function doSaveSearch()
{
	new TextInputDlg({
		title: "Save Search",
		prompt: 'Name:',
		id: 'saved_search_name',
		okStr: 'Save',
		actions: "/search/save_search",
		target_els: "saved_search_name_span",
		pleaseWaitMsg: "Storing the current search..."
	});
}

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
(function(){
  var methods = {
    defaultValueActsAsHint: function(element, default_value){
      element = $(element);
      element.default_value = default_value;

	  if (element.value === default_value)
		  element.addClassName('gd_input_hint_style');

      return element.observe('focus', function(){
        if(element.default_value !== element.value) return;
        element.removeClassName('gd_input_hint_style').value = '';
      }).observe('blur', function(){
        if(element.value.strip() !== '') return;
        element.addClassName('gd_input_hint_style').value = element.default_value;
      });
    },

	getRealValue: function(element) {
	  if (element.value === element.default_value)
		  return null;
	  if (element.value.length === 0)
		  return null;
	  return element.value;
	}
  };

  $w('input').each(function(tag){ Element.addMethods(tag, methods); });
})();


