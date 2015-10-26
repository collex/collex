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

/*global $, MessageBoxDlg */
/*extern searchValidationHome */

jQuery(document).ready(function($) {
   "use strict";
   var form = $("#do-basic-search");
   
    /*mjc, 10/15/15 - the home page search box needs to be sanitized as well*/
    /*                copied code from search.js*/
    window.collex.sanitizeString = function(str) {
	   if (typeof str === "undefined") {
	     return str;
	   }
		str = str.replace(/[^0-9A-Za-z\-'"\u00C0-\u017F]/g, ' ');
		while (str.substr(0,1) === "'")
			str = str.substr(1);
		str = str.replace(/ '/g,' '); // Allow an apostrophe inside a word, but not at the beginning of a word.
		str = str.replace(/\s+/g, ' ');
		return $.trim(str);
	};
	
	form.on("submit", function(e) {
      e.preventDefault();
      var submit_button = $("#search_button");
      var submit_text = submit_button.val();
      submit_button.disabled = true;
      submit_button.val("......");

      var search_phrase = $("#search_phrase").val();
      if (search_phrase.length === 0) {
         new MessageBoxDlg("Error", "Please enter some text before searching.");
         submit_button.disabled = false;
         submit_button.value = submit_text;
         return false;
      }

      window.location = "/search?q="+encodeURIComponent(window.collex.sanitizeString(search_phrase));     /*mjc, 10/15/15*/
   });

});



