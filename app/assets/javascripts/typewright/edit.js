/*globals TW, alert */

jQuery(document).ready(function() {
	"use strict";
   jQuery(".tw_edit_page_nav_button .tw-complete-btn").on("click", function() {
      jQuery.ajax({
         url : "/typewright/documents/"+TW.doc_id+"/complete",
         type : 'POST',
         beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', jQuery('meta[name="csrf-token"]').attr('content'));},
         success : function(resp, textStatus, jqXHR) {
            jQuery(".tw-complete-msg").show();
            jQuery(".tw-complete-btn").hide();
         },
         error : function( jqXHR, textStatus, errorThrown ) {
            alert("Unable to set document status to complete");
         }
      });
   });
});