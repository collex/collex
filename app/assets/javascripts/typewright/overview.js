jQuery(document).ready(function() {
	"use strict";

	var showWaitPopup = function( ) {
      jQuery('#dim-overlay').show();
      jQuery("#wait-spinner").show();
      jQuery('#wait-popup').show();
   };
   
   var hideWaitPopup = function() {
      jQuery('#dim-overlay').hide();
      jQuery("#wait-popup").hide();
   };
   
   jQuery(".tw-retrieve-link").on("click", function() {
      showWaitPopup();  
      var d = new Date();
      var token = Math.round(d.getTime() / 1000);
      var oldHref = jQuery(this).attr("href");
      var pos = oldHref.indexOf("&token");
      if ( pos > -1 ) {
         oldHref = oldHref.substring(0,pos);
      }
      jQuery(this).attr("href", oldHref+"&token=" + token); 
      var limit = 300;
      var intId = setInterval(function() {
         var cookieValue = jQuery.cookie('fileDownloadToken');
         limit -= 1;
         if (cookieValue == token || limit <= 0) {
            hideWaitPopup();
            clearInterval(intId);
         }
      }, 500);
   });
   
   jQuery("#content_container.admin .nav_link").on("click", function() {
      showWaitPopup();   
   });
   
   jQuery("form.filter").on("submit", function() {
      showWaitPopup();   
   });
   
   jQuery(".tw_overview .nav_link").on("click", function() {
      var order = "";
      var filter = jQuery("#tw_filter").val();
      if ( filter.length > 0 ) {
         filter = "&filter="+filter;
      }
      if (jQuery(this).hasClass("tw_asc")) {
         order = "desc";
      } else if (jQuery(this).hasClass("tw_desc")) {
         order = "asc";
      } else {
         order = "asc";
      }
      jQuery(".tw_overview .nav_link").removeClass("tw_asc");
      jQuery(".tw_overview .nav_link").removeClass("tw_desc");
      jQuery(this).addClass("tw_"+order);

      // document / user sorting. first set of conditionals are for doc, second for user
      var sortBy = "uri";
      var sortId = jQuery(this).attr("id");
      sortId = sortId.substring(0, sortId.length - "-sort".length);
      if ( sortId.indexOf("tw-doc") > -1 ) {
         sortBy = sortId.substring("tw-doc-".length);   
      } else {
         sortBy = sortId.substring("tw-user-".length);
      } 

      var url = "/typewright/overviews?sort="+sortBy+"&order="+order+filter;
      if ( jQuery("#curr_view").text() === "users") {
         url = "/typewright/overviews?view=users&sort="+sortBy+"&order="+order+filter;
      }
      window.location = url;
   });
   
   // Reset filter
   jQuery("#tw_clear_filter").on("click", function() {
      showWaitPopup();
      jQuery("#tw_doc_status_filter").val("all");
      jQuery("#tw_filter").val("");
      jQuery("#tw_doc_filter_controls form").submit();
   });
   
   // change document status
   jQuery(".tw_change_doc_status").on("click", function() {
       jQuery(this).parent(".tw_status_display").hide();
       jQuery(this).parent().parent().find(".tw_status_change").show();
       jQuery(".tw_change_doc_status").attr("disabled", "disabled");
   });
   
  
   // Called to close out the status change popup triggered from the specifed button
   var closeStatusChange = function(eventSource) {
      jQuery(eventSource).parent().hide();
      jQuery(eventSource).parent().parent().find(".tw_status_display").show();
      jQuery(".tw_change_doc_status").removeAttr("disabled");
   }; 
   
   // cancel document status change
   jQuery(".tw_cancel_status").on("click", function() {
      closeStatusChange(this);   
   });
   
   // save document status change
   jQuery(".tw_save_status").on("click", function() {
      var evtSrc = this;
      var docId = jQuery(this).attr("id").substring("tw_save_status_".length);
      var newStat = jQuery(this).parent().find('select').val();
      var statusTxt = "No";
      if ( newStat === "complete" ) {
         statusTxt = "Confirmed complete";
      }
      
      showWaitPopup();
      jQuery.ajax({
         url : "/typewright/documents/" + docId + "/status",
         type : 'POST',
         data : {
            new_status : newStat
         },
         beforeSend : function(xhr) {
            xhr.setRequestHeader('X-CSRF-Token', jQuery('meta[name="csrf-token"]').attr('content'));
         },
         success : function(resp, textStatus, jqXHR) {
            closeStatusChange(evtSrc);
            jQuery(evtSrc).parent().parent().find('.tw_status_txt').text(statusTxt);
            hideWaitPopup();
         },
         error : function(jqXHR, textStatus, errorThrown) {
            hideWaitPopup();
            alert("Unable to change document status:\n\t"+jqXHR.responseText);
         }
      });
   }); 

}); 