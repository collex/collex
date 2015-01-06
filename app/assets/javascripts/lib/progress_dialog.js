/*global GeneralDialog, getCurrentProgressDialog, hideProgressDialog */

jQuery(document).ready(function($) {
   "use strict";

   var progressDialog = null;
   var progressCount = 0;

   function showProgressDialog(message) {
      if (!progressDialog) {
         var dlgLayout = {
            page: 'spinner_layout',
            rows: [
               //[ {picture: '/images/progress_transparent.gif', alt: 'please wait'}],
               [
                  {
                     text: ' ',
                     klass: 'gd_transparent_progress_spinner'
                  }
               ],
               [
                  {
                     rowClass: 'gd_progress_label_row'
                  },
                  {
                     text: message,
                     klass: 'transparent_progress_label gd_progress_dialog_message_text'
                  }
               ]
            ]
         };

         var pgsParams = {
            this_id: "gd_progress_spinner_dlg",
            pages: [dlgLayout],
            body_style: "gd_progress_spinner_div",
            row_style: "gd_progress_spinner_row"
         };
         var dlg = new GeneralDialog(pgsParams);
         //dlg.changePage('layout', null);
         dlg.center();

         progressDialog = dlg;
      } else {
         $('.gd_progress_dialog_message_text').text(message);
      }
      progressDialog.show(); // make sure it is visible
      progressCount++;
      return progressDialog;
   }

   function getCurrentProgressDialog() {
      return progressDialog;
   }

   function cancelProgressDialog() {
      if (progressDialog) {
         progressCount--;
         if (progressCount <= 0) {
            progressCount = 0;
            progressDialog.cancel();
            progressDialog = null;
         }
      }
   }

   window.showProgressDialog = showProgressDialog;
   window.cancelProgressDialog = cancelProgressDialog;
   window.getCurrentProgressDialog = getCurrentProgressDialog;

});
   