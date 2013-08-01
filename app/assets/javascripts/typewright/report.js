jQuery(document).ready(function() {
   jQuery(".tw_overview .nav_link").on("click", function() {
      var order = "";
      var filter = jQuery("#tw_filter").val();
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
      if (  jQuery(this).attr("id") == "tw-doc-title-sort" ) {
         sortBy = "title";
      } else if (  jQuery(this).attr("id") == "tw-doc-modified-sort" ) {
         sortBy = "modified";
      } else if (  jQuery(this).attr("id") == "tw-doc-percent-sort" ) {
         sortBy = "percent";
      } else if (  jQuery(this).attr("id") == "tw-user-name-sort" ) {
         sortBy = "user";
      } else if (  jQuery(this).attr("id") == "tw-user-edited-sort" ) {
         sortBy = "edited";
      } else if (  jQuery(this).attr("id") == "tw-user-modified-sort" ) {
         sortBy = "modified";
      }
      
      var url = "/typewright/overviews?sort="+sortBy+"&order="+order+"&filter="+filter;
      if ( jQuery("#curr_view").text() == "users") {
         url = "/typewright/overviews?view=users&sort="+sortBy+"&order="+order+"&filter="+filter;
      }
      window.location = url;
   });
}); 