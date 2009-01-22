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

function yearValidation(input_id, alt_input_id, alt_input_type, submit_id)
{
	// First disable the submit button so we don't get a double click.
	var submit_button = $(submit_id);
	var submit_text = submit_button.value;
	submit_button.disabled = true;
	submit_button.value = "......";
	 
	// Either there is a control named input_id, or there are two controls, alt_input_id, alt_input_type.
	// In the second case, the type is a select control and we want to ignore the validation unless
	// the type="Year".
	var input_year = $(input_id);
	var year_val = "";
	if (input_year != null)
	{
		year_val = input_year.value;
		if (year_val == "")
		{
			return true;
		}
		
	}
	else
	{
		var input_year = $(alt_input_id);
		var input_type = $(alt_input_type);
		if (input_year == null || input_type == null)
		{
			return true;
		}
		
		// Be sure the hint text isn't still displayed
		if (input_year.hasClassName('inputHintStyle'))
		{
			submit_button.disabled = false;
			submit_button.value = submit_text;
		    return false;
		}
		
		if (input_type.value != "Year")
		{
			return true;
		}
		year_val = input_year.value;
	}
	// At this point, year_val contains the user's input for the year. Make sure it is exactly 4 digits
	
  // test if the year is an integer
  if (year_val != parseInt(year_val))
  {
	doSingleInputPrompt("Error", "The year must contain only numerals.", null, submit_id, null, null, $H({ }), "none", null);

	submit_button.disabled = false;
	submit_button.value = submit_text;
    return false;
  }

  // test if the year is 4 digits in length
  if (year_val.length != 4)
  {
	doSingleInputPrompt("Error", "The year must  be 4 digits long.", null, submit_id, null, null, $H({ }), "none", null);

	submit_button.disabled = false;
	submit_button.value = submit_text;
    return false;
  }

  // if the two validation steps above pass, submit the form
  return true;
}
