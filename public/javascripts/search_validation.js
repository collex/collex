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

function yearValidation(theForm, input_id, alt_input_id, alt_input_type, submit_id, event)
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
			theForm.submit();
			return true;
		}
		
	}
	else
	{
		var input_year = $(alt_input_id);
		var input_type = $(alt_input_type);
		if (input_year == null || input_type == null)
		{
			theForm.submit();
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
			theForm.submit();
			return true;
		}
		year_val = input_year.value;
	}
	// At this point, year_val contains the user's input for the year. Make sure it is exactly 4 digits
	
	// Figure out where to put the error box if we need one. 
	var par = theForm.offsetParent;
	var x = theForm.offsetLeft + input_year.offsetLeft;
	var y = theForm.offsetTop + input_year.offsetTop;
	while (par != undefined)
	{
		x += par.offsetLeft;
		y += par.offsetTop;
		par = par.offsetParent;
	}

  // test if the year is an integer
  if (year_val != parseInt(year_val))
  {
  	event.x = x;
	event.y = y;
    showAlert('yearalert', event);
    new Effect.Appear('year_numeric_error_msg', { duration: 0.0 });
    new Effect.Fade('year_length_error_msg', { duration: 0.0 });

	submit_button.disabled = false;
	submit_button.value = submit_text;
    return false;
  }

  // test if the year is 4 digits in length
  if (year_val.length != 4)
  {
  	event.x = x;
	event.y = y;
    showAlert('yearalert', event);
    new Effect.Appear('year_length_error_msg', { duration: 0.0 });
    new Effect.Fade('year_numeric_error_msg', { duration: 0.0 });

	submit_button.disabled = false;
	submit_button.value = submit_text;
    return false;
  }

  // if the two validation steps above pass, submit the form
  theForm.submit(); 
  return true;
}

function showAlert(divID, event)
{
  new Effect.Appear(divID, { duration: 0.5 }); 
  var newXCoordinate = (event.pageX)?event.pageX + xOffset:event.x + xOffset + ((document.body.scrollLeft)?document.body.scrollLeft:0);
  var newYCoordinate = (event.pageY)?event.pageY + yOffset:event.y + yOffset + ((document.body.scrollTop)?document.body.scrollTop:0);
  moveObject2(divID, newXCoordinate, newYCoordinate);
}
