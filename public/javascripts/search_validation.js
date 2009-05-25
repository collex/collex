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

/*global $, $H */
/*global doSingleInputPrompt */

// Returns true if the form should be submitted.
// Puts up a message, then returns false if the form shouldn't be submitted.
function searchValidation(year_input_id, input_type, submit_id, submit_id2)
{
	// First disable the submit buttons so we don't get a double click.
	// The second submit button might be null.
	var submit_buttons = [];
	submit_buttons.push($(submit_id));
	if (submit_id2 !== null)
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
	
	// Be sure the hint text isn't still displayed
	if (input_year.hasClassName('inputHintStyle'))
	{
		errorDlg("Please enter some text before searching.");
	    return false;
	}
	
	// Now see if the year item is legal. If input_type is null, then the year_input_id really is
	// just for the year. If input_type is not null, then it is a select control that must have the value "Year".
	if ((input_type !== null) && ($(input_type).value !== "Year (YYYY)"))	// See if the input_year element really contains a year.
		return true;

	var year_val = input_year.value;
	if (year_val === "")
		return true;

	// At this point, year_val contains the user's input for the year. Make sure it is exactly 4 digits
	
	// test if the year is an integer
	if (year_val !== "" + parseInt(year_val))
	{
		errorDlg("The year must contain only numerals.");
		return false;
	}
	
	// test if the year is 4 digits in length
	if (year_val.length !== 4)
	{
		errorDlg("The year must be 4 digits long.");
		return false;
	}
	
	// if the two validation steps above pass, submit the form
	return true;
}
